// lib.launch.ks
// Function library for ascent and circularization into stable orbit
// John Fallara

// Initialization
runoncepath("lib.utility.ks").

// Library init variables
local throttleControl is 0.
local prevThrust is 0.
local launchTWR is 0.
local turnExponent is 0.
local turnEnd is 0.
local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
local dynPress is 0.
local steerHeading is 90.
local steerPitch is 90.
// TO DO - clean up 'steerTo' so it isn't duplicated code in ascentProfile()
set steerTo to lookdirup(heading(steerHeading, steerPitch):vector, SHIP:FACING:TOPVECTOR).

global Launch is lexicon(
	"Preflight",	preflight@,
	"Ascent",		ascentGuidance@
).

// Calculations for guidance, logging, initial control set
local function preflight {
	parameter orbitAlt, orbitIncl, turnStart.
	print "=== Main Program Initiated ===".
	fairingCheck().
	if exists("0:/flightrecorder.csv") deletepath("0:/flightrecorder.csv").
	log "time,alt,vel,q,atm,att,hdng,mass" to "0:/flightrecorder.csv".
	lock THROTTLE to throttleControl.
	lock STEERING to steerTo.
	initGuidance(orbitAlt, orbitIncl, turnStart).
}

// Ignite engines, calculate TWR, and build ascent profile
local function initGuidance {
	parameter orbitAlt, orbitIncl, turnStart.
	engineStart().
	set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
	set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
	consoleLog(orbitAlt, orbitIncl, turnStart).
	print "Guidance system active".
}

local function engineStart {
	print "Main engine start".
	set throttleControl to 1.
	wait 0.01. print "=== LAUNCH ===".
	stage.
	local engInfo is Utility["Active Engine Info"]().
	set launchTWR TO engInfo[1]/(SHIP:MASS*BODY:MU/(ALTITUDE+BODY:RADIUS)^2).
}

// Guidance control from launch to crossing Atmo height line
local function ascentGuidance {
	parameter orbitAlt, orbitIncl, turnStart.
	local loopCnt is 0.
	local mico is false.
	when ALTITUDE > turnStart then {
		print "Executing roll and pitch maneuver".
	}
	when ALTITUDE > BODY:ATM:HEIGHT * 0.95 then RCS ON.
	when APOAPSIS >= orbitAlt then {
		print "Apoapsis nominal".
		if ALTITUDE < BODY:ATM:HEIGHT print "Coasting until " + BODY:ATM:HEIGHT + " m".
		set mico to true.
	}
	until false {
		if mod(loopCnt, 10) = 0 {
			Utility["Telemetry"]().
		}
		if ALTITUDE > turnStart and APOAPSIS < orbitAlt and not mico {
			ascentProfile(orbitIncl, turnStart).
			limitTWR().
		}
		Utility["Check Staging"]().
		if APOAPSIS >= orbitAlt {
			set throttleControl to 0.
			SAS ON.
			unlock STEERING.
		}
		if ALTITUDE > BODY:ATM:HEIGHT break.
		set loopCnt to loopCnt + 1.
		wait 0.01.
	}
	print "Guidance system deactivated".
}

local function consoleLog {
	parameter orbitAlt, orbitIncl, turnStart.
	print "Desired orbital altitude:    " + orbitAlt + " m".
	print "Desired orbital inclination: " + orbitIncl + " deg".
	print "Launch TWR:                  " + round(launchTWR, 2).
	print "Ascent profile exponent:     " + round(turnExponent, 5).
	print "Gravity turn start:          " + turnStart + " m".
	print "Gravity turn end:            " + round(turnEnd) + " m".
	print "Atmospheric height:          " + BODY:ATM:HEIGHT + " m".
}

local function fairingCheck {
	local hasFairing is false.

	for p in SHIP:PARTSTAGGED("fairing") {
		set fairing to p:GETMODULE("ModuleProceduralFairing").
		set hasFairing to true.
	}
	if hasFairing {
		print "Fairing detected".
		print "Fairing will jettison at " + (BODY:ATM:HEIGHT * 0.9) + " m".
		when ALTITUDE > BODY:ATM:HEIGHT * 0.9 then {
			fairing:DOEVENT("deploy").
		}
	}
}

// ascent trajectory defined by equation
local function ascentProfile {
	parameter orbitIncl, turnStart.
	set steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).
	set steerHeading to orbitIncl * -1 + 90.
	set steerTo to lookdirup(heading(steerHeading, steerPitch):vector, SHIP:FACING:TOPVECTOR).
	limitAoA().
}

// Don't pitch too far off surface prograde while under high dynamic pressrue
local function limitAoA {
	if SHIP:Q > 0 set angleLimit to max(3, min(90, 5*LN(0.9/SHIP:Q))).
	else set angleLimit to 90.
	set angleToPrograde to vang(SHIP:SRFPROGRADE:VECTOR, steerTo:VECTOR).
	if angleToPrograde > angleLimit {
		set steerToLimited to (angleLimit/angleToPrograde * (steerTo:VECTOR:NORMALIZED - SHIP:SRFPROGRADE:VECTOR:NORMALIZED)) + SHIP:SRFPROGRADE:VECTOR:NORMALIZED.
		set steerTo to lookdirup(steerToLimited, SHIP:FACING:TOPVECTOR).
	}.
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