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
print " ".
print "Preflight Checklist".
print "===================".
print "[] Fairings tagged with 'fairing'".
print "[] Engines on first stage".
print "[] Snacks stowed securely".
print " ".
print "Type 'run program.ks.' to initiate launch".