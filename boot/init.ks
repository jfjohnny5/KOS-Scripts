for dependency in list(
	"program.ks",
	"001_artemis1.ks",
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"lib.science.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing Artemis I Flight Control Software".