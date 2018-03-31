for dependency in list(
	"program.ks",
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"lib.science.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing kOS Flight Control Software".