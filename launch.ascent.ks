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
// ==============

// main program
// ==============
SAS ON.
Notify("Main engine start").
set throttleControl to 1.
lock THROTTLE to throttleControl.
wait 0.5.
Notify("LAUNCH").
stage.

wait until ALTITUDE > turnStart.
Notify("Initiating ascent program").
Notify("Executing roll and pitch maneuver").
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
		print "TWR: " + currentTWR + " / " + maxTWR at (0, 16).
		print "P:   " + pid:PTERM at (0,17).
		print "I:   " + pid:ITERM at (0,18).
		print "D:   " + pid:DTERM at (0,19).
		print "out: " + throttleAdjust at (0, 20).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
		wait 0.01.
	}
	else {
		lock THROTTLE to 1.
		CheckStaging().
	}
	
	// check if target Ap on current trajectory
	if APOAPSIS > orbitAlt {
		lock THROTTLE to 0.
		lock STEERING to PROGRADE.
		set ascentComplete to true.
		if forceStage {
			wait 2.
			stage.
			Notify("Decoupling stage").
		}
	}
}
unlock THROTTLE.
unlock STEERING.
Notify("Ascent program complete").