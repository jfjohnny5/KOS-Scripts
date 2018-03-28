// test.ks
// John Fallara

set file to "lib.science.ks".

COPYPATH("0:/" + file,"").
runpath(file).

set file to "lib.utility.ks".

COPYPATH("0:/" + file,"").
runpath(file).

Science["Reset Experiments"]().