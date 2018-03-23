// ascent.ks
// John Fallara
//
// Automated ascent guidance using following profile.
// MAX(90-(((ALTITUDE-turnStart)/(turnEnd-turnStart))^turnExponent*90),0)

// SETUP VARIABLES
set turnStart to 500.
set turnExponent to 0.526.
set turnEnd to 47900.
set orbitHeight to 72000.

// SETUP FUNCTIONS
function CheckStaging {
	list ENGINES in eList.
	for e in eList {
        if e:FLAMEOUT {
            set currentThrottle to THROTTLE.
			lock THROTTLE to 0.
			wait 2.
			stage.
            Notify("Decoupling stage").

            until STAGE:READY {
                wait 2.
				lock THROTTLE to currentThrottle.
            }
        }
    }
}

clearscreen.

// initialization
set ascentComplete to false.

// launch
SAS ON.
set THROTTLE to 1.
stage.
Notify("Initiating ascent program").

wait until ALTITUDE > turnStart.
Notify("Executing roll and pitch maneuver").
SAS OFF.

// ascent program
until ascentComplete {
	// lock steering to ascent profile
	set steerPitch to max(90-(((ALTITUDE - turnStart) / (turnEnd - turnStart))^turnExponent * 90),0).
	lock STEERING to HEADING(90, steerPitch).

	CheckStaging().
	
	if APOAPSIS > orbitHeight {
		lock THROTTLE to 0.
		lock STEERING to PROGRADE.
		set ascentComplete to true.
	}
}

Notify("Ascent program complete").