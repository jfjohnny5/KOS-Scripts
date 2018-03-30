for dependency in list(
	"lib.utility.ks",
	"aviation.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").
	
clearscreen.
print "Initializing KOS Aviation".