// lib.maneuver.ks
// Function library for maneuver node execution
// John Fallara

global Maneuver is lexicon(
	"Execute Maneuver",	executeManeuver@,
	"Circularize",		circularize@,
	"Calculate Circ",		calcCirc@
).

local function executeManeuver {
	performBurn().
	postBurn().
}
local function circularize {
	calcCirc().
	performBurn().
	postBurn().
}

local function maneuverTime {
	parameter dV.

	local f is 0.											// Engine Thrust (kg * m/s²)
	local m is SHIP:MASS * 1000.								// Starting mass (kg)
	local e is CONSTANT():E.									// Base of natural log
	local p is 0.											// Engine ISP (s)
	local g is SHIP:ORBIT:BODY:MU / (SHIP:ORBIT:BODY:RADIUS)^2.	// Gravitational acceleration constant (m/s²)

	local enCount is 0.
	list ENGINES in all_engines.
	
	for en in all_engines if en:IGNITION and not en:FLAMEOUT {
		set f to f + en:AVAILABLETHRUST.
		set p to p + en:ISP.
		set enCount to enCount + 1.
	}
	set p to p / enCount.
	set f to f * 1000.
	return g * m * p * (1 - e^(-dV / (g * p))) / f.
}

local function performBurn {
	parameter autowarp is false.
	parameter node is NEXTNODE.
	parameter dV0 is node:DELTAV.
	parameter t0 is TIME:SECONDS + node:ETA - maneuverTime(dV0:MAG) / 2.
	
	print "Node in: " + Round(node:ETA) + ", DeltaV: " + Round(node:DELTAV:MAG).
	lock STEERING to node:DELTAV.
	if autowarp warpto(t0 - 30).
	wait until TIME:SECONDS >= t0.
	local throttleControl is 0.
	lock THROTTLE to throttleControl.
	until vdot(node:DELTAV, dV0) < 0.01 {
		set throttleControl to min(maneuverTime(node:DELTAV:MAG), 1).	// feather the throttle when < 1 second
		wait 0.1.
	}
	lock THROTTLE to 0.
	unlock STEERING.
	remove NEXTNODE.
	wait 0.
}

local function postBurn {
	SAS ON.
	unlock THROTTLE.
	wait 1.

	set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
}

local function calcCirc {
	local vAp is sqrt(BODY:MU * ((2 / (SHIP:ORBIT:APOAPSIS + BODY:RADIUS)) - (1 / SHIP:ORBIT:SEMIMAJORAXIS))).
	local vTarget is sqrt(BODY:MU / (SHIP:ORBIT:APOAPSIS + BODY:RADIUS)).
	local dV is vTarget - vAp.
	add node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dV).
}