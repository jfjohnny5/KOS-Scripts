// simpleOrbit.ks
// Launch ascent and guidance only.
// John Fallara

// Mission Parameters
// ------------------
parameter missionPhase.
local orbitAlt is 85000.
local orbitIncl is 0.
local launchTWR is 2.25.
local turnStart is 500.
// ------------------

// Initialization
runoncepath("lib.utility.ks").
runoncepath("lib.launch.ks").
runoncepath("lib.maneuver.ks").
runoncepath("lib.science.ks").
runoncepath("lib.descent.ks").

local Mission is lexicon(
	"Launch",	launchPhase@
). 

local function launchPhase {
	print "Initiating 'Launch' program".
	Utility["Countdown"]().
	Launch["Preflight"](orbitAlt, orbitIncl, launchTWR, turnStart).
	Launch["Ascent"](orbitAlt, orbitIncl, turnStart).
	Maneuver["Circularize"]().
	Utility["Notify"]("Launch program complete").
}

// Access to run mission phases
Mission[missionPhase]().