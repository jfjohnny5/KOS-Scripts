// init.ks v1.0.0
// John Fallara

for dependency in list(
	"lib.utility.ks",
	"lib.launch.ks",
	"lib.maneuver.ks",
	"test.ks",
	"muna1.ks"
) if not exists(dependency) COPYPATH("0:/" + dependency,"").