// lib.utility.ks
// Function library for general usage
// John Fallara

global Utility is lexicon(
	"Notify",			notify@,
	"Active Engine Info",	activeEngineInfo@,
	"Query SOI",			querySOI@,
	"Extend Antenna",		extendAntenna@,
	"PID Tweak",			pidTweak@
).

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