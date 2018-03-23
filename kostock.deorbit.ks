// kostockDeorbit.ks v1.0.0
// John Fallara

Notify("Deorbit program initiated").

if PERIAPSIS > 60000 {
	Notify("Orbit detected. Executing deorbit burn.").
	
	lock STEERING to RETROGRADE.
	wait 20.
	lock THROTTLE to 1.
	
	wait until PERIAPSIS < 35000 or SHIP:LIQUIDFUEL < 0.1.
}

Notify("Orbital decay achieved").
lock THROTTLE to 0.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.

wait 1.
Notify("Detaching").
until false {
	stage.
}