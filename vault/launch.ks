// launch.ks
// General launch script
// John Fallara

run lib.utility.ks.
run lib.launch.ks.

// Initialization
// ==============
parameter orbitAlt is 75000.
parameter orbitIncl is 0.
parameter launchTWR is 1.5.
parameter turnStart is 500.
set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
set throttleControl to 0.
lock THROTTLE to throttleControl.

print "Desired orbital altitude:    " + orbitAlt + " m".
print "Desired orbital inclination: " + orbitIncl + " deg".
print "Launch TWR:                  " + launchTWR.
print "Gravity turn start:          " + turnStart + " m".
print "Ascent profile exponent:     " + turnExponent.
print "Gravity turn end:            " + turnEnd + " m".
print "Atmospheric height:          " + BODY:ATM:HEIGHT + " m".

// Main Sequence
fairingCheck().
ignition(turnStart).
until false {
	ascentControl(orbitIncl, turnStart, turnEnd, turnExponent).
	limitTWR().
	checkStaging().
	if altitudeTarget(orbitAlt) { break. }
	wait 0.001.
}
set burnTime to circBurnCalc().
circBurn(burnTime, orbitAlt, orbitIncl).
Notify("Launch program complete").