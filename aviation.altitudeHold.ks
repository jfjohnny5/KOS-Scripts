// aviation.altitudeHold.ks
// John Fallara

parameter altHold.
set pid to PIDLoop(0.004, 0.002, 0.04, -0.75, 0.75).
set pid:SETPOINT to altHold.
set activate to false.
set rcsState to RCS.
set controlStick to SHIP:CONTROL.

clearscreen.

// on RCS {set activate to true.}
until false {
	if RCS <> rcsState {
		set rcsState to RCS.
		if activate {
			set activate to false.
			print "Altitude hold toggled OFF".
			set controlStick:PITCH to 0.	// release pitch control to the pilot
		}
		else {
			set activate to true.
			print "Altitude hold (" + altHold + ") toggled ON".
		}
	}
	if activate {
		set controlStick:PITCH to pid:UPDATE(TIME:SECONDS, ALTITUDE).	// all pitch control given to the autopilot
		print ALTITUDE at (0,16).
		print "P:   " + pid:PTERM at (0,17).
		print "I:   " + pid:ITERM at (0,18).
		print "D:   " + pid:DTERM at (0,19).
		print "out: " + controlStick:PITCH at (0, 20).
	}
	wait 0.05.
}