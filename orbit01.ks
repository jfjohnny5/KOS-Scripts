// Orbit v1.0.0
// John Fallara

clearscreen.


print "Launching in 5 seconds...".
lock THROTTLE to 0.9.
lock STEERING to UP. //HEADING(90, 90). // East and Straight Up
wait 5.

print "Launching!".
stage.

wait until STAGE:SOLIDFUEL < 0.1. // effectively empty
wait 0.1.
print "Dropping boosters.".
stage.

wait until ALTITUDE > 30000.
print "Reaching 30,000 ft.".

wait until ALTITUDE > 70000.
print "Crossing the Kerman line.".

wait until ALT:RADAR < 500. 
print "Deploying parachute.".
stage.
wait until ALT:RADAR < 1. 
wait 1.
print "Touchdown.".