// test.ks
// John Fallara
switch to 0.
if exists("flightrecorder.csv") deletepath("flightrecorder.csv").
log "time,alt,vel,q,atm,mass" to "flightrecorder.csv".
local function telemetry {
	local time is TIME:SECONDS.
	local alt is SHIP:ALTITUDE.
	local vel is SHIP:AIRSPEED.
	local q is SHIP:DYNAMICPRESSURE.
	local atm is BODY:ATM:ALTITUDEPRESSURE(SHIP:ALTITUDE).
//	local att is vang(UP, SHIP:FACING:FOREVECTOR).
//	local azi is SHIP:HEADING.
	local mass is SHIP:MASS.
	log time+","+alt+","+vel+","+q+","+atm+","+mass to "flightrecorder.csv".
}

until false {
	telemetry().
	wait 0.1.
}