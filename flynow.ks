local throttleControl is 0.
lock THROTTLE to throttleControl.
local pid is PIDLoop(0.175, 0.66, 0, -1, 0).

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
local function limitVelocity {
	parameter vLimit.
	set pid:SETPOINT to vLimit.
	set throttleAdjust to pid:UPDATE(TIME:SECONDS, VELOCITY:SURFACE:MAG).
	set throttleControl to 1 + throttleAdjust.
}
set testDone to false.
lock STEERING to UP.
set throttleControl to 1.
stage. wait 0.01.	// launch
when ALTITUDE > 35000 and VELOCITY:SURFACE:MAG > 420 then {
	stage.	// initiate test
	set throttleControl to 0.
	set testDone to true.
	wait 0.01.
}
until testDone {
	limitVelocity(500).
	wait 0.01.
}
wait until VERTICALSPEED < 0.
stage.	// parachute arm