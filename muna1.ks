// muna1.ks
// Muna I mission profile.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase is "Launch".
global orbitAlt is 75000.
global orbitIncl is 0.
global launchTWR is 1.42.
global turnStart is 500.
global targetBody is "Mun".
// ------------------

// Initialization
clearscreen.
run lib.utility.ks.
run lib.launch.ks.
run lib.maneuver.ks.
run lib.science.ks.

// ===============================================================
// To initiate phase, type 'run muna1(PHASE).' in the kOS terminal
// ===============================================================
local Mission is lexicon(
	"Launch",	launchPhase@,
	"Transfer",	transferPhase@,
	"Science",	scienceCollectionPhase@
). 

local function launchPhase {
	Launch["Preflight"]().
	Launch["Ignition"]().
	Launch["Ascent"]().
	Launch["Stage Now"](68000).	// Manual staging to account for fairing separation
	wait until ALTITUDE > 68000.
	Launch["Circularize"]().
	Utility["Notify"]("Launch program complete").
}

local function transferPhase {
	if not HASNODE {
		Utility["Notify"]("Please define maneuver node", "alert").
		Utility["Notify"]("Transfer program aborted", "alert").
	}
	if HASNODE {
		SAS OFF.
		Maneuver["Query Node"]().
		Maneuver["Calc Burn"]().
		Maneuver["Align to Node"]().
		Maneuver["Preburn"]().
		Maneuver["Perform Burn"]().
		Maneuver["Post Burn"]().
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