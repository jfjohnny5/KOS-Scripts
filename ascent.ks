// ascent.ks
// John Fallara
//
// Automated ascent guidance using following profile.
// MAX(90-(((ALTITUDE-turnStart)/(turnEnd-turnStart))^turnExponent*90),0)

// SETUP VARIABLES
parameter turnStart is 500.
parameter turnExponent is 0.6.
parameter turnEnd is 50000.
parameter orbitHeight is 72000.
parameter forceStage is false. // if using a simple 2-stage rocket, and the main booster should/shouldn't be used after ascent

//
// SETUP FUNCTIONS
//
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

function Notify {
	parameter message.
	HUDTEXT("kOS: " + message, 5, 2, 25, WHITE, true).
}

//
// Initialization
//
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
		if forceStage {
			wait 2.
			stage.
			Notify("Decoupling stage").
		}
	}
}
unlock THROTTLE.
unlock STEERING.
Notify("Ascent program complete").