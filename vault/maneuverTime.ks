// Calculate the burn time to complete a burn of a fixed Δv

// Base formulas:
// Δv = ∫ F / (m0 - consumptionRate * t) dt
// consumptionRate = F / (Isp * g)
// ∴ Δv = ∫ F / (m0 - (F * t / g * Isp)) dt

// Integrate:
// ∫ F / (m0 - (F * t / g * Isp)) dt = -g * Isp * log(g * m0 * Isp - F * t)
// F(t) - F(0) = known Δv
// Expand, simplify, and solve for t

function maneuverTime {
	parameter dV.

	local f is 0.											// Engine Thrust (kg * m/s²)
	local m is SHIP:MASS * 1000.								// Starting mass (kg)
	local e is CONSTANT():E.									// Base of natural log
	local p is 0.											// Engine ISP (s)
	local g is SHIP:ORBIT:BODY:MU / (SHIP:ORBIT:BODY:RADIUS)^2.	// Gravitational acceleration constant (m/s²)

	local enCount is 0.
	list ENGINES in all_engines.
	
	for en in all_engines if en:IGNITION and not en:FLAMEOUT {
		set f to f + en:AVAILABLETHRUST.
		set p to p + en:ISP.
		set enCount to enCount + 1.
	}
	set p to p / enCount.
	set f to f * 1000.
	return g * m * p * (1 - e^(-dV / (g * p))) / f.
}

print "Time for a 100m/s burn: " + maneuverTime(100).
print "Time for a 200m/s burn: " + maneuverTime(200).
print "Time for a 300m/s burn: " + maneuverTime(300).
print "Time for a 400m/s burn: " + maneuverTime(400).
print "Time for a 500m/s burn: " + maneuverTime(500).
print "Time for a 1000m/s burn: " + maneuverTime(1000).