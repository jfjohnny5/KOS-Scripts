lock throttle to 1.
stage.
lock targetPitch to 88.963 - 1.03287 * alt:radar^0.409511.
set targetDirection to 90.
lock steering to heading(targetDirection, targetPitch).
wait until false.