// node.burn.ks
// John Fallara
//
// based on "Execute Node Script" from KOS documentation

// execution of the burn to complete the next maneuver node along current trajectory

// Initialization
// ==============
run utility.
// ==============

// main program
set node to NEXTNODE.

print "Node in: " + round(node:ETA) + ", DeltaV: " + round(node:DELTAV:MAG).

set maxAccel to SHIP:MAXTHRUST / SHIP:MASS.

// very simplified calculation
// TO DO: recalculate to utilize the Tsiolkovsky rocket equation
set burnDuration to node:DELTAV:MAG / maxAccel.
print "Estimated burn duration: " + round(burnDuration) + " s".

// allow time (60 s) for spacecraft to rotate into position
wait until node:ETA <= (burnDuration / 2 + 60).
set nodePrograde to node:DELTAV.
lock STEERING to nodePrograde.

wait until vang(nodePrograde, SHIP:FACING:VECTOR) < 0.25.	// TO DO: lookup VANG function

wait until node:ETA <= (burnDuration / 2).

// BEST PRACTICE: LOCK the THROTTLE to a variable, then SET the variable
set tset to 0.
lock THROTTLE to tset.

set burnDone to false.
//initial Delta V
set dv0 to node:DELTAV.

until burnDone	{
	// max acceleration changes as fuel is burned, and spacecraft loses mass
	set maxAccel to SHIP:MAXTHRUST / SHIP:MASS.
	
	// throttle at 100% for max efficiency until less than 1 second left
	// feather throttle linearly if less than 1 second
	set tset to min(node:DELTAV:MAG / maxAccel, 1).
	
	// here's the tricky part, we need to cut the throttle as soon as our nd:deltav and initial deltav start facing opposite directions
    // this check is done via checking the dot product of those 2 vectors
    if vdot(dv0, node:DELTAV) < 0
    {
        print "End burn, remain dv " + round(node:DELTAV:MAG, 1) + "m/s, vdot: " + round(vdot(dv0, node:DELTAV),1).
        lock THROTTLE to 0.
        break.
    }
	// finalizing the burn
    if node:DELTAV:MAG < 0.1
    {
        print "Finalizing burn, remain dv " + round(node:DELTAV:MAG,1) + "m/s, vdot: " + round(vdot(dv0, node:DELTAV),1).
        //we burn slowly until our node vector starts to drift significantly from initial vector
        //this usually means we are on point
        wait until vdot(dv0, node:DELTAV) < 0.5.

        lock THROTTLE to 0.
        print "End burn, remain dv " + round(node:DELTAV:MAG,1) + "m/s, vdot: " + round(vdot(dv0, node:DELTAV),1).
        set burnDone to true.
    }
}

unlock STEERING.
unlock THROTTLE.
wait 1.

remove node.

set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.