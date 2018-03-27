// aviation.ks
// John Fallara

run utility.lib.ks.

set PID_AltHold to PIDLoop(0.06, 0.025, 0.02, -0.25, 0.25).
set altHold to SHIP:ALTITUDE.
set PID_WingLevel to PIDLoop(0.03, 0.11, 0.015, -0.45, 0.45).
set PID_WingLevel:SETPOINT to 90.
set controlStick to SHIP:CONTROL.
set debug to true.
pidTweak().

until false {	

	// Altitude Hold
	on AG9 {
		set altHold to SHIP:ALTITUDE. // set altitude to current every time the mode is activated
		set PID_AltHold:SETPOINT to altHold.
		if AG9 {
			print altHold at (0,14).
			print "Altitude Hold: ACTIVE  " + altHold + "m" at (0,18).
			Notify("Altitude Hold: ACTIVE").
		}
		else {
			set controlStick:PITCH to 0.
			print "Altitude Hold: INACTIVE" at (0,18).
			Notify("Altitude Hold: INACTIVE").
		}
		preserve.
	}
	if AG9 {	
		set controlStick:PITCH to PID_AltHold:UPDATE(TIME:SECONDS, ALTITUDE).  // all pitch control given to the autopilot
		if debug {
			print "AltHold  -  Kp: " + PID_AltHold:KP + " Ki: " + PID_AltHold:KI + " Kd: " + PID_AltHold:KD + "                     " at (0,15).
		}
	}
	
	//Wing Leveler
	on AG10 {
		if AG10 {
			print "Wing Leveler: ACTIVE   " at (0,19).
			Notify("Wing Leveler: ACTIVE").
		}
		else {
			set controlStick:ROLL to 0.
			print "Wing Leveler: INACTIVE " at (0,19).
			Notify("Wing Leveler: INACTIVE").
		}
		preserve.
	}
	if AG10 {
		set rollAngle to Vang(SHIP:FACING:STARVECTOR,SHIP:UP:VECTOR).
		set rollAdjust to PID_WingLevel:UPDATE(TIME:SECONDS, rollAngle).
		set controlStick:ROLL to rollAdjust.
		if debug {
			print "WingLevel - Kp: " + PID_WingLevel:KP + " Ki: " + PID_WingLevel:KI + " Kd: " + PID_WingLevel:KD + "                     " at (0,16).
		}
	}
	
	wait 0.001.
}