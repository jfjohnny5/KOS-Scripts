// test.ks
// John Fallara

local function calcDeorbit {
	local r is SHIP:ORBIT:APOAPSIS + BODY:RADIUS.
	local vAp is sqrt(BODY:MU * ((2 / r) - (1 / SHIP:ORBIT:SEMIMAJORAXIS))).
	local a is ((SHIP:ORBIT:APOAPSIS + BODY:RADIUS) + (BODY:RADIUS + BODY:ATM:HEIGHT * 0.5)) / 2.
	local vTarget is sqrt(BODY:MU * ((2 / r) - (1 / a))).
	local dV is vTarget - vAp.
	add node(TIME:SECONDS + ETA:APOAPSIS, 0, 0, dV).
}

calcDeorbit().