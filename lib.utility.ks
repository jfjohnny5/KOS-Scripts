// lib.utility.ks
// Function library for general usage
// John Fallara

global Utility is lexicon(
	"Telemetry",			telemetry@,
	"Notify",				notify@,
	"Countdown",			countdown@,
	"Check Staging",		checkStaging@,
	"Stage At",				stageAt@,
	"Active Engine Info",	activeEngineInfo@,
	"Query SOI",			querySOI@,
	"Extend Antenna",		extendAntenna@,
	"PID Tweak",			pidTweak@
).

local function telemetry {
	local time is TIME:SECONDS.
	local alt is SHIP:ALTITUDE.
	local vel is SHIP:VELOCITY:MAG.
	local q is SHIP:DYNAMICPRESSURE.
	local atm is BODY:ATM:ALTITUDEPRESSURE(SHIP:ALTITUDE).
	local att is vang(UP, SHIP:FACING).
	local azi is SHIP:HEADING.
	local mass is SHIP:MASS.
	log time, alt, vel, q, atm, att, azi, mass to "flightrecorder.csv"
}

local function notify {
	parameter message.
	parameter type is "default".
	if type = "default" {
		HUDTEXT("kOS: " + message, 8, 2, 27, GREEN, true).
	}
	if type = "alert" {
		HUDTEXT("kOS: " + message, 8, 2, 27, RED, true).
	}
}

local function countdown {
	print "Countdown initiated".
	from { local x is 10. } until x = 0 step { set x to x - 1. } do {
		HUDTEXT(x + "...", 0.75, 2, 72, WHITE, false).
		wait 1.
	}
	HUDTEXT("LAUNCH!", 0.75, 2, 72, GREEN, false).
}

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

local function stageAt {
	parameter trigger.
	when ALTITUDE > trigger then {
		print "Staging trigger activated".
		stage.
		wait 3.
	}
	print "Staging trigger set for:     " + trigger + " m".
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

local function querySOI {
	parameter targetBody.
	if BODY:NAME = targetBody return true.
	else return false.
}

local function extendAntenna {
	print "Extending communication antenna".
	for p in SHIP:PARTSTAGGED("antenna") {
		set antenna to p:GETMODULE("ModuleDeployableAntenna").
		antenna:DOEVENT("extend antenna").
	}
}

local function pidTweak {
	parameter pid.
	local tempD is 0.
	local tempP is 0.
	local tempI is 0.
	
	on AG1 {
		set tempP to tempP - 0.01.
		print tempP + "                       " at (0,10).
		set pid:KP to tempP.
		preserve.
	}
	on AG2 {
		set tempP to tempP + 0.01.
		print tempP + "                       " at (0,10).
		set pid:KP to tempP.
		preserve.
	}
	on AG3 {
		set tempI to tempI - 0.01.
		print tempI + "                       " at (0,11).
		set pid:KI to tempI.
		preserve.
	}
	on AG4 {
		set tempI to tempI + 0.01.
		print tempI + "                       " at (0,11).
		set pid:KI to tempI.
		preserve.
	}
	on AG5 {
		set tempD to tempD - 0.01.
		print tempD + "                       " at (0,12).
		set pid:KD to tempD.
		preserve.
	}
	on AG6 {
		set tempD to tempD + 0.01.
		print tempD + "                       " at (0,12).
		set pid:KD to tempD.
		preserve.
	}
	return pid.
}