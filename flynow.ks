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
lock STEERING to UP.
lock THROTTLE to 1.
stage. wait 0.01.
wait until VERTICALSPEED < 0.
runExperiments().
stage.