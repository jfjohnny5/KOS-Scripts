for dependency in list(
	"program.ks",
	"004_muna1.ks",
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"lib.science.ks",
	"lib.descent.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing Artemis Flight Control Software".