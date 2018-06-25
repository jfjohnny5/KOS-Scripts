// muna1.ks
// Muna I mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 75000.
local orbitIncl is 0.
local launchTWR is 1.42.
local turnStart is 500.
local targetBody is "Mun".
// ------------------

// Initialization
clearscreen.
runoncepath("lib.utility.ks").
runoncepath("lib.launch.ks").
runoncepath("lib.maneuver.ks").
runoncepath("lib.science.ks").

// ===============================================================
// To initiate phase, type 'run muna1(PHASE).' in the kOS terminal
// ===============================================================
local Mission is lexicon(
	"Launch",	launchPhase@,
	"Transfer",	transferPhase@,
	"Science",	scienceCollectionPhase@
). 

local function launchPhase {
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Launch["Ignition"](turnStart).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Launch["Stage Now"](68000).	// Manual staging to account for fairing separation
	wait until ALTITUDE > 68000.
	Maneuver["Circularize"]().
	Maneuver["Execute Maneuver"]().
	Utility["Notify"]("Launch program complete").
}

local function transferPhase {
	if not HASNODE {
		Utility["Notify"]("Please define maneuver node", "alert").
		Utility["Notify"]("Transfer program aborted", "alert").
	}
	if HASNODE {
		SAS OFF.
		Maneuver["Execute Maneuver"]().
		Utility["Notify"]("Transfer program complete").
	}
}

local function scienceCollectionPhase {
	if Utility["Query SOI"](targetBody) {
		Science["Run Experiments"]().
		Science["Transmit Science"]().
	}
	else Utility["Notify"]("Science parameters not met","alert").
}

// Access to run mission phases
Mission[missionPhase]().