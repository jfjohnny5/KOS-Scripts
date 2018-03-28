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

{
	function launch {
		preflight().
		ignition().
		ascent().
		stageNow(68000).	// Manual staging to account for fairing separation
		wait until ALTITUDE > 68000.
		circularize().
		Notify("Launch program complete").
	}
	
	function transfer {
		if not HASNODE {
			Notify("Please define maneuver node", "alert").
			Notify("Transfer program aborted", "alert").
		}
		if HASNODE {
			SAS OFF.
			run node.burn.ks.
			SAS ON.
			Notify("Transfer program complete").
		}
	}
	
	function scienceCollection {
		
	}
	
	global mission is lexicon(
		"Launch", launch@,
		"Transfer", transfer@,
		"Science", scienceCollection@
	). 
}

function extendAntenna {
	print "Extending communication antenna".
	for p in SHIP:PARTSTAGGED("antenna") {
		set antenna to p:GETMODULE("ModuleDeployableAntenna").
		antenna:DOEVENT("extend antenna").
	}
}

mission[missionPhase]().