// AscentCurve.ks
// John Fallara
//
// MAX(90-(((ALTITUDE-turnStart)/(turnEnd-turnStart))^turnExponent*90),0)

// SETUP VARIABLES
set turnStart to 500.
set turnExponent to 0.526.
set turnEnd to 47900.
set orbitHeight to 72000.
set circBurnTime to 75. 

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

// initialization
set ascentComplete to false.
set inOrbit to false.

clearscreen.

// launch
SAS ON.
set THROTTLE to 1.
stage.

wait until ALTITUDE > turnStart.
Notify("Executing roll and pitch program").
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

// begin circularization burn at half burn time before node
wait until ETA:APOAPSIS < (circBurnTime / 2).
Notify ("Executing circularization burn").
lock STEERING to HEADING(90, 0).
lock THROTTLE to 1.

// circularization program
until inOrbit {
	CheckStaging().
	
	if PERIAPSIS > orbitHeight {
		SAS ON.
		lock THROTTLE to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		set inOrbit to true.
		Notify("Orbital parameters achieved").
		Notify("Launch program complete").
	}
}