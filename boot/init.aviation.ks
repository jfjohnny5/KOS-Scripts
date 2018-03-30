for dependency in list(
	"aviation.ks"
	"lib.utility.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").

clearscreen.
print "Initializing KOS Aviation".