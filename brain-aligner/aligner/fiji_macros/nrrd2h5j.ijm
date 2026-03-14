//
// Converts a set of nrrd single channel files into an h5j file.
// Example arguments:
//   "/output/path/for/h5j/file.h5j,/input/ch1.nrrd,/input/ch2.nrrd"
//
setBatchMode(true);

var arg = getArgument();
var args = split(arg,",");
var numArgs = lengthOf(args);
if (numArgs<2)
    exit("Macro requires at least 2 arguments, got: "+arg);

var s = "";
var h5jfile = args[0];
for (i=1; i<numArgs; i++) {
    nrrdpath = args[i];
    print("Channel "+i+": "+nrrdpath);
    run("Nrrd ...", "load=[" + nrrdpath + "]");
    var name = File.getName(nrrdpath);
    s += "c"+i+"="+name+" ";
}

s += "create ignore";
print("Merge Channels... "+s);
run("Merge Channels...", s);
saveCmd = "save=[" + h5jfile + "] crf=20";
print("Save... " + saveCmd);
run("Janelia H265 Writer", saveCmd);

print("Done");
close();
run("Quit");
