function exec {
	parameter autowarp is 0.
	parameter node is NEXTNODE.
	parameter dV_Vector is node:BURNVECTOR.
	parameter starttime is TIME:SECONDS + node:ETA - mnv_time(dV_Vector:MAG) / 2.

	lock STEERING to node:BURNVECTOR.
	if autowarp warpto(starttime - 30).
	wait until TIME:SECONDS >= starttime.
	local t is 0.
	lock THROTTLE to t.
	until vdot(node:BURNVECTOR, dV_Vector) < 0 {
		//if SHIP:MAXTHRUST < 0.1 {
		//	stage.
		//	wait 0.1.
		//	if SHIP:MAXTHRUST < 0.1 {
		//		for part in SHIP:PARTS {
		//			for resource in part:RESOURCES set resource:ENABLED to true.
		//		}
		//		wait 0.1.
		//	}
		//}
		set t to min(mnv_time(node:BURNVECTOR:MAG), 1).	// feather the throttle when < 1 second
		wait 0.1.
	}
	lock THROTTLE to 0.
	unlock STEERING.
	remove NEXTNODE.
	wait 0.
}