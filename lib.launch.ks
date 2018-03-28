// lib.launch.ks
// Function library for ascent and circularization into stable orbit
// John Fallara

// Initialize variables
set prevThrust to 0.
set throttleControl to 0.

{
	local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
	set pid_Asc:SETPOINT to 2. // TWR target for ascent
	global pid is lexicon("Ascent",pid_Asc).
}

function preflight {
	lock THROTTLE to throttleControl.
	calculateProfile().
	consoleLog().
	fairingCheck().
}

// Calculate ascent profile
function calculateProfile {
	global turnExponent is max(1 / (2.5 * launchTWR - 1.7), 0.25).
	global turnEnd is ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
}

// Echo flight path details to the terminal
function consoleLog {
	print "Desired orbital altitude:    " + orbitAlt + " m".
	print "Desired orbital inclination: " + orbitIncl + " deg".
	print "Launch TWR:                  " + launchTWR.
	print "Gravity turn start:          " + turnStart + " m".
	print "Ascent profile exponent:     " + turnExponent.
	print "Gravity turn end:            " + turnEnd + " m".
	print "Atmospheric height:          " + BODY:ATM:HEIGHT + " m".
}

// Fairing check
function fairingCheck {
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
function ignition {
	SAS ON.
	print "Main engine start".
	set throttleControl to 1.
	wait 0.5.
	Notify("LAUNCH").
	stage.

	wait until ALTITUDE > turnStart.
	print "Initiating ascent program".
	print "Executing roll and pitch maneuver".
	SAS OFF.
}

// Staging check
function CheckStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT and MAXTHRUST >= 0.1 {
			wait 1. 
			Notify("Dropping Boosters").
			stage.
			wait 1.
			return true.
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            lock THROTTLE to 0.
			wait 1. 
			Notify("Decoupling Stage").
			stage.
            wait 1.
			lock THROTTLE to 1.
			return true.
			break.
        }
    }
}

// Manually defined staging
function stageNow {
	parameter setAltitude.
	when ALTITUDE > setAltitude then {
		stage.
	}
}

// Ascent loop
function ascent {
	until false {
		ascentProfile().
		limitTWR().
		checkStaging().
		if altitudeTarget() { break. }
		wait 0.001.
	}
}

// Ascent profile control
function ascentProfile {	
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).	// ascent trajectory defined by equation
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).	// convert desired inclination into compass heading
}

// Altitude target for Ap
function altitudeTarget {
	if APOAPSIS > orbitAlt {
		print "Apoapsis nominal".
		set throttleControl to 0.
		lock STEERING to PROGRADE.
		return true.
	}
}

// Throttle back feedback control loop
function limitTWR {
	if ALTITUDE < (BODY:ATM:HEIGHT * 0.4) {
		local engInfo to ActiveEngineInfo().
		set currentTWR to engInfo[0] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set maxTWR to engInfo[1] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		if CheckStaging()	{
			pid["Ascent"]:reset().
		}
		set throttleAdjust to pid["Ascent"]:UPDATE(TIME:SECONDS, currentTWR).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
	}
	else set throttleControl to 1.
}

// Circularization burn calculations
function circBurnCalc {
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
function circularize {
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
			Notify("Malfunction detected", "alert").
			Notify("Aborting burn", "alert").
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
			Notify("Orbital parameters achieved").
			Notify("Engine shutdown").
			Notify("Circularization program complete").
		}
		wait 0.001.
	}
}