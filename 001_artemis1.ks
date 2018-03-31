// 001_artemis1.ks
// Artemis I mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 75000.
local orbitIncl is 0.
local launchTWR is 1.41.
local turnStart is 500.
// ------------------

// Initialization
runoncepath("lib.utility.ks").
runoncepath("lib.launch.ks").
runoncepath("lib.maneuver.ks").
runoncepath("lib.science.ks").

local Mission is lexicon(
	"Launch",	launchPhase@
). 

local function launchPhase {
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Launch["Ignition"](turnStart).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Notify"]("Launch program complete").
	Science["Run Experiments"]().
	Science["Transmit Science"]().
}

// Access to run mission phases
Mission[missionPhase]().