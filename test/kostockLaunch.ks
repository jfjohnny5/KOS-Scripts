// kostockLaunch.ks v1.0.0
// John Fallara

function Notify {
	parameter message.
	HUDTEXT("kOS: " + message, 5, 2, 50, WHITE, false).
}

function Tilt {
	parameter minAltitude.
	parameter angle.
	
	wait until ALTITUDE > minAltitude.
	Notify("Locking heading to " + angle + " degrees").
	lock STEERING to HEADING(0, angle).
}

Notify("Launch program initiated").
Tilt(0, 80).
lock THROTTLE to 1.

wait 5.
Notify("Launching!").
stage.

wait until VERTICALSPEED > 300.
lock THROTTLE to 0.6.

tilt(10000, 70).
tilt(20000, 55).
tilt(30000, 40).

wait until APOAPSIS > 70000.
tilt(0, 10).
lock THROTTLE to 0.1.

wait until STAGE:LIQUIDFUEL < 180.
Notify("Decoupling launch stage").
lock THROTTLE to 0.
wait 5.
stage.

wait until ETA:APOAPSIS < 20.
tilt(0, 0).
wait 5.
lock THROTTLE to 1.

wait until PERIAPSIS > 70000.
lock throttle to 0.
Notify("Orbit achieved").

wait 5.
Notify("Shutting down launch sequence").
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.
shutdown.