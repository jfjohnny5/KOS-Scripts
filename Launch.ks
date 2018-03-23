// launch.ks
// John Fallara

function Notify {
	parameter message.
	HUDTEXT("kOS: " + message, 5, 2, 25, WHITE, true).
}

run AscentCurve.