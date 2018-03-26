// aviation.wingLevel.ks
// John Fallara

set pid to PIDLoop(0.01, 0.00, 0.00, -0.90, 0.90).
set pid:SETPOINT to 90.
set controlStick to SHIP:CONTROL.
set levelerState to false.

clearscreen.

print pid:PTERM.
print pid:ITERM.
print pid:DTERM.

until false {
	
	on AG10 {
		toggle levelerState. 
	}
	
	if AG10 {
		print "ACTIVE  " at (0,18).
		set rollAngle to Vang(SHIP:FACING:STARVECTOR,SHIP:UP:VECTOR).
		print rollAngle at (0,16).
		set rollAdjust to pid:UPDATE(TIME:SECONDS, rollAngle).
		print rollAdjust at (0,17).
		set controlStick:ROLL to rollAdjust.
	}
	else {
		print "INACTIVE" at (0,18).
		set controlStick:ROLL to 0.
	}
	
	
	
	clearVecDraws().
	
	//ship
	//VecDraw(V(0,0,0), SHIP:FACING:FOREVECTOR, RGB(1,0,0), "", 5.0, true, 0.05).
	vecDraw(V(0,0,0), SHIP:FACING:STARVECTOR, RGB(0,1,0), "", 5.0, true, 0.05).
	//VecDraw(V(0,0,0), SHIP:FACING:TOPVECTOR, RGB(0,0,1), "", 5.0, true, 0.05).
	
	//world
	vecDraw(V(0,0,0), SHIP:UP:VECTOR, RGB(0,0,1), "", 10.0, true, 0.02).

wait 0.005.
}