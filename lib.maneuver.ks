// lib.maneuver.ks
// Function library for maneuver node execution
// John Fallara

// Initialization
runoncepath("lib.utility.ks").

global Maneuver is lexicon(
	"Execute Maneuver",	executeManeuver@,
	"Circularize",		circularize@,
	"Deorbit",			deorbit@
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

local function deorbit {
	calcDeorbit().
	performBurn().
	postBurn().
}

// Calculate and return Δt for given amount of Δv based on all currently active engines
local function maneuverTime {
	parameter dV.

	local f is 0.												// Engine Thrust (kg * m/s²)
	local m is SHIP:MASS * 1000.								// Starting mass (kg)
	local e is CONSTANT():E.									// Base of natural log
	local p is 0.												// Engine ISP (s)
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

// Automatically align to and execute burn for next maneuver node
local function performBurn {
	parameter autowarp is true.
	parameter mvrNode is NEXTNODE.
	parameter dV0 is mvrNode:DELTAV.
	parameter t0 is TIME:SECONDS + mvrNode:ETA - maneuverTime(dV0:MAG) / 2.
	local steerControl is mvrNode:DELTAV.
	
	print "Node in: " + round(mvrNode:ETA) + " s, DeltaV: " + round(mvrNode:DELTAV:MAG) + " m/s".
	SAS OFF.
	lock STEERING to steerControl.
	if autowarp warpto(t0 - 30).
	when vang(mvrNode:DELTAV, SHIP:FACING:FOREVECTOR) < 1 then {
		print "Steering locked to current heading".
		// stop ship from "chasing" the maneuver vector
		set steerControl to SHIP:FACING:VECTOR.
	}
	wait until TIME:SECONDS >= t0.
	local throttleControl is 0.
	lock THROTTLE to throttleControl.
	until vdot(mvrNode:DELTAV, dV0) < 0.01 {
		Utility["Check Staging"]().
		// feather the throttle when < 1s
		set throttleControl to min(maneuverTime(mvrNode:DELTAV:MAG), 1).
		wait 0.1.
	}
	lock THROTTLE to 0.
	wait 0.
}

// Remove node just executed and return flight control to pilot
local function postBurn {
	remove NEXTNODE.
	SAS ON.
	unlock STEERING.
	unlock THROTTLE.
	wait 0.1.
	set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
}

local function calcCirc {
	local r is SHIP:ORBIT:APOAPSIS + BODY:RADIUS.
	local vAp is sqrt(BODY:MU * ((2 / r) - (1 / SHIP:ORBIT:SEMIMAJORAXIS))).
	local vTarget is sqrt(BODY:MU / r).
	local dV is vTarget - vAp.
	add node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dV).
}

local function calcDeorbit {
	local r is SHIP:ORBIT:APOAPSIS + BODY:RADIUS.
	local vAp is sqrt(BODY:MU * ((2 / r) - (1 / SHIP:ORBIT:SEMIMAJORAXIS))).
	local a is ((SHIP:ORBIT:APOAPSIS + BODY:RADIUS) + (BODY:RADIUS + BODY:ATM:HEIGHT * 0.5)) / 2.
	local vTarget is sqrt(BODY:MU * ((2 / r) - (1 / a))).
	local dV is vTarget - vAp.
	add node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dV).
}