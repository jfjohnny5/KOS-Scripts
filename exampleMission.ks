// exampleMission.ks
// Example mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 75000.
local orbitIncl is 0.
local launchTWR is 1.5.
local turnStart is 500.
// ------------------

// Initialization
runoncepath("lib.utility.ks").
runoncepath("lib.launch.ks").
runoncepath("lib.maneuver.ks").

local Mission is lexicon(
	"Launch",	launchPhase@,
    "Phase 2",  phase2@
). 

local function launchPhase {
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Launch["Ignition"](turnStart).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Notify"]("Launch program complete").
}

local function phase2 {
    print "Phase 2 launched!".
}

// Access to run mission phases
Mission[missionPhase]().