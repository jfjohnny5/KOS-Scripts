// lib.maneuver.ks
// Function library for maneuver node execution
// John Fallara

// Library variables
declare local node.
declare local burnDuration.
declare local throttleControl.
declare local dv0.

global Maneuver is lexicon(
	"Query Node",		queryNode@,
	"Calc Burn",		calcBurn@,
	"Align to Node",	alignToNode@,
	"Preburn", 			preburn@,
	"Perform Burn",		performBurn@,
	"Post Burn",		postBurn@
).

local function queryNode {
	set node to NEXTNODE.
}

local function calcBurn {
	local maxAccel is SHIP:MAXTHRUST / SHIP:MASS.
	// TO DO: recalculate to utilize the Tsiolkovsky rocket equation
	set burnDuration to node:DELTAV:MAG / maxAccel.
	print "Node in: " + Round(node:ETA) + ", DeltaV: " + Round(node:DELTAV:MAG).
	print "Estimated burn duration: " + Round(burnDuration) + " s".
}

local function alignToNode {
	wait until node:ETA <= (burnDuration / 2 + 60).
	local nodePrograde is node:DELTAV.
	lock STEERING to nodePrograde.
	// check for alignment
	wait until Vang(nodePrograde, SHIP:FACING:VECTOR) < 0.25.
}

local function preburn {
	wait until node:ETA <= (burnDuration / 2).
	set throttleControl to 0.
	lock THROTTLE to throttleControl.
	//initial Delta V
	set dv0 to node:DELTAV.
}

local function performBurn {
	local burnDone is false.
	until burnDone	{
		// max accel changes as fuel is burned
		local maxAccel is SHIP:MAXTHRUST / SHIP:MASS.
		
		// feather throttle at < 1 second
		set throttleControl to Min(node:DELTAV:MAG / maxAccel, 1).
		
		// here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
		// this check is done via checking the dot product of those 2 vectors
		if Vdot(dv0, node:DELTAV) < 0
		{
			print "End burn, remain dv " + Round(node:DELTAV:MAG, 1) + "m/s, vdot: " + Round(vdot(dv0, node:DELTAV),1).
			lock THROTTLE to 0.
			break.
		}
		// finalizing the burn
		if node:DELTAV:MAG < 0.1
		{
			print "Finalizing burn, remain dv " + Round(node:DELTAV:MAG,1) + "m/s, vdot: " + Round(vdot(dv0, node:DELTAV),1).
			//we burn slowly until our node vector starts to drift significantly from initial vector
			//this usually means we are on point
			wait until Vdot(dv0, node:DELTAV) < 0.5.

			lock THROTTLE to 0.
			print "End burn, remain dv " + Round(node:DELTAV:MAG,1) + "m/s, vdot: " + Round(vdot(dv0, node:DELTAV),1).
			set burnDone to true.
		}
	}
}

local function postBurn {
	unlock STEERING.
	unlock THROTTLE.
	wait 1.

	remove node.

	set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
}