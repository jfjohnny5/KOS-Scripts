// test.ks
// John Fallara

// if exists("0:/flightrecorder.csv") deletepath("0:/flightrecorder.csv").
// log "time,alt,vel,q,atm,att,hdng,mass" to "0:/flightrecorder.csv".
// local function telemetry {
// 	local time is TIME:SECONDS.
// 	local alt is SHIP:ALTITUDE.
// 	local vel is SHIP:AIRSPEED.
// 	local q is SHIP:DYNAMICPRESSURE.
// 	local atm is BODY:ATM:ALTITUDEPRESSURE(SHIP:ALTITUDE).
// 	local att is vang(SHIP:FACING:FOREVECTOR, SHIP:UP:UPVECTOR).
// 	local hdng is mod(360 - SHIP:BEARING, 360).
// 	local mass is SHIP:MASS.
// 	log time+","+alt+","+vel+","+q+","+atm+","+att+","+hdng+","+mass to "0:/flightrecorder.csv".
// }

// local function vecTest {
// 	clearvecdraws().
// 	vecdraw(V(0,0,0), SHIP:FACING:FOREVECTOR, RED, "", 10, true, 0.01).
// 	vecdraw(V(0,0,0), UP:VECTOR, WHITE, "", 10, true, 0.01).
// 	print vang(SHIP:FACING:FOREVECTOR, SHIP:UP:UPVECTOR) at (0,20).
// }

runoncepath("lib.utility.ks").
print Utility["Calc TWR"]().