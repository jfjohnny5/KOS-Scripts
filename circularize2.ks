// derivation of the vis-viva equation to solve for v.
// v = sqrt(u * ((2 / r) - (1 / a)))
//
// v = orbital velocity
// u = "mu" gravitaional constant
// r = distance between the two orbiting bodies (remember that technically every orbit is two bodies around each other)
// a = length of semi-major axis (half the length of the long axis of the ellipse)

clearscreen.

local targetVel is sqrt(BODY:MU / (BODY:RADIUS + SHIP:ORBIT:APOAPSIS)).
local div1 is (1 - SHIP:ORBIT:ECCENTRICITY) * BODY:MU.
local div2 is (1 + SHIP:ORBIT:ECCENTRICITY) * SHIP:ORBIT:SEMIMAJORAXIS.
local div is div1 / div2.
local velAp is sqrt(div).
local dv is targetV - velAp.
local mynode is node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dv).

add mynode.

print "Velocity at Ap:  " + velAp. 
print "Target Velocity: " + targetVel.
print "Delta-V:         " + dV.
print "div1:            " + div1.
print "div2:            " + div2.
print "div:             " + div.