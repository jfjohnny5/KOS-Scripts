// Mission Parameters
// ------------------
local orbitAlt is 85000.
local orbitIncl is 0.
local launchTWR is 2.25.
local turnStart is 500.
// ------------------

local throttleControl is 0.
local prevThrust is 0.
local turnExponent is 0.
local turnEnd is 0.
local pid_Asc is PIDLoop(0.175, 0.66, 0, -0.5, 0).
local dynPress is 0.

local function ignition {
	print "Main engine start".
	set throttleControl to 1.
	wait 0.01. print "=== LAUNCH ===".
	stage.
}

local function ascentProfile {
	parameter orbitIncl, turnStart.
	// ascent trajectory defined by equation
	local steerPitch to max(90 - (((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90), 0).
	lock STEERING to heading(orbitIncl * -1 + 90, steerPitch).
}

local function maxQ {
	local lastPress is dynPress.
	set dynPress to SHIP:DYNAMICPRESSURE.
	when dynPress < lastPress then {
		print "Passing max Q".
		print "All systems nominal".
	}
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

// Throttle down feedback control loop
local function limitTWR {
	set pid_Asc:SETPOINT to 4. // TWR upper limit for ascent
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

// Calculations for guidance, logging, initial control set
local function preflight {
	parameter orbitAlt, orbitIncl, launchTWR, turnStart.
	set turnExponent to max(1 / (2.5 * launchTWR - 1.7), 0.25).
	set turnEnd to ((0.128 * BODY:ATM:HEIGHT * launchTWR) + (0.5 * BODY:ATM:HEIGHT)).
	lock THROTTLE to throttleControl.
	SAS ON.
}

// Guidance control from launch to crossing Atmo height line
local function ascentGuidance {
	parameter orbitAlt, orbitIncl, turnStart.
	local loopCnt is 0.
	ignition().
	print "Guidance system active".
	when ALTITUDE > turnStart then {
		print "Executing roll and pitch maneuver".
		SAS OFF.
	}
	when ALTITUDE > BODY:ATM:HEIGHT * 0.95 then RCS ON.
	when APOAPSIS >= orbitAlt then {
		print "Apoapsis nominal".
		if ALTITUDE < BODY:ATM:HEIGHT print "Coasting until " + BODY:ATM:HEIGHT + " m".
	}
	until false {
		if ALTITUDE > turnStart and APOAPSIS < orbitAlt {
			ascentProfile(orbitIncl, turnStart).
			limitTWR().
		}
		//Utility["Check Staging"]().
		if APOAPSIS >= orbitAlt {
			set throttleControl to 0.
			lock STEERING to PROGRADE.
            break. // ONLY FOR BASIC AVIONICS
		}
		if ALTITUDE > BODY:ATM:HEIGHT break.
		set loopCnt to loopCnt + 1.
		wait 0.01.
	}
	print "Guidance system deactivated".
}

	print "Initiating 'Launch' program".
	preflight(orbitAlt, orbitIncl, launchTWR, turnStart).
	ascentGuidance(orbitAlt, orbitIncl, turnStart).