// muna1.ks
// Muna I mission profile.
// John Fallara

// Initialization
// ==============
run lib.utility.ks.
run lib.launch.ks.
parameter orbitAlt is 75000.
parameter orbitIncl is 0.
parameter launchTWR is 1.5.
parameter turnStart is 500.
set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
set throttleControl to 0.
lock THROTTLE to throttleControl.

// Launch & Circularize
// ==============
print "Desired orbital altitude:    " + orbitAlt + " m".
print "Desired orbital inclination: " + orbitIncl + " deg".
print "Launch TWR:                  " + launchTWR.
print "Gravity turn start:          " + turnStart + " m".
print "Ascent profile exponent:     " + turnExponent.
print "Gravity turn end:            " + turnEnd + " m".
print "Atmospheric height:          " + BODY:ATM:HEIGHT + " m".

// Main Sequence
fairingCheck().
ignition(turnStart).
until false {
	ascentControl(orbitIncl, turnStart, turnEnd, turnExponent).
	limitTWR().
	checkStaging().
	if altitudeTarget(orbitAlt) { break. }
	wait 0.001.
}
stageNow(68000).	// Manual staging to account for fairing separation
wait until ALTITUDE > 68000.
set burnTime to circBurnCalc().
circBurn(burnTime, orbitAlt, orbitIncl).
Notify("Launch program complete").

// Post launch task list
// ==============
wait 30.
print "Extending communication antenna".
for p in SHIP:PARTSTAGGED("antenna") {
		set antenna to p:GETMODULE("ModuleDeployableAntenna").
		antenna:DOEVENT("extend antenna").
	}
wait 10.
print "Aligning solar panels for charging".

// Munar transfer
// ==============
until false {
	if not HASNODE {
		print "Pausing execution for 10 minutes".
		print "Please create maneuver node". 
		wait 600.
	}
	else break.
}
run node.burn.ks.

// Detect Mun SOI
// ==============


// Run Science
// ==============


// Transmit Science
// ==============