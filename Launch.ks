// launch.ks
// John Fallara

// Initialization
// ==============
parameter orbitAlt is 75000.
parameter orbitIncl is 0.
parameter launchTWR is 1.5.
parameter turnStart is 500.
parameter forceDropLifter is false.
set atmoHeight to BODY:ATM.
set turnEnd to ((0.128 * atmoHeight * launchTWR) + (0.5 * atmoHeight)).
set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
run utility.lib.ks.
clearscreen.
// ==============

print "Desired orbital altitude:    " + orbitAlt + " m".
print "Desired orbital inclination: " + orbitIncl + " deg".
print "Launch TWR:                  " + launchTWR.
print "Gravity turn start:          " + turnStart + " m".
print "Ascent profile exponent:     " + turnExponent.
print "Gravity turn end:            " + turnEnd + " m".
print "Current atmospheric height:  " + atmoHeight + " m".
print "Force drop lifter stage?:    " + forceDropLifter.

run launch.ascent.ks(orbitAlt, orbitIncl, turnStart, turnExponent, turnEnd, forceDropLifter).
lock STEERING to PROGRADE.
lock THROTTLE to 0.
run launch.circularize.ks(orbitAlt, orbitIncl). // (Orbital ALtitude, Orbital Inclination)

Notify("Launch program complete").