// aviation.ks
// John Fallara

run utility.lib.ks.

set PID_AltHold to PIDLoop(0.004, 0.002, 0.04, -0.75, 0.75).
set altHold to SHIP:ALTITUDE.
set PID_WingLevel to PIDLoop(0.03, 0.11, 0.015, -0.90, 0.90).
set PID_WingLevel:SETPOINT to 90.
set controlStick to SHIP:CONTROL.

until false {	

	// Altitude Hold
	on AG9 {
		set altHold to SHIP:ALTITUDE. // set altitude to current everytime the mode is activated
		set PID_AltHold:SETPOINT to altHold.
		if AG9 {
			print altHold at (0,15).
			print "Altitude Hold: ACTIVE  " at (0,19).
			Notify("Altitude Hold: ACTIVE").
		}
		else {
			set controlStick:PITCH to 0.
			print "Altitude Hold: INACTIVE" at (0,19).
			Notify("Altitude Hold: INACTIVE").
		}
		preserve.
	}
	when AG9 then {	
		set controlStick:PITCH to PID_AltHold:UPDATE(TIME:SECONDS, ALTITUDE).  // all pitch control given to the autopilot
	}
	
	//Wing Leveler
	on AG10 {
		if AG10 {
			print "Wing Leveler: ACTIVE   " at (0,18).
			Notify("Wing Leveler: ACTIVE").
		}
		else {
			set controlStick:ROLL to 0.
			print "Wing Leveler: INACTIVE " at (0,18).
			Notify("Wing Leveler: INACTIVE").
		}
		preserve.
	}
	if AG10 {
		set rollAngle to Vang(SHIP:FACING:STARVECTOR,SHIP:UP:VECTOR).
		set rollAdjust to PID_WingLevel:UPDATE(TIME:SECONDS, rollAngle).
		set controlStick:ROLL to rollAdjust.
	}
	
	wait 0.001.
}