testArg=0;
run("Misc...", "divide=Infinity save");
setBatchMode(true);
if(testArg!=0)
args = split(testArg,",");
else
args = split(getArgument(),",");

path = args[0];// save dir




print("nrrd compression");


open(path);

run("Nrrd Writer", "compressed nrrd="+path);


run("Misc...", "divide=Infinity save");
run("Quit");