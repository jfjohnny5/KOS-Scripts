// launch.circularize.ks
// John Fallara
//
// Circularize around a body at a given altitude.

// Initialization
// ==============
parameter orbitAlt is 72000.
parameter orbitIncl is 0. // inclination of orbit - East (0 inclination) by default
run utility.lib.ks.
set burnDone to false.
// ==============

// main program
// ==============	
Notify("Initiating circularization program").
// calculate deltaV requirement
set calcPeri to PERIAPSIS + SHIP:BODY:RADIUS.
set calcApo to APOAPSIS + SHIP:BODY:RADIUS.
set circDV to sqrt(SHIP:BODY:MU / (calcApo)) * (1 - sqrt(2 * calcPeri / (calcPeri + calcApo))). // Vis-viva equation
set maxAccel to SHIP:MAXTHRUST / SHIP:MASS. 
set circBurnTime to circDV / maxAccel.
print "dV: " + circDV + " m/s".
print "burn time: " + circBurnTime + " s".

// reorient to burn vector
wait until ETA:APOAPSIS < (circBurnTime / 2 + 60).
lock STEERING to HEADING(orbitIncl * -1 + 90, 0).	// convert desired inclination into compass heading

// begin circularization burn at half burn time before node
wait until ETA:APOAPSIS < (circBurnTime / 2).

// circularization burn
Notify ("Executing circularization burn").
if circBurnTime < 5 {
	lock THROTTLE to 0.5.
}
else lock THROTTLE to 1.
until burnDone {
	CheckStaging().
	if APOAPSIS > (orbitAlt * 1.1)	{
		Notify("Malfunction detected").
		Notify("Aborting burn").
		SAS ON.
		lock THROTTLE to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		set burnDone to true.
	}
	if PERIAPSIS > orbitAlt {
		SAS ON.
		lock THROTTLE to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		set burnDone to true.
		Notify("Orbital parameters achieved").
		Notify("Engine shutdown").
		Notify("Circularization program complete").
	}
}