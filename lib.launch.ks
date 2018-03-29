// lib.launch.ks
// Function library for ascent and circularization into stable orbit
// John Fallara

// Llibrary variables
local prevThrust is 0.
local throttleControl is 0.
local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
local pid is lexicon("Ascent",pid_Asc).

global Launch is lexicon(
	"Preflight",			preflight@,
	"Console Log",		consoleLog@,
	"Calculate Profile",	calculateProfile@,
	"Fairing Check", 		fairingCheck@,
	"Ignition",			ignition@,
	"Check Staging",		checkStaging@,
	"Stage Now",			stageNow@,
	"Ascent",			ascent@,
	"Ascent Profile",		ascentProfile@,
	"Altitude Target",	altitudeTarget@,
	"Limit TWR",			limitTWR@,
	"Circ Burn Calc",		circBurnCalc@,
	"Circularize",		circularize@
).

local function preflight {
	parameter orbitAlt, orbitIncl, launchTWR, turnStart.
	lock THROTTLE to throttleControl.
	calculateProfile(launchTWR).
	consoleLog(orbitAlt, orbitIncl, launchTWR, turnStart).
	fairingCheck().
}

// Echo flight path details to the terminal
local function consoleLog {
	print "Desired orbital altitude:    " + orbitAlt + " m".
	print "Desired orbital inclination: " + orbitIncl + " deg".
	print "Launch TWR:                  " + launchTWR.
	print "Gravity turn start:          " + turnStart + " m".
	print "Ascent profile exponent:     " + turnExponent.
	print "Gravity turn end:            " + turnEnd + " m".
	print "Atmospheric height:          " + BODY:ATM:HEIGHT + " m".
}

// Calculate ascent profile
local function calculateProfile {
	parameter launchTWR.
	global turnExponent is max(1 / (2.5 * launchTWR - 1.7), 0.25).
	global turnEnd is ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
}

// Fairing check
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

// Ignition
local function ignition {
	parameter turnStart.
	SAS ON.
	print "Main engine start".
	set throttleControl to 1.
	wait 0.5.
	print "LAUNCH".
	stage.

	wait until ALTITUDE > turnStart.
	print "Initiating ascent program".
	print "Executing roll and pitch maneuver".
	SAS OFF.
}

// Staging check
local function checkStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT and MAXTHRUST >= 0.1 {
			wait 1. 
			print "Dropping Boosters".
			stage.
			wait 1.
			return true.
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            set throttleControl to 0.
			wait 1. 
			print "Decoupling Stage".
			stage.
            wait 1.
			set throttleControl to 1.
			return true.
			break.
        }
    }
}

// Manually defined staging
local function stageNow {
	parameter setAltitude.
	when ALTITUDE > setAltitude then {
		stage.
	}
}

// Ascent loop
local function ascent {
	parameter orbitAlt, turnStart.
	until false {
		ascentProfile(turnStart).
		limitTWR().
		checkStaging().
		if altitudeTarget(orbitAlt) { break. }
		wait 0.001.
	}
}

// Ascent profile control
local function ascentProfile {	
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).	// ascent trajectory defined by equation
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).	// convert desired inclination into compass heading
}

// Altitude target for Ap
local function altitudeTarget {
	if APOAPSIS > orbitAlt {
		print "Apoapsis nominal".
		set throttleControl to 0.
		lock STEERING to PROGRADE.
		return true.
	}
}

// Throttle back feedback control loop
local function limitTWR {
	set pid_Asc:SETPOINT to 2. // TWR target for ascent
	if ALTITUDE < (BODY:ATM:HEIGHT * 0.4) {
		local engInfo to ActiveEngineInfo().
		set currentTWR to engInfo[0] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set maxTWR to engInfo[1] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set throttleAdjust to pid["Ascent"]:UPDATE(TIME:SECONDS, currentTWR).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
	}
	else set throttleControl to 1.
}

// Circularization burn calculations
local function circBurnCalc {
	local calcPeri is PERIAPSIS + SHIP:BODY:RADIUS.
	local calcApo is APOAPSIS + SHIP:BODY:RADIUS.
	local circDV is Sqrt(SHIP:BODY:MU / (calcApo)) * (1 - Sqrt(2 * calcPeri / (calcPeri + calcApo))). // Vis-viva equation
	local maxAccel is SHIP:MAXTHRUST / SHIP:MASS. 
	local circBurnTime is circDV / maxAccel.
	print "dV: " + circDV + " m/s".
	print "burn time: " + circBurnTime + " s".
	return circBurnTime.
}

// Circularization burn execution
local function circularize {
	parameter orbitAlt, orbitIncl.
	local burnDone is false.
	local burnTime is circBurnCalc().
	
	lock STEERING to heading(orbitIncl * -1 + 90, 0).	// convert desired inclination into compass heading
	wait until ETA:APOAPSIS < (burnTime / 2).		// begin circularization burn at half burn time before node
	
	if burnTime < 5 {
		set throttleControl to 0.5.
	}
	else set throttleControl to 1.
	
	until burnDone {
		CheckStaging().
		if APOAPSIS > (orbitAlt * 1.2)	{	// You probably will not space today...
			print "Malfunction detected".
			print "Aborting burn".
			SAS ON.
			lock THROTTLE to 0.
			set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
			set burnDone to true.
		}
		if PERIAPSIS > (orbitAlt * 0.99) {
			SAS ON.
			lock THROTTLE to 0.
			set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
			set burnDone to true.
			print "Orbital parameters achieved".
			print "Engine shutdown".
			print "Circularization program complete".
		}
		wait 0.001.
	}
}