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
			break.
		}
		else if e:FLAMEOUT and MAXTHRUST < 0.1 {
            set currentThrottle to THROTTLE.
			lock THROTTLE to 0.
			wait 2. 
			Notify("Decoupling Stage").
			stage.
            wait 2.
			lock THROTTLE to currentThrottle.
			break.
        }
    }
}