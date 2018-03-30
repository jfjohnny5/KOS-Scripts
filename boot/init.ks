for dependency in list(
	"flynow.ks"
) if not exists(dependency) copypath("0:/" + dependency,"").