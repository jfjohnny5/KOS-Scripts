// utility.lib.ks
// John Fallara
//
// collection of general utility functions for use in specialized programs

function Notify {
	parameter message.
	HUDTEXT("kOS: " + message, 8, 2, 27, GREEN, true).
}

function CheckStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT and MAXTHRUST >= 0.1 {
			wait 2. 
			Notify("Dropping Boosters").
			stage.
			wait 2.
			return true.
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            lock THROTTLE to 0.
			wait 2. 
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

