// utility.lib.ks
// John Fallara
//
// collection of general utility functions for use in specialized programs

function Notify {
	parameter message.
	HUDTEXT("kOS: " + message, 8, 2, 27, GREEN, false).
}

function CheckStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT and MAXTHRUST >= 0.1 {
			wait 1. 
			Notify("Dropping Boosters").
			stage.
			wait 1.
			return true.
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            lock THROTTLE to 0.
			wait 1. 
			Notify("Decoupling Stage").
			stage.
            wait 1.
			lock THROTTLE to 1.
			return true.
			break.
        }
    }
}

function ActiveEngineInfo {
	list ENGINES in eList.
	local currentT is 0.
	local maxT is 0.
	local mDot is 0.
	for e in eList {
		if e:IGNITION {
			set maxT to maxT  +  e:AVAILABLETHRUST.
			set currentT to currentT  +  e:THRUST.
			if NOT e:ISP = 0 set mDot to mDot  +  currentT / e:ISP.
		}.
	}.
	if mDot = 0 local avgISP is 0.
	else local avgISP is currentT / mDot.
	return list(currentT, maxT, avgISP, mDot).
}.

function pidTweak {
	set tempD to 0.
	set tempP to 0.
	set tempI to 0.
	
	on AG1 {
		set tempP to tempP - 0.01.
		print tempP + "                       " at (0,10).
		set PID_AltHold:KP to tempP.
		preserve.
	}
	on AG2 {
		set tempP to tempP + 0.01.
		print tempP + "                       " at (0,10).
		set PID_AltHold:KP to tempP.
		preserve.
	}
	on AG3 {
		set tempI to tempI - 0.01.
		print tempI + "                       " at (0,11).
		set PID_AltHold:KI to tempI.
		preserve.
	}
	on AG4 {
		set tempI to tempI + 0.01.
		print tempI + "                       " at (0,11).
		set PID_AltHold:KI to tempI.
		preserve.
	}
	on AG5 {
		set tempD to tempD - 0.01.
		print tempD + "                       " at (0,12).
		set PID_AltHold:KD to tempD.
		preserve.
	}
	on AG6 {
		set tempD to tempD + 0.01.
		print tempD + "                       " at (0,12).
		set PID_AltHold:KD to tempD.
		preserve.
	}	
}