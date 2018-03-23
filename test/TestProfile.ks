// TestProfile.ks v1.0.0
// John Fallara

run AscentExecution.

set AscentProfile to LIST(
	//Altitude,	Angle,	Thrust
	500,			85,		1,
	2500,		80,		.95,
	5000,		70,		.9,
	7500,		57,		.85,
	10000,		45,		.8,
	15000,		40,		.8,
	20000,		40,		.8,
	25000,		35,		.8,
	32000,		35,		.85,
	45000,		30,		.95,
	50000,		25,		.95,
	60000,		0,		.95,
	70000,		0,		1,
	72000,		0,		0
).

lock THROTTLE to 1.
wait 1.
stage.
ExecuteAscentProfile(90, AscentProfile).

// Start circularization
wait until ETA:APOAPSIS < 20.
lock THROTTLE to 0.75.

// Pause circularization and decouple launch stage
//wait until PERIAPSIS > 50000.
//lock THROTTLE to 0.
//wait 1.
//stage.

//wait 10.
//lock THROTTLE to 1.
wait until PERIAPSIS > 70000.

// Shutdown
lock THROTTLE to 0.
set SHIP:CONTROL:PILOTMAINTHROTTLE to 0.