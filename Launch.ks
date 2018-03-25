// launch.ks
// John Fallara

// Initialization
// ==============
parameter orbitAlt is 75000.
parameter orbitIncl is 0.
run utility.lib.ks.
clearscreen.
// ==============

run launch.ascent.ks(orbitAlt, orbitIncl, 500, 0.487805, 48440, false). // (Orbital ALtitude, Orbital Inclination, Gravity Turn Start, Turn Exponent, Gravity Turn End, Force Drop Lifter)
lock STEERING to PROGRADE.
lock THROTTLE to 0.
run launch.circularize.ks(orbitAlt, orbitIncl). // (Orbital ALtitude, Orbital Inclination)

Notify("Launch program complete").