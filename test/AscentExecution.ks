// AscentExecution.ks v1.0.0
// John Fallara

function ExecuteAscentStep {
	parameter direction.	// compass heading angle
	parameter minAlt.		// altitude at which ascent step should be performed
	parameter newAngle.	// declination angle for steering (90 = straight up; 0 = horizontal)
	parameter newThrottle.	// throttle setting
	
	set prevThrust to MAXTHRUST.	// initialize variable to full possible thrust of all engines in current stage
	
	until false {
		
		// if 
		if MAXTHRUST < (prevThrust - 10) {		// if the max thrust is less than the recorded value, the engine is out of fuel
			print "Stage depleted.".
			set currentThrottle to THROTTLE.	// save the current throttle setting
			lock THROTTLE to 0.
			wait 1.
			print "Staging.".
			stage.	// decouple current stage
			wait 1.
			stage.	// activate engine(s)
			wait 1.
			lock THROTTLE to currentThrottle.
			set prevThrust to MAXTHRUST.
		}
		
		if ALTITUDE > minAlt {
			lock STEERING to HEADING(direction, newAngle).
			lock THROTTLE to newThrottle.
			break.
		}
		
		wait 0.1.  // "clock" timer to run the loop
	}
}

// Ascent Profile List Format
// ===========================
// Altitude, Angle, Throttle

function ExecuteAscentProfile {
	parameter direction.
	parameter profile.
	
	set step to 0.
	until step >= profile:length - 1 {
		print "Setting Direction: " + direction.
		print "Setting Min Alt:   " + profile[step].
		print "Setting Angle:     " + profile[step + 1].
		print "Setting Throttle:  " + profile[step + 2].
		print "============================".
		executeAscentStep(
			direction,
			profile[step],
			profile[step + 1],
			profile[step + 2]
		).
		set step to step + 3.	
	}
}