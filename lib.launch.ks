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
	"Ascent",		ascent@
).

// Any calculations and system prep
local function preflight {
	parameter orbitAlt, orbitIncl, launchTWR, turnStart.
	set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
	set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
	lock THROTTLE to throttleControl.
	consoleLog(orbitAlt, orbitIncl, launchTWR, turnStart).
	fairingCheck().
}

// The actual ascent process
local function ascent {
	parameter orbitAlt, orbitIncl, turnStart.
	ignition(turnStart).
	until false {
		ascentProfile(orbitIncl, turnStart).
		maxQ().
		limitTWR().
		Utility["Check Staging"]().
		if altitudeTarget(orbitAlt) { break. }
		wait 0.01.
	}
	coast().
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
	parameter turnStart.
	SAS ON.
	print "Main engine start".
	set throttleControl to 1.
	wait 0.01. print "=== LAUNCH ===".
	stage.

	wait until ALTITUDE > turnStart.
	print "Initiating ascent routine".
	print "Executing roll and pitch maneuver".
	SAS OFF.
}

local function ascentProfile {
	parameter orbitIncl, turnStart.
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).	// ascent trajectory defined by equation
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).	// convert desired inclination into compass heading
}

local function maxQ {
	local lastPress is dynPress.
	set dynPress to SHIP:DYNAMICPRESSURE.
	when dynPress < lastPress then {
		print "Passing max Q".
		print "All systems nominal".
	}
}

local function altitudeTarget {
	parameter orbitAlt.
	if APOAPSIS > orbitAlt {
		print "Apoapsis nominal".
		set throttleControl to 0.
		return true.
	}
}

local function coast {
	lock STEERING to PROGRADE.
	when ALTITUDE > BODY:ATM:HEIGHT * 0.95 then RCS ON.
	if ALTITUDE < BODY:ATM:HEIGHT {
		print "Coasting until " + BODY:ATM:HEIGHT + " m".
		wait until ALTITUDE > BODY:ATM:HEIGHT.
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