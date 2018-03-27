// aviation.wingLevel.ks
// John Fallara

function wingLevel {
	set pid to PIDLoop(0.03, 0.11, 0.015, -0.90, 0.90).
	set pid:SETPOINT to 90.
	set controlStick to SHIP:CONTROL.

	on AG10 {
		if AG10 {
			print "Wing Leveler: ACTIVE   " at (0,18).
		}
		else {
			set controlStick:ROLL to 0.
			print "Wing Leveler: INACTIVE " at (0,18).
		}
		preserve.
	}
	when AG10 then {
		set rollAngle to Vang(SHIP:FACING:STARVECTOR,SHIP:UP:VECTOR).
		set rollAdjust to pid:UPDATE(TIME:SECONDS, rollAngle).
		set controlStick:ROLL to rollAdjust.
		wait 0.001.
		preserve.
	}
}