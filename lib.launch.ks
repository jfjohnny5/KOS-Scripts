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
//local pid is lexicon("Ascent",pid_Asc).

global Launch is lexicon(
	"Preflight",			preflight@,
	"Ignition",				ignition@,
	"Check Staging",		checkStaging@,
	"Stage Now",			stageNow@,
	"Ascent",				ascent@
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
	fairingCheck().
	until false {
		ascentProfile(orbitIncl, turnStart).
		limitTWR().
		checkStaging().
		if altitudeTarget(orbitAlt) { break. }
		wait 0.001.
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
	wait 0.5. print "LAUNCH".
	stage.

	wait until ALTITUDE > turnStart.
	print "Initiating ascent program".
	print "Executing roll and pitch maneuver".
	SAS OFF.
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

local function stageNow {
	parameter trigger.
	when ALTITUDE > trigger then {
		stage.
	}
}

local function ascentProfile {
	parameter orbitIncl, turnStart.
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).	// ascent trajectory defined by equation
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).	// convert desired inclination into compass heading
}

local function altitudeTarget {
	parameter orbitAlt.
	if APOAPSIS > orbitAlt {
		print "Apoapsis nominal".
		set throttleControl to 0.
		when ALTITUDE > BODY:ATM:HEIGHT * 0.95 then RCS ON.
		lock STEERING to PROGRADE.
		return true.
	}
}

local function coast {
	lock STEERING to PROGRADE.
	wait until ALTITUDE > BODY:ATM:HEIGHT.
}

// Throttle down feedback control loop
local function limitTWR {
	set pid_Asc:SETPOINT to 4. // TWR upper limit for ascent
	if ALTITUDE < (BODY:ATM:HEIGHT * 0.4) {
		local engInfo to Utility["Active Engine Info"]().
		set currentTWR to engInfo[0] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set maxTWR to engInfo[1] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set throttleAdjust to pid["Ascent"]:UPDATE(TIME:SECONDS, currentTWR).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
	}
	else set throttleControl to 1.
}