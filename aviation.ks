// aviation.ks
// John Fallara

clearscreen.

run utility.lib.ks.

set PID_AltHold to PIDLoop(0.06, 0.025, 0.02, -0.25, 0.25).
set altHold to SHIP:ALTITUDE.
set PID_WingLevel to PIDLoop(0.03, 0.11, 0.015, -0.45, 0.45).
set PID_WingLevel:SETPOINT to 90.
set controlStick to SHIP:CONTROL.
set debug to true.
pidTweak().

set gui to GUI(330).
gui:ADDLABEL("<b>PID Tuning</b>").
set Kp_Readout to gui:ADDHBOX().
set Kp_Layout to gui:ADDHLAYOUT().
set Ki_Readout to gui:ADDHBOX().
set Ki_Layout to gui:ADDHLAYOUT().
set Kd_Readout to gui:ADDHBOX().
set Kd_Layout to gui:ADDHLAYOUT().
// Kp section
Kp_Layout:ADDLABEL("<color=white>Kp Step</color>").
set Kp_Text to Kp_Layout:ADDTEXTFIELD("0.01").
set Kp_minus to Kp_Layout:ADDBUTTON("Kp (-)").
set Kp_plus to Kp_Layout:ADDBUTTON("Kp (+)").
Kp_Readout:ADDLABEL("Initial Kp:      " + PID_AltHold:KP:TOSTRING).
set Kp_Display to Kp_Readout:ADDLABEL("").
// Ki section
Ki_Layout:ADDLABEL("<color=white>Ki Step</color>").
set Ki_Text to Ki_Layout:ADDTEXTFIELD("0.01").
set Ki_minus to Ki_Layout:ADDBUTTON("Ki (-)").
set Ki_plus to Ki_Layout:ADDBUTTON("Ki (+)").
Ki_Readout:ADDLABEL("Initial Ki:      " + PID_AltHold:KI:TOSTRING).
set Ki_Display to Ki_Readout:ADDLABEL("").
// Kd section
Kd_Layout:ADDLABEL("<color=white>Kd Step</color>").
set Kd_Text to Kd_Layout:ADDTEXTFIELD("0.01").
set Kd_minus to Kd_Layout:ADDBUTTON("Kd (-)").
set Kd_plus to Kd_Layout:ADDBUTTON("Kd (+)").
Kd_Readout:ADDLABEL("Initial Kd:      " + PID_AltHold:KD:TOSTRING).
set Kd_Display to Kd_Readout:ADDLABEL("").

gui:SHOW().
set KpStep to 0.01.
set KiStep to 0.01.
set KdStep to 0.01.

// user adjustment of step values
on Kp_Text:CONFIRMED {
	set KpStep to Kp_Text:TEXT:TOSCALAR.
	preserve.
}
on Ki_Text:CONFIRMED {
	set KiStep to Ki_Text:TEXT:TOSCALAR.
	preserve.
}
on Kd_Text:CONFIRMED {
	set KdStep to Kd_Text:TEXT:TOSCALAR.
	preserve.
}
set Kp_minus:ONCLICK to { 
	set PID_AltHold:KP to PID_AltHold:KP - KpStep.
}.
set Kp_plus:ONCLICK to { 
	set PID_AltHold:KP to PID_AltHold:KP + KpStep. 
}.
set Ki_minus:ONCLICK to { 
	set PID_AltHold:KI to PID_AltHold:KI - KiStep. 
}.
set Ki_plus:ONCLICK to { 
	set PID_AltHold:KI to PID_AltHold:KI + KiStep. 
}.
set Kd_minus:ONCLICK to { 
	set PID_AltHold:KD to PID_AltHold:KD - KdStep. 
}.
set Kd_plus:ONCLICK to { 
	set PID_AltHold:KD to PID_AltHold:KD + KdStep. 
}.

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