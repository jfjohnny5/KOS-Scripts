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
// ==============

// main program
// ==============
SAS ON.
Notify("Main engine start").
set THROTTLE to 1.
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
	set steerPitch to max(90-(((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90),0).	// ascent trajectory defined by equation
	lock STEERING to HEADING(orbitIncl * -1 + 90, steerPitch).	// convert desired inclination into compass heading
	if 

	CheckStaging().
	
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