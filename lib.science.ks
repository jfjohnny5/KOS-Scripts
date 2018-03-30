// lib.science.ks
// Function library for science collection and transmission
// John Fallara

global Science is lexicon(
	"Run Experiments",		runExperiments@,
	"Reset Experiments",		resetExperiments@,
	"Transmit Science",		transmitScience@
).

local function queryExperiments {
	local experiments is list().
	for p in SHIP:PARTS {
		for m in p:MODULES {
			if m = "ModuleScienceExperiment" experiments:ADD(p).
		}
	}
	return experiments.
}

local function runExperiments {
	for e in queryExperiments() {
		set m to e:GETMODULE("ModuleScienceExperiment").
		m:DEPLOY.
		wait 1.
	}
}

local function resetExperiments {
	for e in queryExperiments() {
		set m to e:GETMODULE("ModuleScienceExperiment").
		m:RESET.
		wait 1.
	}
}

local function transmitScience {
	for e in queryExperiments() {
		set m to e:GETMODULE("ModuleScienceExperiment").
		if m:HASDATA {
			m:TRANSMIT.
		}
		wait 1.
	}
}