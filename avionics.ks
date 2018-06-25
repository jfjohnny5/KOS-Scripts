// avionics.ks
// Basic ascent guidance system
local orbitAlt is 85000.
local orbitIncl is 0.
local launchTWR is 1.5.
local turnStart is 500.
//=======
local throttleControl is 0.
local prevThrust is 0.
local turnExponent is 0.
local turnEnd is 0.
local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
local dynPress is 0.
local function preflight {
	set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
	set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
	lock THROTTLE to throttleControl.
	SAS ON.
}
local function ascentGuidance {
	local mico is false.
	ignition().
	print "Guidance active".
	when ALTITUDE > turnStart then {
		print "Executing roll and pitch maneuver".
		SAS OFF.
	}
	when ALTITUDE > BODY:ATM:HEIGHT * 0.95 then RCS ON.
	when APOAPSIS >= orbitAlt then {
		print "Apoapsis nominal".
		set mico to true.
	}
	until false {
		if ALTITUDE > turnStart and APOAPSIS < orbitAlt and not mico {
			ascentProfile(orbitIncl, turnStart).
			limitTWR().
		}
		checkStaging().
		if APOAPSIS >= orbitAlt {
			set throttleControl to 0.
			SAS ON.
			unlock STEERING.
		}
		if ALTITUDE > BODY:ATM:HEIGHT break.
		wait 0.01.
	}
	print "Guidance deactivated".
}
local function activeEngineInfo {
	list ENGINES in eList.
	local currentT is 0.
	local maxT is 0.
	local mDot is 0.
	for e in eList {
		if e:IGNITION {
			set maxT to maxT + e:AVAILABLETHRUST.
			set currentT to currentT + e:THRUST.
			if not e:ISP = 0 set mDot to mDot + currentT / e:ISP.
		}.
	}.
	if mDot = 0 local avgISP is 0.
	else local avgISP is currentT / mDot.
	return list(currentT, maxT, avgISP, mDot).
}.
local function checkStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT and MAXTHRUST >= 0.1 {
			wait 1. print "Dropping Boosters".
			stage.
			wait 1. return true.
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            set throttleControl to 0.
			wait 1. print "Decoupling Stage".
			stage.
            wait 1. set throttleControl to 1.
			return true.
			break.
        }
    }
}
local function ignition {
	print "Main engine start".
	set throttleControl to 1.
	wait 0.01.
	stage.
}
local function ascentProfile {
	parameter orbitIncl, turnStart.
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).
}
local function limitTWR {
	set pid_Asc:SETPOINT to 4. 
	if ALTITUDE < (BODY:ATM:HEIGHT * 0.4) {
		local engInfo to activeEngineInfo().
		set currentTWR to engInfo[0] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set maxTWR to engInfo[1] / (SHIP:MASS * BODY:MU / (ALTITUDE + BODY:RADIUS)^2).
		set throttleAdjust to pid_Asc:UPDATE(TIME:SECONDS, currentTWR).
		set throttleControl to 1 + throttleAdjust.
		set prevThrust to MAXTHRUST.
	}
	else set throttleControl to 1.
}
preflight().
ascentGuidance().