// 001_artemis1.ks
// Artemis I mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 77000.
local orbitIncl is 0.
local launchTWR is 1.47.
local turnStart is 500.
// ------------------

// Initialization
runoncepath("lib.utility.ks").
runoncepath("lib.launch.ks").
runoncepath("lib.maneuver.ks").
runoncepath("lib.science.ks").
runoncepath("lib.descent.ks").

local Mission is lexicon(
	"Launch",	launchPhase@,
	"Deorbit",	deorbitPhase@
). 

local function launchPhase {
	print "Initiating 'Launch' program".
	Utility["Countdown"]().
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Utility["Stage At"](67000).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Notify"]("Launch program complete").
}

local function deorbitPhase {
	print "Initiating 'Deorbit' program".
	Maneuver["Deorbit"]().
	Descent["Unpowered Descent"]().
}

// Access to run mission phases
Mission[missionPhase]().