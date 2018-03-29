local NIL is 0.0001.

local descent is lex(
	"Suicide Burn",		suicide_burn@,
	"Powered Landing",	powered_landing@
).

local function suicide_burn {
	parameter cutoff.
	local t is 0. 
	lock THROTTLE to t.
	local has_impact_time is {
		local a is (
			g() * (1 - (availtwr() * max(cos(vang(UP:VECTOR, SHIP:FACING:VECTOR)), NIL)))
		).
		local v is VERTICALSPEED * -1.
		local d is radar() - cutoff.
		return v^2 + 2*a*d > 0.
	}.
	lock STEERING to descent_vector().
	until radar() < cutoff or SHIP:AVAILABLETHRUST < 0.1 {
		if has_impact_time() set t to 1.
		else set t to 0.
		wait 0.001.
	}
}

local function powered_landing {
	local t is 0. lock THROTTLE to t.
	lock STEERING to descent_vector().
	until ALT:RADAR < 15 { set t to hover(-7). wait 0. }
	until VELOCITY:SURFACE:MAG < 0.5 { set t to hover(0). wait 0. }
	until SHIP:STATUS = "Landed" { set t to hover(-2). wait 0. }
	set t to 0.
}

local hover_pid is PIDLoop(2.7, 4.4, 0.12, 0, 1).

local function hover {
	parameter setpoint.
	set hover_pid:SETPOINT to setpoint.
	set hover_pid:MAXOUTPUT to availtwr().
	return min(
		hover_pid:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED) /
		max(cos(vang(UP:VECTOR, SHIP:FACING:VECTOR)), 0.0001) /
		max(availtwr(), 0.0001),
		1
	).
}

local function descent_vector {
	if vang(SRFRETROGRADE:VECTOR, UP:VECTOR) > 90 return unrotate(up).
	return unrotate(UP:VECTOR * g() - VELOCITY:SURFACE).
}

local function unrotate {
	parameter v. 
	if v:TYPENAME <> "Vector" set v to v:VECTOR.
	return lookdirup(v, SHIP:FACING:TOPVECTOR).
}

local function radar {
	return altitude - BODY:GEOPOSITIONOF(SHIP:POSITION):TERRAINHEIGHT.
}

local function g { 
	return BODY:MU / ((SHIP:ALTITUDE + BODY:RADIUS)^2). 
}

local function availtwr { 
	return SHIP:AVAILABLETHRUST / (SHIP:MASS * g()). 
}

export(descent).