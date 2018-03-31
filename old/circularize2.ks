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

// Circularization burn calculations
local function circBurnCalc {
	local calcPeri is PERIAPSIS + SHIP:BODY:RADIUS.
	local calcApo is APOAPSIS + SHIP:BODY:RADIUS.
	local circDV is sqrt(SHIP:BODY:MU / calcApo) * (1 - sqrt(2 * calcPeri / (calcPeri + calcApo))). // Vis-viva equation (?)
	local maxAccel is SHIP:MAXTHRUST / SHIP:MASS. 
	local circBurnTime is circDV / maxAccel.
	print "dV: " + circDV + " m/s".
	print "burn time: " + circBurnTime + " s".
	return circBurnTime.
}

// Circularization burn execution
local function circularize {
	parameter orbitAlt, orbitIncl.
	local burnDone is false.
	local burnTime is circBurnCalc().
	
	lock STEERING to heading(orbitIncl * -1 + 90, 0).	// convert desired inclination into compass heading
	wait until ETA:APOAPSIS < (burnTime / 2).		// begin circularization burn at half burn time before node
	
	if burnTime < 5 {
		set throttleControl to 0.5.
	}
	else set throttleControl to 1.
	
	until burnDone {
		CheckStaging().
		if APOAPSIS > (orbitAlt * 1.2)	{	// You probably will not space today...
			Utility["Notify"]("Malfunction detected", "alert").
			Utility["Notify"]("Aborting burn", "alert").
			SAS ON.
			lock THROTTLE to 0.
			set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
			set burnDone to true.
		}
		if PERIAPSIS > (orbitAlt * 0.99) {
			SAS ON.
			lock THROTTLE to 0.
			set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
			set burnDone to true.
			print "Orbital parameters achieved".
			print "Engine shutdown".
			print "Circularization program complete".
		}
		wait 0.001.
	}
}