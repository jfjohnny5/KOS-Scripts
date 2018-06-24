// bridge.ks
// Bridge Program generic mission profile.
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

local Mission is lexicon(
	"Launch",	launchPhase@
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

// Access to run mission phases
Mission[missionPhase]().