// launch.ascent.ks
// John Fallara
//
// Automated ascent guidance using following profile.
// MAX(90-(((ALTITUDE-turnStart)/(turnEnd-turnStart))^turnExponent*90),0)

// Initialization
// ==============
parameter orbitAlt is 72000.
parameter orbitIncl is 0. // inclination of orbit - 0 inclination (East) by default
parameter turnStart is 500.
parameter turnExponent is 0.6.
parameter turnEnd is 50000.
parameter forceStage is false. // if using a simple 2-stage rocket, and the main booster should/shouldn't be used after ascent
run utility.lib.ks.
set ascentComplete to false.
set atmoHeight to SHIP:BODY:ATM:HEIGHT.
set prevThrust to 0.
set pid to PIDLoop(0.175, 0.66, 0, -0.5, 0).
set pid:SETPOINT to 2. // TWR target for ascent
set hasFairing to false.

// Preflight
// ==============
for p in SHIP:PARTSTAGGED("fairing") {
	set fairing to p:GETMODULE("ModuleProceduralFairing").
	set hasFairing to true.
}
if hasFairing {
	when ALTITUDE > BODY:ATM:HEIGHT * 0.9 then {
		fairing:DOEVENT("deploy").
	}
}

// main program
// ==============
SAS ON.
print "Main engine start".
set throttleControl to 1.
lock THROTTLE to throttleControl.
wait 0.5.
Notify("LAUNCH").
stage.

wait until ALTITUDE > turnStart.
print "Initiating ascent program".
print "Executing roll and pitch maneuver".
SAS OFF.

// ascent program
until ascentComplete {
	// lock steering to ascent profile
	set steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).	// ascent trajectory defined by equation
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).	// convert desired inclination into compass heading
		
	// limit thrust in thickest part of atmosphere
	if ALTITUDE < (atmoHeight * 0.4) {
		set engInfo to ActiveEngineInfo().
		set currentTWR to engInfo[0] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set maxTWR to engInfo[1] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		if CheckStaging()	{
			pid:reset().
		}
		set throttleAdjust to pid:UPDATE(TIME:SECONDS, currentTWR).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
	}
	else {
		set throttleControl to 1.
		CheckStaging().
	}
	
	// check if target Ap on current trajectory
	when APOAPSIS > orbitAlt then {
		print "Apoapsis nominal".
		set throttleControl to 0.
		lock STEERING to PROGRADE.
		set ascentComplete to true.
		if forceStage {
			wait until STAGE:READY
			stage.
			Notify("Decoupling stage").
		}
	}
	wait 0.001.
}
unlock THROTTLE.
unlock STEERING.
Notify("Ascent program complete").