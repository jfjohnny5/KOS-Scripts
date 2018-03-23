// circularize.ks
// John Fallara
//
// Circularize around a body at a given altitude.

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

set orbitHeight to 72000.
set circBurnTime to 75. 

set inOrbit to false.

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