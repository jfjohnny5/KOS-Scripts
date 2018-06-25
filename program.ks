// To initiate mission, type "run program.ks." from the kOS console
// To initiate a specific mission phase, type "run program.ks("PhaseNameHere")." from the kOS console

parameter action is "Launch".
local mission is "exampleMission". // main mission file

runpath(mission, action).