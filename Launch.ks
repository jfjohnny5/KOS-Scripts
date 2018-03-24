// launch.ks
// John Fallara

parameter orbitAp is 75000.
parameter orbitPe is 70250.

// helper function
function Notify {
	parameter message.
	HUDTEXT("kOS: " + message, 5, 2, 25, GREEN, true).
}

clearscreen.

print "run ascent".
run launch.ascent.ks(orbitAp, 500, 0.533, 47810).
print "ascent done".
lock STEERING to PROGRADE.
lock THROTTLE to 0.
print "run circularize".
run launch.circularize.ks(orbitPe).
print "circularize done".

Notify("Launch program complete").