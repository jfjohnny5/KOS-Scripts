// lib.launch.ks
// Function library for ascent and circularization into stable orbit
// John Fallara

// Initialization
runoncepath("lib.utility.ks").

// Llibrary variables
local throttleControl is 0.
local prevThrust is 0.
local turnExponent is 0.
local turnEnd is 0.
local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
local dynPress is 0.
//local pid is lexicon("Ascent",pid_Asc).

global Launch is lexicon(
	"Preflight",	preflight@,
	"Ascent",		ascentGuidance@
).

// Calculations for guidance, logging, initial control set
local function preflight {
	parameter orbitAlt, orbitIncl, launchTWR, turnStart.
	set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
	set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
	fairingCheck().
	if exists("0:/flightrecorder.csv") deletepath("0:/flightrecorder.csv").
	log "time,alt,vel,q,atm,att,hdng,mass" to "0:/flightrecorder.csv".
	consoleLog(orbitAlt, orbitIncl, launchTWR, turnStart).
	lock THROTTLE to throttleControl.
	SAS ON.
}

// Guidance control from launch to crossing Atmo height line
local function ascentGuidance {
	parameter orbitAlt, orbitIncl, turnStart.
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
		Utility["Telemetry"]().
		if ALTITUDE > turnStart and APOAPSIS < orbitAlt {
			ascentProfile(orbitIncl, turnStart).
			limitTWR().
		}
		Utility["Check Staging"]().
		if APOAPSIS >= orbitAlt {
			set throttleControl to 0.
			lock STEERING to PROGRADE.
		}
		if ALTITUDE > BODY:ATM:HEIGHT break.
		wait 0.01.
	}
	print "Guidance system deactivated".
}

local function consoleLog {
	parameter orbitAlt, orbitIncl, launchTWR, turnStart.
	print "Desired orbital altitude:    " + orbitAlt + " m".
	print "Desired orbital inclination: " + orbitIncl + " deg".
	print "Launch TWR:                  " + launchTWR.
	print "Gravity turn start:          " + turnStart + " m".
	print "Ascent profile exponent:     " + turnExponent.
	print "Gravity turn end:            " + turnEnd + " m".
	print "Atmospheric height:          " + BODY:ATM:HEIGHT + " m".
}

local function fairingCheck {
	local hasFairing is false.

	for p in SHIP:PARTSTAGGED("fairing") {
		set fairing to p:GETMODULE("ModuleProceduralFairing").
		set hasFairing to true.
	}
	if hasFairing {
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
	// ascent trajectory defined by equation
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).
}

local function maxQ {
	local lastPress is dynPress.
	set dynPress to SHIP:DYNAMICPRESSURE.
	when dynPress < lastPress then {
		print "Passing max Q".
		print "All systems nominal".
	}
}

// Throttle down feedback control loop
local function limitTWR {
	set pid_Asc:SETPOINT to 4. // TWR upper limit for ascent
	if ALTITUDE < (BODY:ATM:HEIGHT * 0.4) {
		local engInfo to Utility["Active Engine Info"]().
		set currentTWR to engInfo[0] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set maxTWR to engInfo[1] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set throttleAdjust to pid_Asc:UPDATE(TIME:SECONDS, currentTWR).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
	}
	else set throttleControl to 1.
}