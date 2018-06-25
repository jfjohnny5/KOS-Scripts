parameter missionPhase.
local orbitAlt is 175000.
local orbitIncl is 10.
local launchTWR is 1.90.
local turnStart is 750.
global Mission is lexicon(
	"Launch",	launchPhase@,
	"Orbit",	orbitPhase@,
	"Stage",	stageNow@
).
local function launchPhase {
	print "Initiating 'Launch' program".
	preflight(orbitAlt, orbitIncl, launchTWR, turnStart).
	ascentGuidance(orbitAlt, orbitIncl, turnStart).
}
local function orbitPhase {
	print "Initiating 'Transfer' program".
	performBurn().
	postBurn().
}
local throttleControl is 0.
local prevThrust is 0.
local turnExponent is 0.
local turnEnd is 0.
local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
local function preflight {
	parameter orbitAlt, orbitIncl, launchTWR, turnStart.
	set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
	set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
	fairingCheck().
	if exists("0:/flightrecorder.csv") deletepath("0:/flightrecorder.csv").
	log "time,alt,vel,q,atm,att,hdng,mass" to "0:/flightrecorder.csv".
	lock THROTTLE to throttleControl.
	SAS ON.
}
local function ascentGuidance {
	parameter orbitAlt, orbitIncl, turnStart.
	local loopCnt is 0.
	ignition().
	print "Guidance system active".
	when ALTITUDE > turnStart then {
		print "Executing roll and pitch maneuver".
		SAS OFF.
	}
	when ALTITUDE > BODY:ATM:HEIGHT * 0.95 then RCS ON.
	when APOAPSIS >= orbitAlt then {
		print "Apoapsis nominal".
		if ALTITUDE < BODY:ATM:HEIGHT print "Coasting until " + BODY:ATM:HEIGHT + " m".
	}
	until false {
		if mod(loopCnt, 10) = 0 {
			telemetry().
		}
		if ALTITUDE > turnStart and APOAPSIS < orbitAlt {
			ascentProfile(orbitIncl, turnStart).
		}
		checkStaging().
		if APOAPSIS >= orbitAlt {
			set throttleControl to 0.
			lock STEERING to PROGRADE.
		}
		if ALTITUDE > BODY:ATM:HEIGHT break.
		set loopCnt to loopCnt + 1.
		wait 0.01.
	}
	print "Guidance system deactivated".
}
local function checkStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT and MAXTHRUST >= 0.1 {
			wait 1. print "Dropping Boosters".
			stage.
			wait 1. return true.
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            set throttleControl to 0.
			wait 1. print "Decoupling Stage".
			stage.
            wait 1. set throttleControl to 1.
			return true.
			break.
        }
    }
}
local function telemetry {
	local time is TIME:SECONDS.
	local alt is SHIP:ALTITUDE.
	local vel is SHIP:AIRSPEED.
	local q is SHIP:DYNAMICPRESSURE.
	local atm is BODY:ATM:ALTITUDEPRESSURE(SHIP:ALTITUDE).
	local att is vang(SHIP:FACING:FOREVECTOR, SHIP:UP:UPVECTOR).
	local hdng is mod(360 - SHIP:BEARING, 360).
	local mass is SHIP:MASS.
	log time+","+alt+","+vel+","+q+","+atm+","+att+","+hdng+","+mass to "0:/flightrecorder.csv".
}
local function fairingCheck {
	local hasFairing is false.

	for p in SHIP:PARTSTAGGED("fairing") {
		set fairing to p:GETMODULE("ModuleProceduralFairing").
		set hasFairing to true.
	}
	if hasFairing {
		print "Fairing will jettison at " + (BODY:ATM:HEIGHT * 0.9) + " m".
		when ALTITUDE > BODY:ATM:HEIGHT * 0.9 then {
			fairing:DOEVENT("deploy").
		}
	}
}
local function ignition {
	print "Main engine start".
	set throttleControl to 1.
	wait 0.01. print "=== LAUNCH ===".
	stage.
}
local function ascentProfile {
	parameter orbitIncl, turnStart.
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).
}
local function maneuverTime {
	parameter dV.
	local f is 0.
	local m is SHIP:MASS * 1000.
	local e is CONSTANT():E.
	local p is 0.
	local g is SHIP:ORBIT:BODY:MU / (SHIP:ORBIT:BODY:RADIUS)^2.
	local enCount is 0.
	list ENGINES in all_engines.
	for en in all_engines if en:IGNITION and not en:FLAMEOUT {
		set f to f + en:AVAILABLETHRUST.
		set p to p + en:ISP.
		set enCount to enCount + 1.
	}
	set p to p / enCount.
	set f to f * 1000.
	return g * m * p * (1 - e^(-dV / (g * p))) / f.
}
local function performBurn {
	parameter autowarp is false.
	parameter node is NEXTNODE.
	parameter dV0 is node:DELTAV.
	parameter t0 is TIME:SECONDS + node:ETA - maneuverTime(dV0:MAG) / 2.
	print "Node in: " + round(node:ETA) + " s, DeltaV: " + round(node:DELTAV:MAG) + " m/s".
	SAS OFF.
	lock STEERING to node:DELTAV.
	if autowarp warpto(t0 - 30).
	wait until TIME:SECONDS >= t0.
	local throttleControl is 0.
	lock THROTTLE to throttleControl.
	until vdot(node:DELTAV, dV0) < 0.01 {
		checkStaging().
		// feather the throttle when < 1s
		set throttleControl to min(maneuverTime(node:DELTAV:MAG), 1).
		wait 0.1.
	}
	lock THROTTLE to 0.
	wait 0.
}
local function postBurn {
	remove NEXTNODE.
	unlock STEERING.
	unlock THROTTLE.
	wait 0.1.
	set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
}
local function stageNow {
	print "Manual staging trigger activated".
	stage.
	wait 3.
}
Mission[missionPhase]().