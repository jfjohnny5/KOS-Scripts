for dependency in list(
	"test.ks",
	"program.ks",
	"exampleMission.ks", // main mission file
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"lib.science.ks",
	"lib.descent.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing kOS Flight Control Software".