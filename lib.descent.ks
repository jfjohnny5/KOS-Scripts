// lib.descent.ks
// Function library for powered descent maneuvers
// John Fallara
// based on code from Kevin Gisi

// Library variables
local nil is 0.0001.
local hover_pid is PIDLoop(2.7, 4.4, 0.12, 0, 1).

global Descent is lexicon(
	"Unpowered Descent",	unpwrDescent@,
	"Powered Descent",		powered_landing@
).

local function unpwrDescent {
	wait until trajectoryConfirm().
	reentryAlign().
	armParachutes().
	until touchdown() {
		wait 0.01.
	}
}

local function trajectoryConfirm {
	if SHIP:ORBIT:PERIAPSIS < BODY:ATM:HEIGHT {
		print "Reentry trajectory confirmed".
		wait 5.
		stage.
		return true.
	}
	else return false.
}

// Align for reentry
local function reentryAlign {
	print "Aligning for reentry interface".
	lock STEERING to SRFRETROGRADE.
}

// Arm the parachutes at < 50% atmospheric height
local function armParachutes {
	when ALTITUDE < BODY:ATM:HEIGHT * 0.5 then { 
		stage.	// arm parachutes
		print "Parachutes armed".
	}
}

local function touchdown {
	if SHIP:STATUS = "Landed" {
		print "Touchdown".
		unlock STEERING.
		return true.
	}
	else return false.
}

local function suicide_burn {
	parameter cutoff.
	local throttleControl is 0. 
	lock THROTTLE to throttleControl.
	local has_impact_time is {
		local a is (
			g() * (1 - (availtwr() * max(cos(vang(UP:VECTOR, SHIP:FACING:VECTOR)), nil)))
		).
		local v is VERTICALSPEED * -1.
		local d is radar() - cutoff.
		return v^2 + 2 * a * d > 0.
	}.
	lock STEERING to descent_vector().
	until radar() < cutoff or SHIP:AVAILABLETHRUST < 0.1 {
		if has_impact_time() set throttleControl to 1.
		else set throttleControl to 0.
		wait 0.001.
	}
}

local function powered_landing {
	local throttleControl is 0. 
	lock THROTTLE to throttleControl.
	lock STEERING to descent_vector().
	until ALT:RADAR < 15 { set throttleControl to hover(-7). wait 0. }				// descend at 7 m/s until 15 m above the surface
	until VELOCITY:SURFACE:MAG < 0.5 { set throttleControl to hover(0). wait 0. }	// slow down to 0.5 m/s relative to  the surface
	until SHIP:STATUS = "Landed" { set throttleControl to hover(-2). wait 0. }		// descend at 2 m/s until touchdown
	set throttleControl to 0.
}

local function hover {
	parameter setpoint.
	set hover_pid:SETPOINT to setpoint.
	set hover_pid:MAXOUTPUT to availtwr().
	return min(hover_pid:UPDATE(TIME:SECONDS, SHIP:VERTICALSPEED) / max(cos(vang(UP:VECTOR, SHIP:FACING:VECTOR)), 0.0001) / max(availtwr(), 0.0001), 1).
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