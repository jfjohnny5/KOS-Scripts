// 003_artemis1.ks
// Artemis III mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 85000.
local orbitIncl is 0.
local launchTWR is 1.44.
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
	"Science",	sciencePhase@,
	"Deorbit",	deorbitPhase@
). 

local function launchPhase {
	print "Initiating 'Launch' program".
	Utility["Countdown"]().
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Utility["Stage At"](68000). // Lifter not fully expended during launch
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Notify"]("Launch program complete").
}

local function sciencePhase {
	print "Initiating 'Science' program".
	Science["Run Experiments"]().
	Utility["Notify"]("Science program complete").
}

local function deorbitPhase {
	print "Initiating 'Deorbit' program".
	Maneuver["Deorbit"]().
	Descent["Unpowered Descent"]().
	Utility["Notify"]("Deorbit program complete").
}

// Access to run mission phases
Mission[missionPhase]().