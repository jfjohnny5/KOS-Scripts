for dependency in list(
	"avionicsBasic.ks",
	"program.ks",
	"simpleOrbit.ks", // main mission file
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"lib.science.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing kOS Flight Control Software".