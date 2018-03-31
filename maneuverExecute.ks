runpath("maneuverTime.ks").

function exec {
	parameter autowarp is false.
	parameter node is NEXTNODE.
	parameter dV0 is node:DELTAV.
	parameter t0 is TIME:SECONDS + node:ETA - maneuverTime(dV0:MAG) / 2.

	lock STEERING to node:DELTAV.
	if autowarp warpto(t0 - 30).
	wait until TIME:SECONDS >= t0.
	local throttleControl is 0.
	lock THROTTLE to throttleControl.
	until vdot(node:DELTAV, dV0) < 0.01 {
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
		set throttleControl to min(maneuverTime(node:DELTAV:MAG), 1).	// feather the throttle when < 1 second
		wait 0.1.
	}
	lock THROTTLE to 0.
	unlock STEERING.
	remove NEXTNODE.
	wait 0.
}

exec().