// derivation of the vis-viva equation to solve for v.
// v = sqrt(u * ((2 / r) - (1 / a)))
//
// v = orbital velocity
// u = "mu" gravitaional constant
// r = distance between the two orbiting bodies (remember that technically every orbit is two bodies around each other)
// a = length of semi-major axis (half the length of the long axis of the ellipse)
// 
// In a circular orbit, r = a, to so the equation can be simplified to:
// v = sqrt(u / a).

clearscreen.

local function johnSolution {

	local vAp is sqrt(BODY:MU * ((2 / (SHIP:ORBIT:APOAPSIS + BODY:RADIUS)) - (1 / SHIP:ORBIT:SEMIMAJORAXIS))).
	local vTarget is sqrt(BODY:MU / (SHIP:ORBIT:APOAPSIS + BODY:RADIUS)).
	local dV is vTarget - vAp.
	add node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dV).
	
	print "Velocity at Ap:  " + vAp. 
	print "Target Velocity: " + vTarget.
	print "Delta-V:         " + dV.

}

johnSolution().