// launch.ks
// John Fallara

// Initialization
// ==============
parameter orbitAlt is 75000.
parameter orbitIncl is 0.
run utility.
clearscreen.
// ==============

print "run ascent".
run launch.ascent.ks(orbitAlt, orbitIncl, 500, 0.283688, 53726).
print "ascent done".
lock STEERING to PROGRADE.
lock THROTTLE to 0.
print "run circularize".
run launch.circularize.ks(orbitAlt, orbitIncl).
print "circularize done".

Notify("Launch program complete").