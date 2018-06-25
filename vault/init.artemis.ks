for dependency in list(
	"program.ks",
	"003_artemis3.ks",
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"lib.science.ks",
	"lib.descent.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing Artemis Flight Control Software".