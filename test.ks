// test.ks
// John Fallara

for p in SHIP:PARTSTAGGED("antenna") {
		set antenna to p:GETMODULE("ModuleDeployableAntenna").
		antenna:DOEVENT("extend antenna").
	}