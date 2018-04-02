// 005_muna2.ks
// Muna II mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 100000.
local orbitIncl is 0.
local launchTWR is 1.88.
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
	"Transfer",	transferPhase@,
	"Science",	sciencePhase@,
	"Deorbit",	deorbitPhase@
). 

local function launchPhase {
	print "Initiating 'Launch' program".
	Utility["Countdown"]().
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Stage Now"]().	// force staging of lifter
	Utility["Notify"]("Launch program complete").
}

local function transferPhase {
	print "Initiating 'Transfer' program".
	Maneuver["Execute Maneuver"]().
	set STEERING to HEADING(10,10).	// orient solar panels
	Utility["Notify"]("Transfer program complete").
}

local function sciencePhase {
	print "Initiating 'Science' program".
	Science["Run Experiments"]().
	Science["Transmit Science"]().
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