// aviation.ks
// John Fallara

run utility.lib.ks.
run aviation.altitudeHold.ks.
run aviation.wingLevel.ks.

until false {
	altitudeHold().
	wingLevel().
}