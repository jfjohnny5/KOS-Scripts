// launch.circularize.ks
// John Fallara
//
// Circularize around a body at a given altitude.

parameter orbitHeight.

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
set burnDone to false.
	
Notify("Initiating circularization program").
// calculate deltaV requirement
set calcPeri to PERIAPSIS + SHIP:BODY:RADIUS.
set calcApo to APOAPSIS + SHIP:BODY:RADIUS.
set circDV to sqrt(SHIP:BODY:MU / (calcApo)) * (1 - sqrt(2 * calcPeri / (calcPeri + calcApo))). // Vis-viva equation
set maxAccel to SHIP:MAXTHRUST / SHIP:MASS. 
set circBurnTime to circDV / maxAccel.

print "dV: " + circDV + " m/s".
print "burn time: " + circBurnTime + " s".

// begin circularization burn at half burn time before node
wait until ETA:APOAPSIS < (circBurnTime / 2).

// circularization burn
Notify ("Executing circularization burn").
lock STEERING to HEADING(90, 0).
if circBurnTime < 5 {
	lock THROTTLE to 0.5.
}
else lock THROTTLE to 1.
until burnDone {
	CheckStaging().
	if PERIAPSIS > orbitHeight {
		SAS ON.
		lock THROTTLE to 0.
		set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
		set burnDone to true.
		Notify("Orbital parameters achieved").
		Notify("Circularization program complete").
	}
}