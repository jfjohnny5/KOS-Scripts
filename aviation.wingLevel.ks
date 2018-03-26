// aviation.wingLevel.ks
// John Fallara

set pid to PIDLoop(0.03, 0.11, 0.015, -0.90, 0.90).
set pid:SETPOINT to 90.
set controlStick to SHIP:CONTROL.
set levelerState to false.

//pidTweak().

//clearscreen.
//print pid:KP.
//print pid:KI.
//print pid:KD.

until false {
	
	on AG10 {
		toggle levelerState. 
	}
	
	if AG10 {
		set now to TIME:SECONDS.
		set rollAngle to Vang(SHIP:FACING:STARVECTOR,SHIP:UP:VECTOR).
		set rollAdjust to pid:UPDATE(now, rollAngle).
		set controlStick:ROLL to rollAdjust.
		print "ACTIVE  " at (0,18).
		print rollAngle at (0,16).
		print rollAdjust at (0,17).
	}
	else {
		set controlStick:ROLL to 0.
		print "INACTIVE" at (0,18).
	}
wait 0.001.
}