// aviation.altitudeHold.ks
// John Fallara

function altitudeHold {
	set pid to PIDLoop(0.004, 0.002, 0.04, -0.75, 0.75).
	set controlStick to SHIP:CONTROL.
	declare altHold is SHIP:ALTITUDE.

		on AG9 {
			set altHold to SHIP:ALTITUDE.
			set pid:SETPOINT to altHold.
			if AG9 {
				print altHold at (0,15).
				print "Altitude Hold: ACTIVE  " at (0,19).
			}
			else {
				set controlStick:PITCH to 0.
				print "Altitude Hold: INACTIVE" at (0,19).
			}
			preserve.
		}
		when AG9 then {	
			set controlStick:PITCH to pid:UPDATE(TIME:SECONDS, ALTITUDE).  // all pitch control given to the autopilot
			wait 0.001.
			preserve.
		}
}