// exampleMission.ks
// Example mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 250000.
local orbitIncl is 0.
//local launchTWR is 1.61.
local turnStart is 500.
// ------------------

// Initialization
runoncepath("lib.utility.ks").
runoncepath("lib.launch.ks").
runoncepath("lib.maneuver.ks").

local Mission is lexicon(
	"Launch",	launchPhase@,
	"Execute Maneuver", executeManeuver@
). 

local function launchPhase {
	Launch["Preflight"](orbitAlt, orbitIncl, turnStart).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Notify"]("Launch program complete").
}

local function executeManeuver {
	Maneuver["Execute Maneuver"]().
}

// Access to run mission phases
Mission[missionPhase]().