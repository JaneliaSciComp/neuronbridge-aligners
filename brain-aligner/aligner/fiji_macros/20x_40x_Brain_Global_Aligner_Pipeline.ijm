//Pre-Image processing for Brain before CMTK operation
//Wrote by Hideo Otsuna, Jan 16, 2018
run("Misc...", "divide=Infinity save");
run("Close All");

MIPsave=1;
ShapeAnalysis=1;//perform shape analysis and kick strange sample
CLAHEwithMASK=1;
Batch=1;
BWd=0; //BW decision at 793 line
PrintSkip=0;
templateBr="JFRC2014";//JFRC2013, JFRC2014, JRC2018
ForceUSE=false;
nrrdEx=true;
revstack=false;
nc82decision="Signal_amount";//"ch1","ch2","ch3"

cropWidth=1400;
cropHeight=800;
ChannelInfo = "01 02 nrrd files";
blockposition=1;
totalblock=1;
Frontal50pxPath=0;
MCFOYN=false;
TwentyMore=false;
DecidedColor="Red";
ShapeMatchingMaskPath=0;
JFRC2010MedProPath=0;

Slice50pxPath=0;
LateralMIPPath=0;
dir=0;
savedir=0;
saveOK=0;
lsmOK=0;
rotationYN="No";
BrainShape= "Unknown";//"Both_OL_missing (40x)";//"Intact", "Both_OL_missing (40x)", "Unknown"
shrinkTo2010=false;

shiftY=15;
DesireX=512;

setBatchMode(true);
testArg=0;

reverseR=1;
APcheck=1;
forceAPinv=0; //1 is forcefully inv
forceUPdown=0; //1 is rotate 180 degree

nameFile="Acq1_Da6_KDRT_smOllas_ollasRb488_B1_2023_02_26__12_43_32_bothCh.tif";

// 40x

//testArg="/Users/otsunah/test/20x_brain_alignment/Failed_/,VT006863_GAL4_attP2_5.lsm,/Users/otsunah/test/20x_brain_alignment/Failed_/VT006863_GAL4_attP2_5.lsm,/Volumes/otsuna/template/,0.5,1,11,40x,JRC2018,Both_OL_missing (40x),/test/20x_brain_alignment/fail/ConsolidatedLabel.v3dpbd"

//testArg= "/test/20x_brain_alignment/fail/,tile-2598433930730274853.v3draw,/test/20x_brain_alignment/fail/tile-2598433930730274853.v3draw,/Users/otsunah/Documents/otsunah/20x_brain_aligner/,0.44,0.44,11,40x,JRC2018,Both_OL_missing (40x),/test/20x_brain_alignment/fail/ConsolidatedLabel.v3dpbd"

//testArg= "/test/20x_brain_alignment/fail/,tile-2597686417454792738.v3draw,/Users/otsunah/Dropbox\ \(HHMI\)/40x_project/tile-2597686417454792738.v3draw,/Users/otsunah/Documents/otsunah/20x_brain_aligner,0.44,0.44,11,40x,JRC2018,Both_OL_missing (40x),??"


//for 20x
//<<<<<<< HEAD
//testArg= "/Registration/Output/,"+nameFile+",/Registration/"+nameFile+",/Users/otsunah/Registration/JRC2018_align_test/Template,0.4763198,1,11,20x,JRC2018,Both_OL_missing (40x),??"
//=======
//testArg= "/test/20x_brain_alignment/TwoChannel/,JRC_SS31881_20180615_24_B2_Brain.h5j,/Users/otsunah/Downloads/Workstation/JRC_SS31881/JRC_SS31881_20180615_24_B2_Brain.h5j,/Users/otsunah/Documents/otsunah/20x_brain_aligner/,0.52,1,7,20x,JRC2018,Unknown,??"

//0.46
//testArg= "/Users/otsunah/test/20x_brain_alignment/,"+nameFile+",/Users/otsunah/test/20x_brain_alignment/"+nameFile+",/Users/otsunah/Registration/JRC2018_align_test/Template,0.46,1,11,40x,JRC2018,Both_OL_missing (40x),??,false,Signal_amount";
//testArg= "/Users/otsunah/test/Brain_aligner/prealigned/,"+nameFile+",/Users/otsunah/test/Brain_aligner/"+nameFile+",/Users/otsunah/Dropbox\ \(Personal\)/Hideo_Daily_Coding/Brainaligner_CDMcreator/template,0.468,1,6,40x,JRC2018,Both_OL_missing (40x),??,false,Signal_amount,Max";

//testArg= "G:\\Guest\\Yoshi\\,"+nameFile+",G:\\Guest\\Yoshi\\"+nameFile+",E:\\template,0.18,0.38,14,63x,JRC2018,Intact,??,false,ch1,Median";

//-Lop
//testArg= "/test/20x_brain_alignment/NoLop/,GMR_13D08_AE_01_13-fA01b_C080304_20080305233708703.zip,/test/20x_brain_alignment/pre_Align_Test_Vol/-Lop/GMR_13D08_AE_01_13-fA01b_C080304_20080305233708703.zip,/Users/otsunah/Documents/otsunah/20x_brain_aligner/,0.46,1,7,20x,JRC2018,Unknown,??"
flipchannel=0;
PNGsave=0;
opticlobeMASKcheck=0;
nc82usecolor=0;
//-Rop

if(testArg!=0)
args = split(testArg,",");
else
args = split(getArgument(),",");

savedir = args[0];// save dir
filename = args[1];//file name
path = args[2];// full file path for inport LSM
MatchingFilesDir = args[3];
widthVx = args[4];// X voxel size
depth = args[5];// slice depth
NumCPU=args[6];
objective = args [7];//"40x" or "20x"
templateBr = args [8];//"JFRC2014", JFRC2013, JFRC2014, JRC2018
BrainShape = args [9];//"Both_OL_missing (40x)";//"Intact", "Both_OL_missing (40x)", "Unknown"
PathConsolidatedLabel=args[10];// full file path for ConsolidatedLabel.v3dpbd
forceVxSize = args[11];//true, false
nc82decision = args[12];//"Signal_amount","ch1","ch2","ch3","ch4"
comparisonP = args[13] ;//"Median", "Max"

MatchingFilesDir=MatchingFilesDir+"/";

Frontal50pxPath = MatchingFilesDir+"JFRC2010_60pxMedP.tif";// full file path for "JFRC2010_60pxMedP.tif"
LateralMIPPath = MatchingFilesDir+"Lateral_JFRC2010_5time_smallerMIP.tif";//  full file path for "Lateral_JFRC2010_5time_smallerMIP.tif"
Slice50pxPath = MatchingFilesDir+"JFRC2010_50pxSlice.tif";//  full file path for "JFRC2010_50pxSlice.tif"
ShapeMatchingMaskPath = MatchingFilesDir+"JFRC2010_ShapeMatchingMask.tif";//"JFRC2010_ShapeMatchingMask.tif";


widthVx=parseFloat(widthVx);//Chaneg string to number
depth=parseFloat(depth);//Chaneg string to number
heightVx=widthVx;
NumCPU= parseFloat(NumCPU);//Chaneg string to number

Ori_widthVx = widthVx;
Ori_heightVx = widthVx;
filename=replace(filename, " ", "_");

print("savedir; "+savedir);
print("filename; "+filename);
print("path;"+path);
print("MatchingFilesDir; "+MatchingFilesDir);
print("X resolution; "+widthVx+" micron");
print("depth; "+depth);
print("NumCPU; "+NumCPU);
print("objective; "+objective);
print("templateBr; "+templateBr);
print("BrainShape; "+BrainShape);
print("PathConsolidatedLabel; "+PathConsolidatedLabel);
print("forceVxSize; "+forceVxSize);
print("nc82decision; "+nc82decision);
print("comparisonP; "+comparisonP);
print("");

print("Frontal50pxPath; "+Frontal50pxPath);
print("LateralMIPPath; "+LateralMIPPath);
print("Slice50pxPath; "+Slice50pxPath);
print("ShapeMatchingMaskPath; "+ShapeMatchingMaskPath);


savedirext=File.exists(savedir);
if(savedirext!=1)
File.makeDirectory(savedir);

noext=filename;
DotIndex = lastIndexOf(filename, ".");
if(DotIndex!=-1)
noext = substring(filename, 0, DotIndex);


logsum=getInfo("log");

if(PNGsave==1)
filepath=savedir+"20x_brain_pre_aligner_log_"+noext+"_.txt";
else
filepath=savedir+"20x_brain_pre_aligner_log.txt";

File.saveString(logsum, filepath);

String.resetBuffer;
n3 = lengthOf(savedir);
for (si=0; si<n3; si++) {
	c = charCodeAt(savedir, si);
	if(c==32){// if there is a space
		print("There is a space, please eliminate the space from saving directory.");
		
		logsum=getInfo("log");
		File.saveString(logsum, filepath);
		exit();
	}
	//	String.append(fromCharCode(c));
	//	filename = String.buffer;
}
String.resetBuffer;

myDir0 = savedir+"Shape_problem"+File.separator;
File.makeDirectory(myDir0);

myDir4 = savedir+"High_background_cannot_segment"+File.separator;
File.makeDirectory(myDir4);

logsum=getInfo("log");
File.saveString(logsum, filepath);

mask=savedir+"Mask"+File.separator;
File.makeDirectory(mask);

ID20xMIP=0;

FilePathArray=newArray(Frontal50pxPath, "JFRC2010_60pxMedP.tif");
fileOpen(FilePathArray);
Frontal50pxPath=FilePathArray[0];

FilePathArray=newArray(LateralMIPPath, "Lateral_JFRC2010_5time_smallerMIP.tif");
fileOpen(FilePathArray);
LateralMIPPath=FilePathArray[0];

FilePathArray=newArray(Slice50pxPath, "JFRC2010_50pxSlice.tif");
fileOpen(FilePathArray);
Slice50pxPath=FilePathArray[0];

FilePathArray=newArray(ShapeMatchingMaskPath, "JFRC2010_ShapeMatchingMask.tif");
fileOpen(FilePathArray);
ShapeMatchingMaskPath=FilePathArray[0];

if(comparisonP=="Average"){// average is not good 13D08
	JFRC2010MedProPath = MatchingFilesDir+"JFRC2010_AvePro.png"; //"JFRC2010_AvePro.png"
	FilePathArray=newArray(JFRC2010MedProPath, "JFRC2010_AvePro.png");
	projectionSt="JFRC2010_AvePro.png";
}
if(comparisonP=="Median"){// good for izoom adjustment, but not good for optic lobe detection
	JFRC2010MedProPath = MatchingFilesDir+"JFRC2010_MedPro.tif"; //"JFRC2010_AvePro.png"
	FilePathArray=newArray(JFRC2010MedProPath, "JFRC2010_MedPro.tif");
	projectionSt="JFRC2010_MedPro.tif";
}

if(comparisonP=="Max"){
	JFRC2010MedProPath = MatchingFilesDir+"JFRC2010_MIP.tif"; //"JFRC2010_AvePro.png"
	FilePathArray=newArray(JFRC2010MedProPath, "JFRC2010_MIP.tif");
	projectionSt="JFRC2010_MIP.tif";
}

fileOpen(FilePathArray);
JFRC2010MedProPath=FilePathArray[0];

noext2=0;
print("JFRC2010MedProPath; "+JFRC2010MedProPath);

///// Duplication check //////////////////////////////////////////////////////////////

filepathcolor=0; 
NRRD_02_ext=0; 



List.clear();

beforeopen=getTime();
print("path; "+path);

if(endsWith(path,"/")!=1){
	if(endsWith(path,"lif")!=1 && endsWith(path,".oif")!=1 && endsWith(path,".czi")!=1)
	open(path);// for tif, comp nrrd, lsm", am, v3dpbd, mha
	else{
		print("using loci");
		run("Bio-Formats Macro Extensions");
		Ext.openImagePlus(path);
		//run("Bio-Formats Windowless Importer", "open="+path+"");
	}
}else{
	print("this is not confocal file");
	logsum=getInfo("log");
	File.saveString(logsum, filepath);
	newImage("Untitled", "8-bit black", 512, 512, 1);
	run("quit plugin");
}
afteropen=getTime();

oriname=getTitle();

rename("ThreeD_stack.tif");
fileopentime=(afteropen-beforeopen)/1000;
print("file open time; "+fileopentime+" sec");

logsum=getInfo("log");
File.saveString(logsum, filepath);

starta=getTime();
getDimensions(width, height, channels, slices, frames);
getVoxelSize(VxWidth, VxHeight, VxDepth, VxUnit);
print("File vx size; VxWidth; "+VxWidth+"  VxHeight; "+VxHeight+"   VxDepth; "+VxDepth);

stackthickness=slices*VxDepth;
if(stackthickness<90 || stackthickness>200){
	fiedZ=140/slices;
	print("The stack is too thin, fixed z vx size from "+VxDepth+" to "+fiedZ);
	
	run("Properties...", "channels="+channels+" slices="+slices+" frames=1 unit=microns pixel_width="+VxWidth+" pixel_height="+VxHeight+" voxel_depth="+fiedZ+"");
	getVoxelSize(VxWidth, VxHeight, VxDepth, VxUnit);
	
	
}


if(forceVxSize=="false" || forceVxSize==false){
	Ori_widthVx=VxWidth;
	widthVx=VxWidth;
	Ori_heightVx=VxHeight;
	depth=VxDepth;
	print("forceVxSize=false, then Real voxel size is file vx size; Ori_widthVx; "+Ori_widthVx+"  depth; "+depth);
}



//if(Ori_widthVx>0.43 && objective=="40x" && Ori_widthVx<0.46){
//	print("40x vx size changed!! from "+Ori_widthVx+" to 0.4713");
//	Ori_widthVx = 0.4713;
//	Ori_heightVx = 0.4713;
//	widthVx = Ori_widthVx;
//	heightVx = Ori_heightVx;

//	run("Properties...", "channels="+channels+" slices="+nSlices/channels+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+depth+"");
//}else
run("Properties...", "channels="+channels+" slices="+nSlices/channels+" frames=1 unit=microns pixel_width="+widthVx+" pixel_height="+widthVx+" voxel_depth="+depth+"");

cropWidth=round(800/Ori_widthVx);
cropHeight=round(400/Ori_heightVx);

print("cropWidth; "+cropWidth+"   cropHeight; "+cropHeight);
print(bitDepth+" bit");



if(width<height)
longlength=height;
else
longlength=width;

if(channels==2 || channels==3 || channels==4)
run("Split Channels");

print("channels; "+channels);

logsum=getInfo("log");
File.saveString(logsum, filepath);

//if(channels==1 && nSlices>240){
//	roundSlices = round(nSlices/4);
//	actualSlice = nSlices/4;

//	while(roundSlices!=actualSlice){
//		setSlice(nSlices);
//		run("Delete Slice");
//		actualSlice = nSlices/4;
//	}
//	run("Stack to Hyperstack...", "order=xyczt(default) channels=4 slices="+nSLices/4+" frames=1 display=Composite");
//	getDimensions(width, height, channels, slices, frames);
//	run("Split Channels");
//}

if(channels==1 && nSlices<240){
	print("PreAlignerError: There are no signal channels");
	
	logsum=getInfo("log");
	File.saveString(logsum, filepath);
	
	run("Quit");
	newImage("Untitled", "8-bit black", 512, 512, 1);
	run("quit plugin");
}

posicolorNum=0;
titlelist=getList("image.titles");
signal_count = 0; neuron2=0; neuron3=0;
neuron=newArray(titlelist.length);
UnknownChannel=newArray(titlelist.length);
posicolor=newArray(titlelist.length);
Original3D=newArray(titlelist.length);

for (iCh=0; iCh<titlelist.length; iCh++) {
	selectWindow(titlelist[iCh]);
	
	if(forceUPdown==1){
		run("Rotation Hideo headless", "rotate=180 3d in=InMacro interpolation=NONE cpu="+NumCPU+"");
	}

	
	if(nSlices>1){
		
		if(forceAPinv==1){
			run("Reverse");
			run("Flip Horizontally", "stack");
		}
		//	cc = substring(chanspec,iCh,iCh+1);
		print("titlelist[iCh]; "+titlelist[iCh]);
		UnknownChannel[posicolorNum]=getImageID();
		posicolorNum=posicolorNum+1;
	}
}//for (i=0; i<lengthOf(chanspec); i++) {

logsum=getInfo("log");
File.saveString(logsum, filepath);

if(channels>1){
	
	mean10=0; mean20=0; mean30=0; mean40=0; maxmean=-1;
	if(nc82decision=="Signal_amount"){
		
		selectImage(UnknownChannel[0]);
		run("Z Project...", "projection=[Sum Slices]");
		avetest0=getImageID();
		getStatistics(area, mean10, min, max, std, histogram);
		maxmean=mean10;
		close();
		
		selectImage(UnknownChannel[1]);
		run("Z Project...", "projection=[Sum Slices]");
		avetest1=getImageID();
		getStatistics(area, mean20, min, max, std, histogram);
		if(maxmean<mean20)
		maxmean=mean20;
		close();
		
		if(channels>=3){
			selectImage(UnknownChannel[2]);
			run("Z Project...", "projection=[Sum Slices]");
			avetest2=getImageID();
			getStatistics(area, mean30, min, max, std, histogram);
			if(maxmean<mean30)
			maxmean=mean30;
			close();
		}
		
		if(channels==4){
			selectImage(UnknownChannel[3]);
			run("Z Project...", "projection=[Sum Slices]");
			avetest3=getImageID();
			getStatistics(area, mean40, min, max, std, histogram);
			if(maxmean<mean40)
			maxmean=mean40;
			close();
		}
	}//	if(nc82decision=="Signal_amount"){
	refchannel=0;
	if(maxmean==mean10 || nc82decision=="ch1"){
		selectImage(UnknownChannel[0]);
		nc82=getImageID();
		
		selectImage(UnknownChannel[1]);
		neuron=getImageID();
		
		if(channels>=3){
			selectImage(UnknownChannel[2]);
			neuron2=getImageID();
		}
		if(channels==4){
			selectImage(UnknownChannel[3]);
			neuron3=getImageID();
		}
		refchannel=1;
		print("ch1 is reference");
	}else if (maxmean==mean20 || nc82decision=="ch2"){
		selectImage(UnknownChannel[1]);
		nc82=getImageID();
		
		selectImage(UnknownChannel[0]);
		neuron=getImageID();
		
		if(channels>=3){
			selectImage(UnknownChannel[2]);
			neuron2=getImageID();
		}
		if(channels==4){
			selectImage(UnknownChannel[3]);
			neuron3=getImageID();
		}
		refchannel=2;
		print("ch2 is reference");
	}else if (maxmean==mean30 || nc82decision=="ch3"){
		selectImage(UnknownChannel[2]);
		nc82=getImageID();
		
		selectImage(UnknownChannel[0]);
		neuron=getImageID();
		
		selectImage(UnknownChannel[1]);
		neuron2=getImageID();
		
		if(channels==4){
			selectImage(UnknownChannel[3]);
			neuron3=getImageID();
		}
		refchannel=3;
		print("ch3 is reference");
	}else if (maxmean==mean40 || nc82decision=="ch4"){
		selectImage(UnknownChannel[3]);
		nc82=getImageID();
		
		selectImage(UnknownChannel[0]);
		neuron=getImageID();
		
		selectImage(UnknownChannel[1]);
		neuron2=getImageID();
		
		selectImage(UnknownChannel[2]);
		neuron3=getImageID();
		print("ch4 is reference");
		refchannel=4;
	}
}//if(channels>1){

//selectImage(nc82);
//setBatchMode(false);
//		updateDisplay();
//		"do"
//		exit();





maxvalue0=255;

if(channels!=1){
	selectImage(nc82);
	NC82SliceNum=nSlices();
	
}

if(bitDepth==16)
maxvalue0=65535;

maxsizeData=0; SizeM=0;

ID20xMIP=0; positiveAR=0; lowerM=3; threTry=0; prelower=0; finalMIP=0; ABSMaxARShape=0; ABSmaxSize=0;
maxARshape=1.7; ABSmaxCirc=0; MaxOBJScore=0; MaxRot=0; angle=400;

elipsoidArea = 0;//area of mask
elipsoldAngle = 0;//angle of mask
numberResults=0; mask1st=0; shortARshapeGap=0;

selectImage(nc82);
rename("nc82.tif");
bitd=bitDepth();

if(bitDepth==8)
run("16-bit");

if(comparisonP=="Median")
run("Z Project...", "start=10 stop="+nSlices-10+" projection=Median");

if(comparisonP=="Max")
run("Z Project...", "start=10 stop="+nSlices-10+" projection=[Max Intensity]");

run("Enhance Contrast", "saturated=0.35");

if(comparisonP=="Median")
run("16-bit");

run("Apply LUT");
run("8-bit");
saveAs("PNG", ""+savedir+noext+"_"+comparisonP+"01.png");
close();
selectWindow("nc82.tif");

run("Duplicate...", "title=nc82_Ori.tif duplicate");
selectWindow("nc82.tif");

ZoomratioSmall=Ori_widthVx/6.2243;
Zoomratio=Ori_widthVx/0.62243;
if(Zoomratio>0.99 && Zoomratio<1.01)
Zoomratio=1;

xcenter=round(getWidth/2); ycenter=round(getHeight/2);

DupAvePprocessing (nc82,NumCPU,bitd,projectionSt);// DUPaveP.tif creation from nc82.tif

selectWindow("DUPaveP.tif");

//setBatchMode(false);
//	updateDisplay();
//	"do"
//	exit();


print("443 nImages; "+nImages);
print("492 ZoomratioSmall; "+ZoomratioSmall+"   widthVx; "+widthVx+"  round(getWidth*ZoomratioSmall); "+round(getWidth*ZoomratioSmall)+"   Zoomratio; "+Zoomratio);
run("Size...", "width="+round(getWidth*ZoomratioSmall)+" height="+round(getHeight*ZoomratioSmall)+" depth=1 constrain interpolation=None");
run("Canvas Size...", "width=102 height=102 position=Center zero");

if(isOpen(projectionSt)==0)
open(JFRC2010MedProPath);

print("499 nImages; "+nImages);
//setBatchMode(false);
//	updateDisplay();
//	"do"
//	exit();

rotSearch=70; 	MaxZoom=1; 	setForegroundColor(0, 0, 0);
ImageAligned=0;

if(objective=="40x")
BrainShape="Both_OL_missing (40x)";

if(BrainShape=="Intact" || BrainShape=="Unknown"){
	ImageCarray=newArray(0, 0, 0, 0);
	ImageCorrelation2 ("DUPaveP.tif", projectionSt, rotSearch+124,ImageCarray,85,NumCPU,1,PNGsave);
	
	OBJScoreOri=ImageCarray[0];
	OriginalRot=ImageCarray[1];
	OriginalYshift=ImageCarray[2];
	OriginalXshift=ImageCarray[3];
	
	maxX=OriginalXshift/2;
	maxY=OriginalYshift/2;
	
	OriginalXshift=parseFloat(OriginalXshift);//Chaneg string to number
	OriginalYshift=parseFloat(OriginalYshift);//Chaneg string to number
	
	wholebraindistance=sqrt(OriginalXshift*OriginalXshift+OriginalYshift*OriginalYshift);
	
	print("458 BrainShape; "+BrainShape+"   wholebraindistance; "+wholebraindistance+"   OBJScore; "+OBJScoreOri+"  OriginalRot; "+OriginalRot+"   OriginalXshift; "+OriginalXshift+"   OriginalYshift; "+OriginalYshift);
	
	logsum=getInfo("log");
	File.saveString(logsum, filepath);
	
	if(objective=="20x"){
		ImageCorrelationArray=newArray(nc82, 0,0,0,0,0,0,wholebraindistance);
		ImageCorrelation(ImageCorrelationArray,Ori_widthVx,NumCPU,projectionSt,PNGsave,BrainShape);// with zoom adjustment, it was widthVx
		ImageAligned=ImageCorrelationArray[1];
		OriginalRot=ImageCorrelationArray[4];
		OBJScoreOri=ImageCorrelationArray[5];
		MaxZoom=ImageCorrelationArray[6];
		OriginalXshift = ImageCorrelationArray[2];
		OriginalYshift = ImageCorrelationArray[3];
		MaxZoom=parseFloat(MaxZoom);//Chaneg string to number
		MaxZoomgap=abs(MaxZoom-1);
		OriginalRot=OriginalRot*-1;
		
		if(MaxZoom!=1){
			print("MaxZoom is not 1; "+MaxZoom);
			nc82Ori=0;
			DupPcreationAndbasicTransArray=newArray(widthVx, heightVx, Ori_widthVx, Ori_heightVx, ZoomratioSmall, Zoomratio, nc82, nc82Ori, OBJScoreOri,OriginalRot,OriginalYshift,OriginalXshift,maxX,maxY);
			DupPcreationAndbasicTrans (MaxZoom,DupPcreationAndbasicTransArray, NumCPU, bitd, rotSearch,1);
			
			nc82=DupPcreationAndbasicTransArray[6];
			nc82Ori=DupPcreationAndbasicTransArray[7];
			OBJScoreOri=DupPcreationAndbasicTransArray[8];
			//		OriginalRot=DupPcreationAndbasicTransArray[9];
			//		OriginalYshift=DupPcreationAndbasicTransArray[10];
			//		OriginalXshift=DupPcreationAndbasicTransArray[11];
			//		maxX=DupPcreationAndbasicTransArray[12];
			//		maxY=DupPcreationAndbasicTransArray[13];
			
			print("   OBJScore after Zoom; "+OBJScoreOri+"  OriginalRot; "+OriginalRot);	
		}//if(MaxZoom!=1){
		
		maxX=OriginalXshift/2;
		maxY=OriginalYshift/2;
		
	}//if(objective=="20x"){
	
	finalshiftX=round((OriginalXshift/ZoomratioSmall)*MaxZoom);
	finalshiftY=round((OriginalYshift/ZoomratioSmall)*MaxZoom);
	print("MaxZoom; "+MaxZoom+"   widthVx; "+Ori_widthVx+"   heightVx; "+Ori_heightVx+"   Zoomratio; "+Zoomratio+"  finalshiftX; "+finalshiftX+"  finalshiftY; "+finalshiftY);
}//	if(BrainShape=="Intact" || BrainShape=="Unknown"){

if(BrainShape=="Unknown"){
	
	opticlobecheckArray = newArray(OBJScoreOri, BrainShape, OriginalXshift, OriginalYshift,finalshiftX,finalshiftY,0,0,0,0);
	opticlobecheck (rotSearch,NumCPU,opticlobecheckArray,1,JFRC2010MedProPath);
	
	
	BrainShape = opticlobecheckArray[1];
	//	SizeM = opticlobecheckArray[6];
	//	finalMIP = opticlobecheckArray[7];
	//	ID20xMIP = opticlobecheckArray[8];
	
	finalMIP="Max projection";
	SizeM=1; 
	//	BrainShape ="Intact";
	ID20xMIP = 1;
	
	
}//if(BrainShape=="Unknown"){

MaxZoomgap=abs(MaxZoom-1);

heightVx=heightVx*MaxZoom;
widthVx=widthVx*MaxZoom;

Ori_widthVx=Ori_widthVx*MaxZoom;
Ori_heightVx=Ori_heightVx*MaxZoom;

reversetoOne=0;

if(BrainShape!="Intact" && MaxZoom!=1 && reversetoOne==1){
	
	backzoom=1/MaxZoom;
	MaxZoom=1;
	
	
	selectWindow(projectionSt);
	close();
	open(JFRC2010MedProPath);
	
	
	print("MaxZoom is change back to 1, due to "+BrainShape+" shape;   backzoom; "+backzoom);
	DupPcreationAndbasicTransArray=newArray(widthVx, heightVx, Ori_widthVx, Ori_heightVx, ZoomratioSmall, Zoomratio, nc82, nc82Ori, OBJScoreOri,OriginalRot,OriginalYshift,OriginalXshift,maxX,maxY);
	DupPcreationAndbasicTrans (backzoom,DupPcreationAndbasicTransArray, NumCPU, bitd, rotSearch,2);
	
	widthVx=DupPcreationAndbasicTransArray[0];
	heightVx=DupPcreationAndbasicTransArray[1];
	Ori_widthVx=DupPcreationAndbasicTransArray[2];
	Ori_heightVx=DupPcreationAndbasicTransArray[3];
	ZoomratioSmall=DupPcreationAndbasicTransArray[4];
	Zoomratio=DupPcreationAndbasicTransArray[5];
	nc82=DupPcreationAndbasicTransArray[6];
	nc82Ori=DupPcreationAndbasicTransArray[7];
	OBJScoreOri=DupPcreationAndbasicTransArray[8];
	OriginalRot=DupPcreationAndbasicTransArray[9];
	OriginalYshift=DupPcreationAndbasicTransArray[10];
	OriginalXshift=DupPcreationAndbasicTransArray[11];
	maxX=DupPcreationAndbasicTransArray[12];
	maxY=DupPcreationAndbasicTransArray[13];
	
	
	opticlobecheckArray = newArray(OBJScoreOri, 0, 0, 0,0,0,0,0,0,0);
	opticlobecheck (rotSearch,NumCPU,opticlobecheckArray,2,JFRC2010MedProPath);
	
	OBJScoreOri = opticlobecheckArray[0];
	BrainShape = opticlobecheckArray[1];
	//	OriginalXshift = opticlobecheckArray[2];
	//	OriginalYshift = opticlobecheckArray[3];
	//	finalshiftX = opticlobecheckArray[4];
	//	finalshiftY = opticlobecheckArray[5];
	SizeM = opticlobecheckArray[6];
	finalMIP = opticlobecheckArray[7];
	ID20xMIP = opticlobecheckArray[8];
	OriginalRot = opticlobecheckArray[9];
}

if(BrainShape=="Both_OL_missing (40x)"){
	selectWindow(projectionSt);
	makePolygon(17,31,22,42,31,51,37,65,31,79,14,79,2,74,2,54,1,38);//L-OL elimination
	run("Fill", "slice");
	
	makePolygon(82,34,74,52,66,65,69,76,90,80,99,72,101,58,100,34);// elimination of the R-Op
	run("Fill", "slice");
	ImageCarray=newArray(0, 0, 0, 0);
	ImageCorrelation2 ("DUPaveP.tif", projectionSt, rotSearch,ImageCarray,80,NumCPU,6,PNGsave);
	
	OBJScoreOri=ImageCarray[0];
	OriginalRot=ImageCarray[1];
	OriginalYshift = ImageCarray[2];
	OriginalXshift = ImageCarray[3];
	print("654 OBJScoreBoth; "+OBJScoreOri);
	
	maxX=OriginalXshift;
	maxY=OriginalYshift;
	
	finalshiftX=round((OriginalXshift/ZoomratioSmall)/2);
	finalshiftY=round((OriginalYshift/ZoomratioSmall)/2);
	
	OriginalXshift=parseFloat(OriginalXshift);
	OriginalYshift=parseFloat(OriginalYshift);//Chaneg string to number
	
	wholebraindistance=sqrt(OriginalXshift*OriginalXshift+OriginalYshift*OriginalYshift);
	
	//setBatchMode(false);
	//	updateDisplay();
	//	"do"
	//	exit();
	print("691; wholebraindistance; "+wholebraindistance);
	ImageCorrelationArray=newArray(nc82, 0,0,0,0,0,0,wholebraindistance);
	ImageCorrelation(ImageCorrelationArray,Ori_widthVx,NumCPU,projectionSt,PNGsave,BrainShape);// with zoom adjustment, it was widthVx
	ImageAligned=ImageCorrelationArray[1];
	OriginalRot=ImageCorrelationArray[4];
	OriginalRot=OriginalRot*-1;
	//		OBJScoreOri=ImageCorrelationArray[5];
	MaxZoom=ImageCorrelationArray[6];
	OriginalXshift = ImageCorrelationArray[2];
	OriginalYshift = ImageCorrelationArray[3];
	
	ImageAligned2=ImageAligned;
	MaxZoom=parseFloat(MaxZoom);//Chaneg string to number
	
	if(MaxZoom!=1){
		
		//	Ori_widthVx=Ori_widthVx*MaxZoom;
		//	Ori_heightVx=Ori_heightVx*MaxZoom;
		
		print("682 MaxZoom is not 1; "+MaxZoom);
		nc82Ori=0;
		DupPcreationAndbasicTransArray=newArray(widthVx, heightVx, Ori_widthVx, Ori_heightVx, ZoomratioSmall, Zoomratio, nc82, nc82Ori, OBJScoreOri,OriginalRot,OriginalYshift,OriginalXshift,maxX,maxY);
		DupPcreationAndbasicTrans (MaxZoom,DupPcreationAndbasicTransArray, NumCPU, bitd, rotSearch,1);
		
		//	widthVx=DupPcreationAndbasicTransArray[0];
		//	heightVx=DupPcreationAndbasicTransArray[1];
		Ori_widthVx=DupPcreationAndbasicTransArray[2];
		Ori_heightVx=DupPcreationAndbasicTransArray[3];
		ZoomratioSmall=DupPcreationAndbasicTransArray[4];
		Zoomratio=DupPcreationAndbasicTransArray[5];
		nc82=DupPcreationAndbasicTransArray[6];
		nc82Ori=DupPcreationAndbasicTransArray[7];
		OBJScoreOri=DupPcreationAndbasicTransArray[8];
		//	OriginalRot=DupPcreationAndbasicTransArray[9];
		//	OriginalYshift=DupPcreationAndbasicTransArray[10];
		//		OriginalXshift=DupPcreationAndbasicTransArray[11];
		maxX=DupPcreationAndbasicTransArray[12];
		maxY=DupPcreationAndbasicTransArray[13];
		
		reverseR=1;
		finalshiftX=round((OriginalXshift/ZoomratioSmall)*MaxZoom);
		finalshiftY=round((OriginalYshift/ZoomratioSmall)*MaxZoom);
		print("MaxZoom; "+MaxZoom+"   widthVx; "+Ori_widthVx+"   heightVx; "+Ori_heightVx+"   Zoomratio; "+Zoomratio);
		print("   OBJScore after Zoom; "+OBJScoreOri+"  OriginalRot; "+OriginalRot+"  finalshiftX; "+finalshiftX+"  finalshiftY; "+finalshiftY);	
	}//if(MaxZoom!=1){
	
	
	ID20xMIP=1;
	finalMIP="Max projection";
	SizeM=1; 
}

//if missing OP, 15-20% bigger




elipsoidAngle=OriginalRot;
OBJScore=OBJScoreOri;
print("");
print("BrainShape; "+BrainShape+"   OBJScore; "+OBJScoreOri+"  OriginalRot; "+OriginalRot+"  finalshiftX; "+finalshiftX+"  finalshiftY; "+finalshiftY+"   maxX; "+maxX+"   maxY; "+maxY);

//setBatchMode(false);
//updateDisplay();
//"do"
//exit();

while(isOpen("DUPaveP.tif")){
	selectWindow("DUPaveP.tif");
	close();
}

if(PNGsave==1)
File.saveString(BrainShape, savedir+"OL_shape_"+noext+"_.txt");
else
File.saveString(BrainShape, savedir+"OL_shape.txt");

while(isOpen("OriginalProjection.tif")){
	selectWindow("OriginalProjection.tif");
	close();
}

run("Set Measurements...", "area centroid center perimeter fit shape redirect=None decimal=2");
print("Zoomratio; "+Zoomratio);

if(BrainShape=="Intact"){
	firstTime=0; MaxShiftY=-1000; MaxShiftX=-1000;
	
	if(opticlobeMASKcheck!=0){
		for(MIPstep=1; MIPstep<3; MIPstep++){// Segmentation of the brain
			endthre=0; lowestthre=100000; maxARshapeGap=100000; maxThreTry=100; MaxCirc=0.18; 
			for(ThreTry=0; ThreTry<=maxThreTry; ThreTry++){
				
				showStatus("Brain rotation");
				selectImage(nc82);
				
				//	setBatchMode(false);
				//		updateDisplay();
				//		"do"
				//exit();
				
				if(ThreTry>0){
					selectImage(OriginalProjection);
					
					
				}else if(ThreTry==0){
					if(MIPstep==1)
					run("Z Project...", "start=10 stop="+nSlices-10+" projection=[Average Intensity]");// imageID is AR
					else if(MIPstep==2)
					run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Max Intensity]");// imageID is AR
					
					//		run("Minimum...", "radius=5");
					//		run("Maximum...", "radius=5");
					
					rename("OriginalProjection.tif");
					OriginalProjection=getImageID();
				}
				
				
				selectWindow("OriginalProjection.tif");
				run("Duplicate...", "title=DUPprojection.tif");// for Masking
				DUPprojection=getImageID();
				
				//	print("Line 700");
				//			setBatchMode(false);
				//			updateDisplay();
				//			aa
				
				if(ThreTry>3){
					
					lowestthre=lowestthre+increment16bit;
					
					setThreshold(lowestthre, maxvalue0);
					setForegroundColor(255, 255, 255);
					setBackgroundColor(0, 0, 0);
					run("Make Binary", "thresholded remaining");
					
					//	run("Fill Holes");
					
					if(firstTime==1)
					ThreTry=maxThreTry+1;
					
				}else{
					
					run("8-bit");
					
					if(ThreTry==0)
					setAutoThreshold("Triangle dark");
					else if(ThreTry==1)
					setAutoThreshold("Default dark");
					else if(ThreTry==2)
					setAutoThreshold("Huang dark");
					else if(ThreTry==3)
					setAutoThreshold("Percentile dark");
					
					getThreshold(lower, upper);
					setThreshold(lower, maxvalue0);
					print("MIPstep; "+MIPstep+"   ThreTry; "+ThreTry+"   "+lower+"  lower");
					
					//			setOption("BlackBackground", true);
					
					setForegroundColor(255, 255, 255);
					setBackgroundColor(0, 0, 0);
					run("Make Binary", "thresholded remaining");
					
					//			run("Fill Holes");
					
					//		if(ThreTry==2){
					//			setBatchMode(false);
					//			updateDisplay();
					//			aa
					//		}
					
					if(lowestthre>lower)
					lowestthre=lower;
					
					if(endthre<lower)
					endthre=lower;
					
					if(ThreTry==3){
						maxThreTry=100;
						increment16bit=(endthre-lowestthre)/100;
						increment16bit=round(increment16bit);
						
						if(increment16bit<1)
						increment16bit=1;
						
						print("MIPstep; "+MIPstep+"   Gap thresholding; from "+lowestthre+" to "+endthre+" Gap; "+endthre-lowestthre+"  increment16bit; "+increment16bit);
					}//	if(ThreTry==3){
				}//	if(ThreTry>3){
				
				run("Minimum...", "radius=5");
				run("Maximum...", "radius=5");
				
				//		setBatchMode(false);
				//		updateDisplay();
				//		aa
				
				//	print("Line 781");
				run("Analyze Particles...", "size="+round((100000*MaxZoom)*Zoomratio)+"-Infinity display exclude clear");
				
				updateResults();
				maxsizeData=0;
				
				//	if(ThreTry==2){
				//		setBatchMode(false);
				//		updateDisplay();
				//		aa
				//	}
				
				if(getValue("results.count")>0){
					numberResults=getValue("results.count");	 ARshape=0;
					
					for(inn=0; inn<getValue("results.count"); inn++){
						maxsize0=getResult("Area", inn);
						print("maxsize0; "+maxsize0);
						
						if(maxsize0>maxsizeData){
							ARshape=getResult("AR", inn);// AR value from Triangle
							Anglemax=getResult("Angle", inn);
							Circ=getResult("Circ.", inn);
							Circ=parseFloat(Circ);//Chaneg string to number
							//		print(Circ+" Circ");
							maxsizeData=maxsize0;
							
							
							ixcenter=getResult("X", inn);
							iycenter=getResult("Y", inn);
							
							//					print("maxsizeData; "+maxsizeData+"   ARshape; "+ARshape);
						}
					}//for(inn=0; inn<nResults; inn++){
					
					if(ABSMaxARShape<ARshape){
						ABSMaxARShape=ARshape;
						
						ABSmaxSize=maxsizeData;
						ABSmaxCirc=Circ;
					}
					print("maxsizeData; "+maxsizeData+"   (130000*MaxZoom)*Zoomratio; "+(100000*MaxZoom)*Zoomratio+"   MaxZoom; "+MaxZoom+"   Zoomratio; "+Zoomratio);
					
					if(PNGsave==1){
						saveAs("PNG", ""+savedir+noext+"_Mask_ThreTry"+ThreTry+"_MIPstep_"+MIPstep+"_maxsizeData_"+maxsizeData+".png");
						rename("DUPprojection.tif");
					}
					if(maxsizeData>(100000*MaxZoom)*Zoomratio && maxsizeData<(570000*MaxZoom)*Zoomratio && ARshape>1.3){
						
						selectWindow("DUPprojection.tif");// binary mask
						
						//			setBatchMode(false);
						//					updateDisplay();
						//					aa
						
						run("Size...", "width="+round(getWidth*ZoomratioSmall*MaxZoom)+" height="+round(getHeight*ZoomratioSmall*MaxZoom)+" depth=1 constrain interpolation=None");
						
						run("Canvas Size...", "width=102 height=102 position=Center zero");
						
						//	setBatchMode(false);
						//	updateDisplay();
						//	aa
						
						if(bitDepth==8)
						run("16-bit");
						if(OBJScoreOri>600){
							run("Rotation Hideo headless", "rotate="+OriginalRot+" in=InMacro");
							rotSearch=5;
						}else
						rotSearch=55;
						
						setMinAndMax(0, 255);
						run("Apply LUT");
						run("8-bit");
						
						//					setBatchMode(false);
						//					updateDisplay();
						//					"do"
						//					exit();
						
						
						ImageCarray=newArray(0, 0, 0, 0);
						ImageCorrelation2 ("DUPprojection.tif", "JFRC2010_ShapeMatchingMask.tif", rotSearch,ImageCarray,90,NumCPU,7,PNGsave);
						
						OBJScore=ImageCarray[0];
						Rot=ImageCarray[1];
						ShiftY=ImageCarray[2];
						ShiftX=ImageCarray[3];
						
						print("Line 799, Rot; "+Rot+"   ShiftX; "+ShiftX+"   ShiftY; "+ShiftY+"   OBJScore; "+OBJScore+"  OriginalRot; "+OriginalRot);
						//		print("OBJScore from Image2; "+OBJScore+"   ARshape; "+ARshape +"   Circ; "+Circ);
						
						if(OBJScore>MaxOBJScore){
							MaxOBJScore=OBJScore;
							MaxRot=Rot;
							
							//		if(MaxOBJScore>680){
							//			print("Circ; "+Circ);
							//			print("ARshape; "+ARshape);
							
							//			setBatchMode(false);
							//			updateDisplay();
							//			aa
							//		}
							
							if(ARshape>maxARshape){//&& ARshape>1.7
								if(Circ>MaxCirc-0.04){//0.16 is min
									maxARshape=ARshape;
									
									if(MaxCirc<Circ)
									MaxCirc=Circ;
									
									print("MIPstep; "+MIPstep+"   lower; "+lower+"   maxARshape; "+maxARshape+"   Circ; "+Circ+"   ThreTry; "+ThreTry+"   maxsizeData; "+maxsizeData+"  MaxOBJScore; "+MaxOBJScore);
									
									ID20xMIP=1;
									numberResults=1;
									
									elipsoidAngle = Anglemax;
									
									if (elipsoidAngle>90) 
									elipsoidAngle = -(180 - elipsoidAngle);
									
									if (MIPstep==1)
									finalMIP="Ave projection";
									
									if (MIPstep==2)
									finalMIP="Max projection";
									
									MaxShiftY=ShiftY;
									MaxShiftX=ShiftX;
									
									positiveAR=0; firstTime=1;
									lowerM=lower; threTry=ThreTry; angle=elipsoidAngle; SizeM=maxsizeData;
									
									xcenter=ixcenter; ycenter=iycenter;
									//		if(MIPstep==2){
									//			setBatchMode(false);
									//			updateDisplay();
									//			"do"
									//			exit();
									//		}
									
								}else{
									positiveAR=positiveAR+1;
								}
							}//	if(ARshape>maxARshape){//&& ARshape>1.7
						}
					}else{
						
						positiveAR=positiveAR+1;
					}//if(maxsizeData>250000 && maxsizeData<470000){
				}else{
					positiveAR=positiveAR+1;
					
				}//if(nResults>0){
				
				if(positiveAR>=40){
					if(firstTime==1)
					ThreTry=maxThreTry+1;
				}
				
				if(firstTime==1 && ThreTry>3)
				ThreTry=maxThreTry+1;
				
				while(isOpen(DUPprojection)){
					selectImage(DUPprojection);
					close();
				}
				while(isOpen("DUPprojection.tif")){
					selectWindow("DUPprojection.tif");
					close();
				}
				
				
				//			titlelist=getList("image.titles");
				//			for(iImage=0; iImage<titlelist.length; iImage++){
				//				print("Opened; "+titlelist[iImage]);
				//			}
				
				
				//		if(titlelist.length>channels+2){
				//				for(iImage=0; iImage<titlelist.length; iImage++){
				//					if(channels==2){
				//						if(titlelist[iImage]!=Original3D[0] && titlelist[iImage]!=Original3D[1] && titlelist[iImage]!=Original3D[2] && titlelist[iImage]!="OriginalProjection.tif"){
				//							selectWindow(titlelist[iImage]);
				//							close();
				//						print("Closed; "+titlelist[iImage]);
				//					}
				//					}//if(channels==2){
				
				//					}
				//				}//	if(titlelist.length>channels){
			}//for(ThreTry=0; ThreTry<3; ThreTry++){
			
			if(lowerM!=3 && prelower!=lowerM){
				print("MIPstep; "+MIPstep+"   lowerM; "+lowerM+"   threTry; "+threTry+"   angle; "+angle+"   SizeM; "+SizeM+"   maxARshape; "+maxARshape+"  MaxCirc; "+MaxCirc+"   ID20xMIP; "+ID20xMIP);
				prelower=lowerM;
			}
			while(isOpen(OriginalProjection)){
				selectImage(OriginalProjection);
				close();
			}
		}//for(MIPstep=1; MIPstep<3; MIPstep++){
	}//if(opticlobeMASKcheck!=0){
	if(OBJScoreOri>600 || angle==400)// angle ==400 is initial setting, could not detect the brain in the mask process
	elipsoidAngle=OriginalRot;
	else
	elipsoidAngle=angle;
	
	//OriginalXshift=OriginalXshift+MaxShiftX;
	//OriginalYshift=OriginalYshift+MaxShiftY;
	
	if(opticlobeMASKcheck!=0)
	print("MaxOBJScore; "+MaxOBJScore+"   MaxMaskRot; "+angle+MaxRot+"  TrueShiftY; "+MaxShiftY+"  TrueShiftX; "+MaxShiftX+"  lowerM; "+lowerM+"  best threTry; "+threTry+"   SizeM; "+SizeM);
}else{//if(BrainShape=="Intact"){ // if brain is not intact
	//	maxY = OriginalYshift/2;
	//	maxX = OriginalXshift/2;
	
	//	finalshiftX=round(maxX*20*Zoomratio);
	//	finalshiftY=round(maxY*20*Zoomratio);
	ID20xMIP=1;
	ImageAligned=1;// this means, xy shift + rotation are already known
	finalMIP="Max projection";
	SizeM=1; 
}//	if(BrainShape=="Intact"){
if(ID20xMIP==0 && opticlobeMASKcheck!=0){
	print("could not segment by normal method, ImageAligned; "+ImageAligned+"   OBJScoreOri; "+OBJScoreOri);
	/// rescue code with Image correlation ////////////////////////////
	//	ImageCorrelationArray=newArray(nc82, ImageAligned,0,0,0,0,0);
	//	ImageCorrelation (ImageCorrelationArray,Ori_widthVx,NumCPU,projectionSt,PNGsave);
	//	ImageAligned=ImageCorrelationArray[1];
	//		maxX=ImageCorrelationArray[2];
	//		maxY=ImageCorrelationArray[3];
	//		elipsoidAngle=ImageCorrelationArray[4];
	//	OBJScore=ImageCorrelationArray[5];
	
	if(OBJScoreOri>0.7)
	ImageAligned=1;
	
	//	setBatchMode(false);
	//		updateDisplay();
	//		"do"
	//		exit();
	
	if(ImageAligned==1){// if rescued
		
		ID20xMIP=1;
		finalMIP="Max projection";
		SizeM=1; 
		MIPstep=2;
	}else{
		print("AR shape/size is too low, might be no optic lobe; ABSMaxARShape; "+ABSMaxARShape+"  ABSmaxSize; "+ABSmaxSize+"  ABSmaxCirc; "+ABSmaxCirc);
		
		maxY = OriginalYshift/2;
		maxX = OriginalXshift/2;
		finalshiftX=round(maxX*20*Zoomratio);
		finalshiftY=round(maxY*20*Zoomratio);
		
		ID20xMIP=1;
		finalMIP="Max projection";
		SizeM=1; 
		MIPstep=2;
		
		selectImage(nc82);
		run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Max Intensity]");
		run("Grays");
		resetMinAndMax();
		run("8-bit");
		saveAs("PNG", ""+myDir0+noext+"_MaxAR_"+ABSMaxARShape+"_Shape.png");//save 20x MIP mask
		saveAs("PNG", ""+mask+noext+"_MaxAR_"+ABSMaxARShape+"_Shape.png");//save 20x MIP mask
		saveAs("PNG", ""+savedir+noext+"_MaxAR_Shape.png");
		close();
		
		print("PreAlignerError: Shape problem of the brain");
	}//if(ImageAligned==1){// if rescued
}//if(ID20xMIP==0 && opticlobeMASKcheck!=0){
logsum=getInfo("log");
File.saveString(logsum, filepath);
if(NRRD_02_ext==1 || nrrdEx==true){
	ID20xMIP=1;
	SizeM=1;
}

if(SizeM!=0){
	if(ID20xMIP!=0){// AR shape is more than 1.7
		x1_opl=0; x2_opl=0; y1_opl=0; 	resliceLongLength=round(sqrt(height*height+width*width));
		print("elipsoidAngle; "+elipsoidAngle);
		OpticLobeSizeGap=60000*Zoomratio*MaxZoom; sizediff2=0; sizediff1=0; 
		
		if(opticlobeMASKcheck!=0){
			if(NRRD_02_ext==0){
				
				if(BrainShape=="Intact"){
					MIPstep=1;
					if(finalMIP=="Max projection")
					MIPstep=2;
					
					print("   finalMIP; "+finalMIP+"   MIPstep; "+MIPstep+"   ImageAligned; "+ImageAligned);
					
					selectImage(nc82);
					
					if(MIPstep==1)
					run("Z Project...", "start=10 stop="+nSlices-10+" projection=[Average Intensity]");// imageID is AR
					else if(MIPstep==2)
					run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Max Intensity]");// imageID is AR
					
					MIP2nd=getImageID();
					NewID20xMIPgeneration=0;
					
					if(ImageAligned==0){ // brain shape is intact
						print("lowerM; final "+lowerM);
						run("8-bit");
						
						logsum=getInfo("log");
						File.saveString(logsum, filepath);
						
						setThreshold(lowerM, maxvalue0);
						setForegroundColor(255, 255, 255);
						setBackgroundColor(0, 0, 0);
						run("Make Binary", "thresholded remaining");
						
						run("Minimum...", "radius=5");// previously size was 5, 5 gives me lower thresholding value than 2, then 2 can give OL connection this time
						run("Maximum...", "radius=5");
						
						//			setBatchMode(false);
						//			updateDisplay();
						//			"do"
						//			exit();
						
						run("Select All");
						run("Copy");
						
						run("Fill Holes");
						getStatistics(area, meanHole, minHole, maxHole, stdHole, histogramHole);
						
						if(meanHole==0){
							run("Paste");
							run("Grays");
							run("Fill Holes");
						}
						
						if(meanHole==255)
						run("Paste");
						
						
						run("Analyze Particles...", "size="+(100000*MaxZoom)*Zoomratio+"-Infinity show=Masks display clear");//run("Analyze Particles...", "size=200000-Infinity show=Masks display exclude clear");
						ID20xMIP=getImageID();//このマスクを元にしてローテーション、中心座標を得る
						ID20xMIPtitle=getTitle();
						run("Grays");
						
						if(PNGsave==1){
							saveAs("PNG", ""+savedir+noext+"_MIPstep_"+MIPstep+".png");
							rename(ID20xMIPtitle);
						}
						//			setBatchMode(false);
						//						updateDisplay();
						//						"do"
						//						exit();
						
						run("Canvas Size...", "width="+cropWidth+300+" height="+cropWidth+300+" position=Center zero");
						run("Rotate... ", "angle="+elipsoidAngle+" grid=1 interpolation=None enlarge");//Rotate mask to horizontal
						
						AFxsize=getWidth();
						AFysize=getHeight();
						
						run("Size...", "width="+AFxsize*MaxZoom*Zoomratio+" height="+AFysize*MaxZoom*Zoomratio+" constrain interpolation=None");
						run("Canvas Size...", "width="+AFxsize+" height="+AFysize+" position=Center zero");
						run("Properties...", "channels=1 slices=1 frames=1 unit=microns pixel_width=1 pixel_height=1 voxel_depth=1");
						
						print("after rotation; AFxsize; "+AFxsize+"   AFysize; "+AFysize);
						
						ScanMakeBinary ();
						
						//		setBatchMode(false);
						//			updateDisplay();
						//			"do"
						//			exit();
						
						if(getValue("results.count")==0){
							print("PreAlignerError: Could not detect brain mask in line 1120");
							run("Quit");
							newImage("Untitled", "8-bit black", 512, 512, 1);
							run("quit plugin");
						}else{
							
							AnalyzeCArray=newArray(SizeM, 0, 0);
							analyzeCenter(AnalyzeCArray);
							
							xcenter=AnalyzeCArray[1];
							ycenter=AnalyzeCArray[2];
							
							xcenter=round(xcenter);
							ycenter=round(ycenter);
							
							print("CX="+xcenter);
							print("CY="+ycenter);
							
							finalshiftX=round(getWidth/2)-xcenter;
							finalshiftY=round(getHeight/2)-ycenter;
							
							xgapleft=0;
							if(xcenter<=cropWidth/2)
							xgapleft=cropWidth/2-xcenter;
							
							print("finalshiftX; "+round(finalshiftX)+"   round(maxX*MaxZoom*Zoomratio); "+round(maxX*MaxZoom*Zoomratio)+"  finalshiftY; "+round(finalshiftY)+"   round(maxY*20/Zoomratio); "+round(maxY*20/Zoomratio)+"maxX; "+maxX+"   maxY; "+maxY+"  Zoomratio; "+Zoomratio);
							print("1069 cropWidth*Zoomratio*MaxZoom; "+round(cropWidth*Zoomratio*MaxZoom)+"   cropHeight*Zoomratio*MaxZoom; "+round(cropHeight*Zoomratio*MaxZoom)+"   Zoomratio; "+Zoomratio);
							
							
							selectImage(ID20xMIP);
							selectWindow(ID20xMIPtitle);
							
							run("Translate...", "x="+finalshiftX+" y="+finalshiftY+" interpolation=None");
							run("Canvas Size...", "width="+round(cropWidth*Zoomratio*MaxZoom)+" height="+round(cropHeight*Zoomratio*MaxZoom)+" position=Center zero");
							
							//				setBatchMode(false);
							//					updateDisplay();
							//				"do"
							//				exit();
							
							run("Duplicate...", "title=DupMask2D.tif");
							DupMask=getImageID();
							
						}//if(getValue("results.count")!=0){
						
						//				setBatchMode(false);
						//				updateDisplay();
						//				"do"
						//				exit();
					}//ImageAligned==0
					
					if(ImageAligned==1){// brain shape not intact
						ID20xMIP=getImageID();//Z projection.. may need threshold to be mask
						ID20xMIPtitle=getTitle();
						NewID20xMIPgeneration = 1;
						
						run("Canvas Size...", "width="+resliceLongLength+" height="+resliceLongLength+" position=Center zero");
						getVoxelSize(LVxWidth, LVxHeight, LVxDepth, LVxUnit);//reslice
						if(bitDepth==8)
						run("16-bit");
						run("Rotation Hideo headless", "rotate="+elipsoidAngle+" in=InMacro");
						
						run("Translate...", "x="+finalshiftX+" y="+finalshiftY+" interpolation=None");
						
						run("Size...", "width="+round(getWidth*Zoomratio*MaxZoom)+" height="+round(getHeight*Zoomratio*MaxZoom)+" depth=1 constrain interpolation=None");
						run("Canvas Size...", "width="+round(cropWidth*Zoomratio*MaxZoom)+" height="+round(cropHeight*Zoomratio*MaxZoom)+" position=Center zero");
						
						run("Properties...", "channels=1 slices=1 frames=1 unit=microns pixel_width=1 pixel_height=1 voxel_depth=1");
						
						run("Duplicate...", "title=DupMask2D.tif");
						DupMask=getImageID();
						
						//		setBatchMode(false);
						//					updateDisplay();
						//					"do"
						//		exit();
						
						xsize=getWidth();
						ysize=getHeight();
					}//if(ImageAligned==1){
					
					
					//			setBatchMode(false);
					//			updateDisplay();
					//			"do"
					//			exit();
					
					ycenterCrop=round((cropHeight*Zoomratio)/2);//(cropHeight/2)-((cropHeight/2)*0.1);
					
					logsum=getInfo("log");
					File.saveString(logsum, filepath);
					
					//		setBatchMode(false);
					//		updateDisplay();
					//		"do"
					//		exit();
					
					run("8-bit");
					setThreshold(1, 255);
					setForegroundColor(255, 255, 255);
					setBackgroundColor(0, 0, 0);
					run("Make Binary", "thresholded remaining");
					//// optic lobe detection //////////////////////////////////////////
					run("Watershed");// clip optic lobe out
					
					run("Analyze Particles...", "size=4000-Infinity display clear");
					updateResults();
					
					//	setBatchMode(false);
					//			updateDisplay();
					//			"do"
					//			exit();
					
					sizeDiffOp= newArray(getValue("results.count")); sizediff1=300000; sizediff2=300000;
					minX1position=10000;
					
					xdistancearray=newArray(getValue("results.count")); ydistancearray=newArray(getValue("results.count")); AreaArray=newArray(getValue("results.count"));
					
					for(xdistance=0; xdistance<getValue("results.count"); xdistance++){// array creation for analyzed objects
						xdistancearray[xdistance]=getResult("X", xdistance);
						ydistancearray[xdistance]=getResult("Y", xdistance);
						AreaArray[xdistance]=getResult("Area", xdistance);
					}
					
					//// optic lobe detection and building OL from smaller segments ///////////////////////////////
					optic1_Xposition_sum=0; optic1_object=0; optic1_Area_sum=0; optic1_Yposition_sum=0;
					optic2_Xposition_sum=0; optic2_object=0; optic2_Area_sum=0; optic2_Yposition_sum=0;
					oticLobe2Area=0; oticLobe1Area=0; sizediff2=0; sizediff1=0;
					
					for(opticL1=0; opticL1<getValue("results.count"); opticL1++){
						
						opticlobe1Gap=abs(xdistancearray[opticL1]-((220/1200)*(cropWidth*Zoomratio*MaxZoom)));//  300 220 is average of left optic lobe central X
						
						opticlobe2Gap=abs(xdistancearray[opticL1]-((950/1200)*(cropWidth*Zoomratio*MaxZoom)));// 920 981 is average of left optic lobe central X
						
						print("opticlobe1Gap; "+opticlobe1Gap+"  120*Zoomratio*MaxZoom; "+120*Zoomratio*MaxZoom+"  Zoomratio; "+Zoomratio+"  MaxZoom; "+MaxZoom+"   cropWidth;"+cropWidth+" xdistancearray[opticL1]; "+xdistancearray[opticL1]);
						print("opticlobe2Gap; "+opticlobe2Gap+"   1/Ori_widthVx; "+1/Ori_widthVx+"  (xdistancearray[opticL1]*(1/Ori_widthVx))"+(xdistancearray[opticL1]*(1/Ori_widthVx)));
						if(opticlobe1Gap<120*Zoomratio*MaxZoom)
						optic1_Area_sum=optic1_Area_sum+AreaArray[opticL1];
						
						
						if(opticlobe2Gap<120*Zoomratio*MaxZoom)
						optic2_Area_sum=optic2_Area_sum+AreaArray[opticL1];
					}
					
					//	setBatchMode(false);
					//	updateDisplay();
					//	"do"
					//	exit();
					
					print("optic1_Area_sum; "+optic1_Area_sum+"  optic2_Area_sum; "+optic2_Area_sum);
					
					for(opticL=0; opticL<getValue("results.count"); opticL++){
						
						opticlobe1Gap=abs(xdistancearray[opticL]-((220/1200)*(cropWidth*Zoomratio*MaxZoom)));//  300 220 is average of left optic lobe central X
						opticlobe2Gap=abs(xdistancearray[opticL]-((950/1200)*(cropWidth*Zoomratio*MaxZoom)));// 920 981 is average of left optic lobe central X
						
						if(opticlobe1Gap<120*Zoomratio*MaxZoom){
							print("opticlobe1Gap; "+opticlobe1Gap);
							
							optic1_Xposition_sum=optic1_Xposition_sum+(xdistancearray[opticL]*(AreaArray[opticL]/optic1_Area_sum));
							
							optic1_Yposition_sum=optic1_Yposition_sum+(ydistancearray[opticL]*(AreaArray[opticL]/optic1_Area_sum));
							
							
							optic1_object=optic1_object+1;
						}
						
						if(opticlobe2Gap<120*Zoomratio*MaxZoom){
							print("opticlobe2Gap; "+opticlobe2Gap);
							optic2_Xposition_sum=optic2_Xposition_sum+(xdistancearray[opticL]*(AreaArray[opticL]/optic2_Area_sum));
							
							optic2_Yposition_sum=optic2_Yposition_sum+(ydistancearray[opticL]*(AreaArray[opticL]/optic2_Area_sum));
							
							
							optic2_object=optic2_object+1;
						}
					}//for(opticL=0; opticL<nResults; opticL++){
					
					x1_opl=optic1_Xposition_sum;
					y1_opl=optic1_Yposition_sum;
					sizediff1=abs(100000*Zoomratio*MaxZoom-optic1_Area_sum);
					
					x2_opl=optic2_Xposition_sum;
					y2_opl=optic2_Yposition_sum;
					sizediff2=abs(100000*Zoomratio*MaxZoom-optic2_Area_sum);
					print("getValue(results.count); "+getValue("results.count"));
					print("oticLobe1Area; "+optic1_Area_sum+"  OL1 is "+optic1_object+" peaces. "+"  oticLobe2Area; "+optic2_Area_sum+"  optic2_Area_sum; "+optic2_Area_sum+"  OL2 is "+optic2_object+" peaces. ");
					ImageAligned2=0; 
					x1_opl=round(x1_opl); x2_opl=round(x2_opl); y1_opl=round(y1_opl); y2_opl=round(y2_opl);
					
					logsum=getInfo("log");
					File.saveString(logsum, filepath);
					
					print("sizediff1; "+sizediff1+"   sizediff2; "+sizediff2+"   OpticLobeSizeGap; "+OpticLobeSizeGap);
					//		setBatchMode(false);
					//		updateDisplay();
					//		"do"
					//		exit();
					
					// if optioc lobe is not exist ///////////////////////////
					if(sizediff2>OpticLobeSizeGap || sizediff1>OpticLobeSizeGap){
						if(BrainShape=="Intact"){		
							print("Optic lobe shape / segmentation problem!!!!!!!!!");
							print("Opticlobe1 size gap; "+sizediff1+"  Opticlobe1 center X,Y; ("+x1_opl+" , "+y1_opl+") / "+ycenterCrop+"  Opticlobe2 size gap; "+sizediff2+"  Opticlobe2 center X,Y; ("+x2_opl+" , "+y2_opl+")");
							
							wait(100);
							call("java.lang.System.gc");
							//		ImageCorrelationArray=newArray(nc82, ImageAligned2,0,0,0,0,0,wholebraindistance);
							//		ImageCorrelation(ImageCorrelationArray,Ori_widthVx,NumCPU,projectionSt,PNGsave,BrainShape);
							//		ImageAligned2=ImageCorrelationArray[1];
							
							print("1399 ImageAligned2; "+ImageAligned2);
							
							logsum=getInfo("log");
							File.saveString(logsum, filepath);
							
							//		maxX=ImageCorrelationArray[2];
							//		maxY=ImageCorrelationArray[3];
							//		elipsoidAngle=ImageCorrelationArray[4];
							ImageAligned=ImageAligned2;// obj score, if more than 0.6, will be 1
							//		OBJScore=ImageCorrelationArray[5];
							
							if(ImageAligned2==0){// if shape problem
								selectImage(DupMask);
								run("Grays");
								
								saveAs("PNG", ""+myDir0+noext+"_OL_Shape_MASK.png");//save 20x MIP mask
								saveAs("PNG", ""+savedir+noext+"_OL_Shape_MASK.png");
								
								selectImage(nc82);
								run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Max Intensity]");// imageID is AR
								MIP2ID=getImageID();
								run("Enhance Contrast", "saturated=0.35");
								getMinAndMax(min, max);
								setMinAndMax(min, max);
								print("max; "+max);
								
								if(max!=maxvalue0 && max!=255)
								run("Apply LUT");
								
								run("8-bit");
								run("Grays");
								saveAs("PNG", ""+myDir0+noext+"_OL_Shape.png");//save 20x MIP mask
								print("PreAlignerError: optic lobe shape problem");
								while(isOpen(MIP2ID)){
									selectImage(MIP2ID);
									close();
								}
								
								y1_opl=cropHeight*2;
								y2_opl=cropHeight;
							}// if(ImageAligned2==0){// if shape problem
							//		selectImage(ID20xMIP);
							//		close();
						}
					}//if(sizediff2>50000 || sizediff1>50000){
					
					while(isOpen(DupMask)){
						selectImage(DupMask);
						close();
					}
					
					while(isOpen(projectionSt)){
						selectWindow(projectionSt);
						close();//projectionSt
					}
					
					if(NewID20xMIPgeneration==0){
						while(isOpen(MIP2nd)){
							selectImage(MIP2nd);
							close();
						}
					}
					
					selectImage(ID20xMIP);
					selectWindow(ID20xMIPtitle);
					if(y1_opl!=cropHeight*2)// if no shape problem
					print("Opticlobe1 size gap; "+sizediff1+"  Opticlobe1 center X,Y; ("+x1_opl+" , "+y1_opl+") / "+ycenterCrop+"  Opticlobe2 size gap; "+sizediff2+"  Opticlobe2 center X,Y; ("+x2_opl+" , "+y2_opl+")");
					
					logsum=getInfo("log");
					File.saveString(logsum, filepath);
					
					//	setBatchMode(false);
					//	updateDisplay();
					//	"do"
					//	exit();
					
					wait(100);
					call("java.lang.System.gc");
					
					/// if brain is upside down /////////////////////////////
					xcenter2=xcenter;
					if(y1_opl<ycenterCrop && y2_opl<ycenterCrop && ImageAligned==0){// if optic lobe is higer position, upside down
						if(bitDepth==8)
						run("16-bit");
						run("Rotation Hideo headless", "rotate=180 in=InMacro");
						print(" 180 rotated");
						
						rotationYN="Yes";
						
						//	run("Translate...", "x="+round(maxX*20/Zoomratio)+" y="+round(maxY*20/Zoomratio)+" interpolation=None");
						
						orizoomratio=Zoomratio;
						if(shrinkTo2010==false)
						Zoomratio=1;
						
						run("Canvas Size...", "width="+round(cropWidth*Zoomratio*MaxZoom)+" height="+round(cropHeight*Zoomratio*MaxZoom)+" position=Center zero");
						
						Zoomratio=orizoomratio;
					}//if(y1_opl<ycenterCrop && y2_opl<ycenterCrop){// if optic lobe is higer position, upside down
					
					
					if(y1_opl!=cropHeight*2){// if no shape problem
						OBJV="";
						if(ImageAligned2==1){
							
							rotateshift3D (resliceLongLength,finalshiftX,Zoomratio*MaxZoom,finalshiftY,elipsoidAngle,shrinkTo2010,cropWidth,cropHeight,Ori_widthVx,Ori_heightVx,depth,reverseR);
							
							OBJV="_"+OBJScore;
						}
						
						path20xmask=mask+noext;
						
						resetMinAndMax();
						run("8-bit");
						print("1593  8bit");
						
						setThreshold(1, 255);
						setForegroundColor(255, 255, 255);
						setBackgroundColor(0, 0, 0);
						run("Make Binary", "thresholded remaining");
						
						run("Watershed");
						run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+widthVx+" pixel_height="+heightVx+" voxel_depth="+depth+"");
						
						run("Grays");
						saveAs("PNG", ""+path20xmask+OBJV+".png");//save 20x MIP mask
						
					}//if(y1_opl!=cropHeight*2){// if no shape problem
					selectImage(ID20xMIP);
					//		selectWindow(ID20xMIPtitle);
					close();// MIP
					//		setBatchMode(false);
					
					logsum=getInfo("log");
					File.saveString(logsum, filepath);
					
					selectImage(nc82);
					wait(100);
					call("java.lang.System.gc");
				}//if(BrainShape=="Intact"){
				
				print("1292");
				//	setBatchMode(false);
				//	updateDisplay();
				//	"do"
				//	exit();
				
				selectImage(nc82);
				print("nc82 selected 1837; "+getTitle());
				
				rotateshift3D (resliceLongLength,finalshiftX,Zoomratio*MaxZoom,finalshiftY,elipsoidAngle,shrinkTo2010,cropWidth,cropHeight,Ori_widthVx,Ori_heightVx,depth,reverseR);
				
				if(ImageAligned==1){
					sizediff2=OpticLobeSizeGap; sizediff1=OpticLobeSizeGap;
				}
				
				resetBrightness(maxvalue0);				
				
				print("nImages 1801; "+nImages);
			}//if(NRRD_02_ext==0){
		}//if(opticlobeMASKcheck!=0){
		if(ChannelInfo=="01 02 nrrd files" || ChannelInfo=="Both formats"){
			
			
			logsum=getInfo("log");
			File.saveString(logsum, filepath);
			
			selectImage(nc82);
			lateralArray=newArray(0, 0,0,0,0,0);
			lateralDepthAdjustment(x1_opl,x2_opl,lateralArray,nc82,templateBr,NumCPU,shrinkTo2010,objective,PNGsave);
			incredepth=lateralArray[0];
			nc82=lateralArray[1];
			maxrotation=lateralArray[2];
			LateralXtrans=lateralArray[3];
			LateralYtrans=lateralArray[4];
			OBJL=lateralArray[5];
			
			LateralYtrans=round(LateralYtrans);
			
			if(widthVx==1 || ForceUSE==true){
				heightVx=DesireX;
				widthVx=DesireX;
				print("Voxel size changed from 1 to "+widthVx);
			}
			
			if(OBJL<500){
				if(templateBr=="JFRC2010" || templateBr=="JFRC2013"){
					incredepth=218/NC82SliceNum;//ADJUSTING sample depth size to template , z=1 micron template
					
					if(TwentyMore!=0)
					incredepth=incredepth*(1+TwentyMore/100);
					print("TwentyMore; "+TwentyMore+"   1+TwentyMore/100; "+1+TwentyMore/100);
					
				}else if(templateBr=="JFRC2014" || templateBr=="JRC2018"){
					
					if(depth!=1){
						tempthinkness=151;
						sampthickness=depth*NC82SliceNum;
						
						incredepth=tempthinkness/sampthickness;//ADJUSTING sample depth size to template 
					}else
					incredepth=(218/NC82SliceNum)*0.69;
					
				}//	if(templateBr=="JFRC2010"){
			}else{//if(OBJL>500){
				
				if(TwentyMore!=0){
					print("TwentyMore; "+TwentyMore+"   1+TwentyMore/100; "+1+TwentyMore/100);
					incredepth=incredepth*(1+TwentyMore/100);
					
				}
			}
			
			String.resetBuffer;
			n3 = lengthOf(noext);
			noext3=noext;
			for (si=0; si<n3; si++) {
				c = charCodeAt(noext, si);
				if(c==32){// if there is a space
					print("There is a space, replaced to _.");
					c=95;
				}
				if (c>=32 && c<=127)
				String.append(fromCharCode(c));
				
				noext3 = String.buffer;
			}//	for (si=0; si<n3; si++) {
			noext=noext3;
			String.resetBuffer;
			
			
			if(NRRD_02_ext==0){
				
				while(isOpen("nc82.tif")){
					selectWindow("nc82.tif");
					close();
				}
				
				wait(100);
				call("java.lang.System.gc");
				
				selectWindow("nc82_Ori.tif");
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+incredepth+"");
				
				//	setBatchMode(false);
				//					updateDisplay();
				//					"do"
				//					exit();
				
				
				if(shrinkTo2010==true){
					VoxSizeADJArray=newArray(Ori_widthVx,Ori_heightVx,incredepth);
					VoxSizeADJ(VoxSizeADJArray,DesireX,objective);
				}
				
				nc82=getImageID();
				print("01 channel; "+resliceLongLength+"   "+finalshiftX+"   "+Zoomratio*MaxZoom+"   "+finalshiftY+"   "+elipsoidAngle+"   "+shrinkTo2010+"   "+cropWidth+"   "+cropHeight+"   "+Ori_widthVx+"   "+Ori_heightVx+"   "+incredepth+"   "+reverseR);
				rotateshift3D (resliceLongLength,finalshiftX,Zoomratio*MaxZoom,finalshiftY,elipsoidAngle,shrinkTo2010,cropWidth,cropHeight,Ori_widthVx,Ori_heightVx,incredepth,reverseR);
				
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width=1 pixel_height=1 voxel_depth=1");
				run("Reslice [/]...", "output=1.000 start=Left rotate avoid");
				rename("resliceN.tif");
				print("Reslice nc82 Done 1967, Not translated lateral, LateralYtrans; "+LateralYtrans+"   LateralXtrans; "+LateralXtrans);
				if(bitDepth==8)
				run("16-bit");
				
				run("Rotation Hideo headless", "rotate="+maxrotation+" 3d in=InMacro");
				//		run("Translate...", "x=0 y="+LateralYtrans+" interpolation=None stack");
				//		print("nc82 Lateral Trans Y; "+LateralYtrans);
				
				run("Reslice [/]...", "output=1 start=Left rotate avoid");
				rename("RealSignal.tif");
				RealSignal=getImageID();
				
				while(isOpen("resliceN.tif")){
					selectWindow("resliceN.tif");
					close();
				}
				
				while(isOpen("nc82_Ori.tif")){
					selectWindow("nc82_Ori.tif");
					close();
				}
				
				wait(100);
				call("java.lang.System.gc");
				
				selectWindow("RealSignal.tif");
				
				print("After reslice; width; "+getWidth()+"   height; "+getHeight()+"   nSlices; "+nSlices);
				
				run("Gamma samewindow noswing", "gamma=1.60 3d in=InMacro cpu="+NumCPU+"");
				nc82=getImageID();
				rename("nc82.tif");
				
				wait(100);
				call("java.lang.System.gc");
				
				if(BrainShape=="Intact" && opticlobeMASKcheck!=0){
					if(y1_opl<ycenterCrop && y2_opl<ycenterCrop && ImageAligned==0){// if optic lobe is higer position, upside down
						if(bitDepth==8)
						run("16-bit");
						run("Rotation Hideo headless", "rotate=180 3d in=InMacro");
						print(" 180 rotated nc82 signal");
					}
				}//if(BrainShape=="Intact"){
				
				if(shrinkTo2010==false)
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+incredepth+"");
				else
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width="+widthVx+" pixel_height="+heightVx+" voxel_depth="+incredepth+"");
				
				metadata="voxelSizeXY: "+Ori_widthVx+"\n"+"voxelSizeZ: "+incredepth+"\n"+"numChannels: "+channels+"\n"+"referenceChannel: "+refchannel;
				File.saveString(metadata, savedir+"metadata.yaml");
				
				if(sizediff2>OpticLobeSizeGap || sizediff1>OpticLobeSizeGap || y1_opl==cropHeight*2)
				run("Nrrd Writer", "compressed nrrd="+myDir0+noext+"_01.nrrd");
				else{
					if(BrainShape!="Both_OL_missing (40x)")
					run("Nrrd Writer", "compressed nrrd="+savedir+noext+"_01.nrrd");
				}
				
				//		setBatchMode(false);
				//		updateDisplay();
				//		"do"
				//		exit();
				
				
				run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Max Intensity]");
				run("Grays");
				run("8-bit");
				rename("nc82Max.jpg");
				
				makeRectangle(getWidth/2-round((344/Ori_widthVx)/2), 60, round(344/Ori_widthVx), 9);
				setForegroundColor(255, 255, 255);
				run("Fill", "slice");
				
				if(ImageAligned==1)
				//	run("Save", "save="+savedir+noext+"_obj"+OBJScore+".tif");
				saveAs("JPEG", ""+savedir+noext+"_obj"+OBJScore+".jpg");//save 20x MIP
				
				//run("Nrrd Writer", "compressed nrrd="+savedir+noext+"_obj"+OBJScore+".nrrd");//save 20x MIP
				//	saveAs("JPEG", ""+savedir+noext+"_obj"+OBJScore+".jpg");//save 20x MIP
				else
				//	run("Save", "save="+savedir+noext+"MIP.tif");
				saveAs("JPEG", ""+savedir+noext+".jpg");//save 20x MIP
				
				close();
				
				while(isOpen("nc82Max.jpg")){
					selectWindow("nc82Max.jpg");
					close();
				}
			}//if(NRRD_02_ext==0){
			
			selectImage(nc82);
			APinv=0;
			
			if(BrainShape=="Both_OL_missing (40x)"){
				/// template generation ///////////////0.6214809
				
				cropW=round(800/Ori_widthVx);
				cropH=round(400/Ori_widthVx);
				
				run("Canvas Size...", "width="+cropW+" height="+cropH+" position=Center zero");
				
				run("Size...", "width="+round(getWidth*(Ori_widthVx/1))+" height="+round(getHeight*(Ori_widthVx/1))+" depth="+nSlices*(incredepth/1.5)+" constrain average interpolation=Bicubic");
				
				nc82title=getTitle();
				
				changeratio5= 1/5;
				print("APcheck; "+APcheck+"  changeratio5; "+changeratio5);
				
				if(APcheck==1){
					while(isOpen("Samp.tif")){
						selectWindow("Samp.tif");
						close();
						print("Samp.tif closed");
						
					}
					
					run("Duplicate...", "title=Samp.tif duplicate");
					run("Canvas Size...", "width="+round(getHeight)+" height="+round(getHeight)+" position=Center zero");
					
					run("Size...", "width="+round(getWidth*changeratio5)+" height="+round(getHeight*changeratio5)+" depth=60 constrain average interpolation=Bicubic");
					run("Canvas Size...", "width=80 height=80 position=Center zero");
					
					SampID=getImageID();
					
					//setBatchMode(false);
					//					updateDisplay();
					//					"do"
					//					exit();
					
					JFRC2010Ext=File.exists(MatchingFilesDir+"JFRC2010_16bit_crop5.tif");
					if(JFRC2010Ext!=1)
					print("Not exist; "+MatchingFilesDir+"JFRC2010_16bit_crop5.tif");
					
					if(JFRC2010Ext==1)
					open(MatchingFilesDir+"JFRC2010_16bit_crop5.tif");
					
					JFRC2010Ext=File.exists(MatchingFilesDir+"JFRC2010_16bit_cropAN.tif");
					if(JFRC2010Ext!=1)
					print("Not exist; "+MatchingFilesDir+"JFRC2010_16bit_cropAN.tif");
					
					if(JFRC2010Ext==1){
						open(MatchingFilesDir+"JFRC2010_16bit_cropAN.tif");
						
						MaxOBJ3Dscan=0;
						MaxinSlice=0; MaxOBJ3Dscan=0; elipsoidAngle2=0;
						selectWindow("Samp.tif");
						finslice=nSlices;
						
						//	setBatchMode(false);
						//						updateDisplay();
						//						"do"
						//						exit();
						
						print("finslice; "+finslice);
						
						for(inSlice=1; inSlice<finslice-1; inSlice++){
							
							selectImage(SampID);
							selectWindow("Samp.tif");
							setSlice(inSlice);
							run("Duplicate...", "title=SingleSamp.tif");
							
							run("Image Correlation Atomic SD", "samp=JFRC2010_16bit_crop5.tif temp=SingleSamp.tif +=12 -=12 overlap=90 parallel="+NumCPU+" rotation=1 calculation=OBJPeasonCoeff");
							
							resultstringST = call("Image_Correlation_Atomic_SD.getResult");
							//	print("resultstringST; "+resultstringST);
							
							resultstring=split(resultstringST,",");
							
							OBJScore=parseFloat(resultstring[3]);
							
							selectWindow("SingleSamp.tif");
							close();
							
							if(OBJScore>MaxOBJ3Dscan){
								print("slice; "+inSlice);
								MaxinSlice=inSlice;
								MaxOBJ3Dscan=OBJScore;
								Rot=parseFloat(resultstring[2]);
								maxX=parseFloat(resultstring[0]);
								maxY=parseFloat(resultstring[1]);
								
								elipsoidAngle2=parseFloat(Rot);
								if (elipsoidAngle2>90) 
								elipsoidAngle2 = -(180 - elipsoidAngle2);
								
							}
						}
						print("MaxinSlice; "+MaxinSlice+"   MaxOBJ3Dscan; "+MaxOBJ3Dscan+"  elipsoidAngle2; "+elipsoidAngle2);
						selectWindow("JFRC2010_16bit_crop5.tif");
						close();
						
						
						print("");
						if(MaxinSlice<finslice/2 && MaxOBJ3Dscan>600){//means posterior is beginning of slices
							
							if(MaxOBJ3Dscan>800){
								APinv=1;
								print("AP_inverted!!");
							}else{
								
								MaxinSlice=0; MaxOBJ3Dscan=0; elipsoidAngle2=0;
								for(inSlice=1; inSlice<finslice-1; inSlice++){
									
									selectImage(SampID);
									selectWindow("Samp.tif");
									setSlice(inSlice);
									run("Duplicate...", "title=SingleSamp.tif");
									
									//	if(inSlice==7){
									//	setBatchMode(false);
									//			updateDisplay();
									//				"do"
									//		}
									
									run("Image Correlation Atomic EQ", "samp=JFRC2010_16bit_cropAN.tif temp=SingleSamp.tif +=12 -=12 overlap=90 parallel="+NumCPU+" rotation=1 calculation=OBJPeasonCoeff");
									
									resultstringST = call("Image_Correlation_Atomic_EQ.getResult");
									print("resultstringST; "+resultstringST);
									
									resultstring=split(resultstringST,",");
									
									OBJScore=parseFloat(resultstring[3]);
									
									selectWindow("SingleSamp.tif");
									close();
									
									if(OBJScore>MaxOBJ3Dscan){
										print("slice; "+inSlice);
										MaxinSlice=inSlice;
										MaxOBJ3Dscan=OBJScore;
										
										Rot=parseFloat(resultstring[2]);
										maxX=parseFloat(resultstring[0]);
										maxY=parseFloat(resultstring[1]);
										
										elipsoidAngle2=Rot;
										if (elipsoidAngle2>90) 
										elipsoidAngle2 = -(180 - elipsoidAngle2);
										
									}
								}
								print("MaxinSliceAN; "+MaxinSlice+"   MaxOBJ3DscanAN; "+MaxOBJ3Dscan+"  elipsoidAngle2; "+elipsoidAngle2);
								
								
								if(MaxinSlice>finslice/2 && MaxOBJ3Dscan>500){
									APinv=1;
									print("AP_inverted!!");
								}
							}
						}
						
						
						selectWindow("JFRC2010_16bit_cropAN.tif");
						close();
					}//	if(JFRC2010Ext==1){
					
					selectWindow("Samp.tif");
					close();
				}//	if(APcheck=="ON"){
				
				selectWindow(nc82title);
				if(APinv==1){
					run("Reverse");
					run("Flip Horizontally", "stack");
					
					File.saveString("AP inverted", savedir+noext+"_INV.txt"); //- Saves string as a file. 
				}
				
				run("Nrrd Writer", "compressed nrrd="+savedir+noext+"_01.nrrd");
				run("Z Project...", "projection=[Max Intensity]");
				nc82max=getTitle();
				
				getDimensions(finalw, finalh, finalc, finals, frames);
				
				open(MatchingFilesDir+"JRC2018_UNISEX_20x_onemicron.nrrd");
				
				run("Z Project...", "projection=[Max Intensity]");
				jrc2018max=getTitle();
				
				run("Canvas Size...", "width="+finalw+" height="+finalh+" position=Center zero");
				run("Merge Channels...", "c1="+jrc2018max+" c2="+nc82max+" c3="+jrc2018max+"");
				
				saveAs("JPEG", ""+savedir+noext+"_purple_green.jpg");
				close();
				
				while (isOpen("JRC2018_UNISEX_20x_onemicron.nrrd")){
					selectWindow("JRC2018_UNISEX_20x_onemicron.nrrd");
					close();
				}
			}//	if(BrainShape=="Both_OL_missing (40x)"){
			
			if(ChannelInfo!="Both formats"){
				close();
				while(isOpen("nc82.tif")){
					selectWindow("nc82.tif");
					close();
				}
			}
			
			wait(100);
			call("java.lang.System.gc");
			
			print("");
			titlelist=getList("image.titles");
			for(iImage=0; iImage<titlelist.length; iImage++){
				print("Opened; "+titlelist[iImage]);
			}
			
			if(NRRD_02_ext==0){
				startNeuronNum=2;
				AdjustingNum=-1;
				
				if(MCFOYN==false)
				maxvalue1=newArray(channels);
				else
				maxvalue1=newArray(5);
				
			}else if (channels>1){
				startNeuronNum=2;
				AdjustingNum=-1;
			}else if (channels==1){
				startNeuronNum=0;
				AdjustingNum=0;
			}
			if(channels==2){
				startNeuronNum=2;
				AdjustingNum=0;
			}
			
			Neuron_SepEXT = File.exists(PathConsolidatedLabel);
			if(Neuron_SepEXT==1){
				print("Neuron separator result existing; ");
				AdjustingNum=AdjustingNum+1;
			}
			
			print("nImages 1939; "+nImages+"   startNeuronNum; "+startNeuronNum+"   AdjustingNum; "+AdjustingNum+"  channels; "+channels);
			
			for(neuronNum=startNeuronNum; neuronNum<channels+startNeuronNum+AdjustingNum; neuronNum++){
				
				ThisNeuronSep = 0;
				
				if(neuronNum==startNeuronNum){
					selectImage(neuron);
					print("line 1670, neuronNum; "+neuronNum+"   Neuron_SepEXT; "+Neuron_SepEXT);
				}else if (neuronNum==startNeuronNum+1){
					if(isOpen(neuron2)){
						selectImage(neuron2);
					}else if(Neuron_SepEXT==1){
						open(PathConsolidatedLabel);
						run("Flip Vertically", "stack");
						ThisNeuronSep = 1;
						if(nSlices!=NC82SliceNum){
							print("PreAlignerError: Neuron separator result has different slice number; "+nSlices+"  nc82; "+NC82SliceNum);
							
							logsum=getInfo("log");
							File.saveString(logsum, filepath);
							run("Quit");
							newImage("Untitled", "8-bit black", 512, 512, 1);
							run("quit plugin");
						}
					}else
					break;
					
				}else if (neuronNum==startNeuronNum+2){
					
					if(isOpen(neuron3)){
						selectImage(neuron3);
					}else if(Neuron_SepEXT==1){
						open(PathConsolidatedLabel);
						ThisNeuronSep = 1;
						run("Flip Vertically", "stack");
						
						if(nSlices!=NC82SliceNum){
							print("PreAlignerError: Neuron separator result has different slice number; "+nSlices+"  nc82; "+NC82SliceNum);
							
							logsum=getInfo("log");
							File.saveString(logsum, filepath);
							run("Quit");
							newImage("Untitled", "8-bit black", 512, 512, 1);
							run("quit plugin");
						}
					}else
					break;
					
				}else if (neuronNum==startNeuronNum+3){
					if(Neuron_SepEXT==1){
						open(PathConsolidatedLabel);
						ThisNeuronSep = 1;
						run("Flip Vertically", "stack");
						
						if(nSlices!=NC82SliceNum){
							print("PreAlignerError: Neuron separator result has different slice number; "+nSlices+"  nc82; "+NC82SliceNum);
							
							logsum=getInfo("log");
							File.saveString(logsum, filepath);
							run("Quit");
							newImage("Untitled", "8-bit black", 512, 512, 1);
							run("quit plugin");
						}
					}//if(Neuron_SepEXT==1){
				}//if(neuronNum==startNeuronNum){
				
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+incredepth+"");
				//	getVoxelSize(widthVx, heightVx, depth, unit);
				
				if(shrinkTo2010==true){
					VoxSizeADJArray=newArray(Ori_widthVx,Ori_heightVx,incredepth);
					VoxSizeADJ(VoxSizeADJArray,DesireX,objective);
				}
				
				if(	ThisNeuronSep == 0){
					if(neuronNum==startNeuronNum)
					neuron = getImageID();
					else if (neuronNum==startNeuronNum+1)
					neuron2 = getImageID();
					else if (neuronNum==startNeuronNum+2)
					neuron3 = getImageID();
				}
				
				//	setBatchMode(false);
				//	updateDisplay();
				//	"do"
				//		exit();
				
				print("02 channel; "+resliceLongLength+"   "+finalshiftX+"   "+Zoomratio*MaxZoom+"   "+finalshiftY+"   "+elipsoidAngle+"   "+shrinkTo2010+"   "+cropWidth+"   "+cropHeight+"   "+Ori_widthVx+"   "+Ori_heightVx+"   "+incredepth+"   "+reverseR);
				rotateshift3D (resliceLongLength,finalshiftX,Zoomratio*MaxZoom,finalshiftY,elipsoidAngle,shrinkTo2010,cropWidth,cropHeight,Ori_widthVx,Ori_heightVx,incredepth,reverseR);			
				
				rename("signalCH.tif");
				signalCH=getImageID();
				
				logsum=getInfo("log");
				File.saveString(logsum, filepath);
				
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width=1 pixel_height=1 voxel_depth=1");
				run("Reslice [/]...", "output=1.000 start=Left rotate avoid");
				rename("resliceN.tif");
				print("Reslice Done 1568");
				if(bitDepth==8)
				run("16-bit");
				
				run("Rotation Hideo headless", "rotate="+maxrotation+" 3d in=InMacro");
				//		run("Translate...", "x=0 y="+LateralYtrans+" interpolation=None stack");
				//		print("signal Lateral Trans Y; "+LateralYtrans);
				
				run("Reslice [/]...", "output=1 start=Left rotate avoid");
				rename("RealSignal.tif");
				RealSignal=getImageID();
				
				print("Neuron reslice & rotated; "+neuronNum);
				
				if(BrainShape=="Intact" && opticlobeMASKcheck!=0){
					if(y1_opl<ycenterCrop && y2_opl<ycenterCrop && ImageAligned==0){// if optic lobe is higer position, upside down
						if(bitDepth==8)
						run("16-bit");
						run("Rotation Hideo headless", "rotate=180 3d in=InMacro");
						print(" 180 rotated neuron signal "+neuronNum);
					}
				}//if(BrainShape=="Intact"){
				
				if(shrinkTo2010==false)
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+incredepth+"");
				else
				run("Properties...", "channels=1 slices="+NC82SliceNum+" frames=1 unit=microns pixel_width="+widthVx+" pixel_height="+heightVx+" voxel_depth="+incredepth+"");
				
				if(BrainShape=="Both_OL_missing (40x)")
				run("Canvas Size...", "width="+cropW+" height="+cropH+" position=Center zero");
				
				if(APinv==1){
					run("Reverse");
					run("Flip Horizontally", "stack");
					print("2158 neuron AP inv");
				}
				
				//	setBatchMode(false);
				//		updateDisplay();
				//		"do"
				//			exit();
				
				if(	ThisNeuronSep == 0){
					if(sizediff2>OpticLobeSizeGap || sizediff1>OpticLobeSizeGap|| y1_opl==cropHeight*2)
					run("Nrrd Writer", "compressed nrrd="+myDir0+noext+"_0"+neuronNum+".nrrd");
					else
					run("Nrrd Writer", "compressed nrrd="+savedir+noext+"_0"+neuronNum+".nrrd");
				}else{
					run("Nrrd Writer", "compressed nrrd="+savedir+"GLOBAL_ConsolidatedLabel.nrrd");					
				}
				
				
				if(ChannelInfo!="Both formats"){
					close();//RealSignal
					while(isOpen("RealSignal.tif")){
						selectWindow("RealSignal.tif");
						close();
					}
				}
				
				
				while(isOpen("signalCH.tif")){
					selectWindow("signalCH.tif");
					close();
				}
				
				while(isOpen("resliceN.tif")){
					selectWindow("resliceN.tif");
					close();
				}
				if(isOpen("RealSignal.tif"))
				selectWindow("RealSignal.tif");
				
			}//for(neuronNum=1; neuronNum<channels; neuronNum++){
			
			if(ChannelInfo=="Both formats"){
				selectImage(nc82);
				run("Half purple");
				rename("nc82.tif");
				
				selectImage(neuron);
				rename("neuron.tif");
				
				if(channels==3){
					selectImage(neuron2);
					rename("neuron2.tif");
				}
				if(channels==4){
					selectImage(neuron3);
					rename("neuron3.tif");
				}
				
				MergeCH(channels,bitDepth,maxvalue0);
				
				if(sizediff2>OpticLobeSizeGap || sizediff1>OpticLobeSizeGap || y1_opl==cropHeight*2)
				saveAs("ZIP", ""+myDir0+noext+".zip");
				else
				saveAs("ZIP", ""+savedir+noext+".zip");
				close();
			}//	if(ChannelInfo=="Both formats"){
		}//	if(ChannelInfo=="01 02 nrrd files"){
		
		if(ChannelInfo=="multi-colors, single file .tif.zip"){
			selectImage(nc82);
			run("Half purple");
			rename("nc82.tif");
			
			for(neuronNum=1; neuronNum<channels; neuronNum++){
				if(neuronNum==1)
				selectImage(neuron);
				else if (neuronNum==2)
				selectImage(neuron2);
				else if (neuronNum==3)
				selectImage(neuron3);
				
				if(ImageAligned==0){
					run("Canvas Size...", "width="+cropWidth+300+" height="+cropWidth+300+" position=Center zero");
					if(bitDepth==8)
					run("16-bit");
					run("Rotation Hideo headless", "rotate="+elipsoidAngle+" 3d in=InMacro");
					//	run("Rotate... ", "angle="+elipsoidAngle+" grid=0 interpolation=None enlarge stack");//Rotate mask to horizontal
					canvasenlarge(xcenter,cropWidth);
					
					if(rotationYN=="Yes"){
						run("Rotation Hideo headless", "rotate=180 3d in=InMacro");
						//			run("Rotate... ", "angle=180 grid=1 interpolation=None stack");//Rotate mask to 180 degree
						canvasenlarge(xcenter2,cropWidth);
					}
					makeRectangle(round(xcenter2+xgapleft-(cropWidth/2)*Zoomratio*MaxZoom), round(ycenter-(cropHeight/2)*Zoomratio*MaxZoom-shiftY), round(cropWidth*Zoomratio*MaxZoom), round(cropHeight*Zoomratio*MaxZoom));//cropping brain
					run("Crop");
				}else{
					run("Canvas Size...", "width="+resliceLongLength+" height="+resliceLongLength+" position=Center zero");
					getVoxelSize(LVxWidth, LVxHeight, LVxDepth, LVxUnit);//reslice
					print("Translated X; "x="+finalshiftX+" y="+finalshiftY+", nc82," elipsoidAngle; "+elipsoidAngle);
					if(bitDepth==8)
					run("16-bit");
					run("Rotation Hideo headless", "rotate="+elipsoidAngle+" 3d in=InMacro");
					
					run("Translate...", "x="+finalshiftX+" y="+finalshiftY+" interpolation=None stack");
					
					setVoxelSize(LVxWidth*MaxZoom, LVxHeight*MaxZoom, LVxDepth, LVxUnit);//reslice
					run("Canvas Size...", "width="+round(cropWidth*Zoomratio*MaxZoom)+" height="+round(cropHeight*Zoomratio*MaxZoom)+" position=Center zero");
				}
				
				logsum=getInfo("log");
				File.saveString(logsum, filepath);
				
				if(bitDepth==16){
					if(neuronNum==1)
					maxvalue1=newArray(channels);
					
					realresetArray=newArray(maxvalue1,0);
					RealReset(realresetArray);
					maxvalue1[neuronNum-1]=realresetArray[0];
				}
				
				if(neuronNum==1)
				rename("neuron.tif");
				else if (neuronNum==2)
				rename("neuron2.tif");
				else if (neuronNum==3)
				rename("neuron3.tif");
			}
			
			MergeCH(channels,bitDepth,maxvalue0);
			
			setVoxelSize(widthVx, heightVx, depth*incredepth, unit);
			rename(noext+".tif");
			
			if(sizediff2>OpticLobeSizeGap || sizediff1>OpticLobeSizeGap || y1_opl==cropHeight*2)
			saveAs("ZIP", ""+myDir0+noext+".zip");
			else
			saveAs("ZIP", ""+savedir+noext+".zip");
		}//if(ChannelInfo=="multi-colors, single file .tif.zip"){
	}//if(ID20xMIP!=0){
	
}else{//if(maxsizeData!=0){
	
	selectImage(nc82);
	run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Max Intensity]");// imageID is AR
	MIP2ID=getImageID();
	run("Enhance Contrast", "saturated=0.35");
	getMinAndMax(min, max);
	setMinAndMax(min, max);
	print("max; "+max);
	
	if(max!=maxvalue0 && max!=255)
	run("Apply LUT");
	
	run("8-bit");
	run("Grays");
	saveAs("PNG", ""+myDir0+noext+"_OL_Shape.png");//save 20x MIP mask
	saveAs("PNG", ""+savedir+noext+"_OL_Shape_MASK.png");
	
	print("PreAlignerError: brain shape problem");
}

run("Close All");

List.clear();
"Done"

enda=getTime();
gaptime=(enda-starta)/1000;

print("processing time; "+gaptime/60+" min");

logsum=getInfo("log");
File.saveString(logsum, filepath);
run("Misc...", "divide=Infinity save");

run("Quit");
newImage("Untitled", "8-bit black", 512, 512, 1);
run("quit plugin");


function DupPcreationAndbasicTrans (MaxZoom,DupPcreationAndbasicTransArray, NumCPU, bitd, rotSearch,times){
	
	widthVx=DupPcreationAndbasicTransArray[0];
	heightVx=DupPcreationAndbasicTransArray[1];
	Ori_widthVx=DupPcreationAndbasicTransArray[2];
	Ori_heightVx=DupPcreationAndbasicTransArray[3];
	ZoomratioSmall=DupPcreationAndbasicTransArray[4];
	Zoomratio=DupPcreationAndbasicTransArray[5];
	nc82=DupPcreationAndbasicTransArray[6];
	nc82Ori=DupPcreationAndbasicTransArray[7];
	OBJScoreOri=DupPcreationAndbasicTransArray[8];
	OriginalRot=DupPcreationAndbasicTransArray[9];
	OriginalYshift=DupPcreationAndbasicTransArray[10];
	OriginalXshift=DupPcreationAndbasicTransArray[11];
	maxX=DupPcreationAndbasicTransArray[12];
	maxY=DupPcreationAndbasicTransArray[13];
	
	widthVx=widthVx*MaxZoom; heightVx=heightVx*MaxZoom;
	
	Ori_widthVx = Ori_widthVx*MaxZoom; Ori_heightVx = Ori_heightVx*MaxZoom;
	ZoomratioSmall=ZoomratioSmall*MaxZoom; Zoomratio = Zoomratio*MaxZoom;
	
	if(isOpen("OriginalProjection.tif")){
		selectWindow("OriginalProjection.tif");
		close();
	}
	
	while(isOpen("DUPaveP.tif")){
		selectWindow("DUPaveP.tif");
		close();
	}
	
	while(isOpen("nc82.tif")){
		selectWindow("nc82.tif");
		close();
	}
	if(isOpen("nc82.tif"))
	exit("nc82 cannot close 897");
	
	wait(100);
	call("java.lang.System.gc");
	
	selectWindow("nc82_Ori.tif");
	rename("nc82.tif");
	nc82=getImageID();
	
	run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+depth+"");
	
	run("Duplicate...", "title=nc82_Ori.tif duplicate");
	nc82Ori=getImageID();
	
	selectWindow("nc82.tif");
	
	DupAvePprocessing (nc82,NumCPU,bitd,projectionSt);// DUPaveP.tif creation from nc82.tif
	
	selectWindow("DUPaveP.tif");//original size
	
	newImage("Mask", "8-bit white", getWidth, getHeight, 1);
	run("Mask Median Subtraction", "mask=Mask data=DUPaveP.tif %=90 histogram=100");
	selectWindow("Mask");
	close();
	selectWindow("DUPaveP.tif");
	
	//setBatchMode(false);
	//updateDisplay();
	//"do"
	//exit();
	
	print("ZoomratioSmall; "+ZoomratioSmall+"   widthVx; "+widthVx+"  round(getWidth/ZoomratioSmall); "+round(getWidth/ZoomratioSmall)+"  line 2024");
	run("Size...", "width="+round(getWidth*ZoomratioSmall)+" height="+round(getHeight*ZoomratioSmall)+" depth=1 constrain interpolation=None");
	run("Canvas Size...", "width=102 height=102 position=Center zero");
	
	//if(times==1){
	//setBatchMode(false);
	//	updateDisplay();
	//			"do"
	//		exit();
	
	ImageCarray=newArray(0, 0, 0, 0);
	ImageCorrelation2 ("DUPaveP.tif", projectionSt, rotSearch,ImageCarray,75,NumCPU,2,PNGsave);
	
	OBJScoreOri=ImageCarray[0];
	OriginalRot=ImageCarray[1];
	OriginalYshift=ImageCarray[2];
	OriginalXshift=ImageCarray[3];
	
	maxX=OriginalXshift/2;
	maxY=OriginalYshift/2;
	//}
	
	
	DupPcreationAndbasicTransArray[0]=widthVx;
	DupPcreationAndbasicTransArray[1]=heightVx;
	DupPcreationAndbasicTransArray[2]=Ori_widthVx;
	DupPcreationAndbasicTransArray[3]=Ori_heightVx;
	DupPcreationAndbasicTransArray[4] =ZoomratioSmall;
	DupPcreationAndbasicTransArray[5] =Zoomratio;
	DupPcreationAndbasicTransArray[6] =nc82;
	DupPcreationAndbasicTransArray[7] =nc82Ori;
	DupPcreationAndbasicTransArray[8] =OBJScoreOri;
	DupPcreationAndbasicTransArray[9] =OriginalRot;
	DupPcreationAndbasicTransArray[10] =OriginalYshift;
	DupPcreationAndbasicTransArray[11] =OriginalXshift;
	DupPcreationAndbasicTransArray[12] =maxX;
	DupPcreationAndbasicTransArray[13] =maxY;
	
}//function DupPcreationAndbasicTrans (MaxZoom,DupPcreationAndbasicTransArray, NumCPU, bitd, rotSearch){


function opticlobecheck (rotSearch,NumCPU,opticlobecheckArray,times,JFRC2010MedProPath){
	
	OBJScoreOri=opticlobecheckArray[0];
	print("");
	print("  Optic lobe checking!!  OBJScoreOri; "+OBJScoreOri);
	
	selectWindow(projectionSt);
	
	run("Duplicate...", "title=JFRC2010_MedPro-Rop.png");
	makePolygon(82,34,74,52,66,65,69,76,90,80,99,72,101,58,100,34);// elimination of the R-Op
	run("Fill", "slice");
	run("Select All");
	print(projectionSt+" size; W; "+getWidth+"   H; "+getHeight);
	
	BrainShape="Intact";
	
	selectWindow("DUPaveP.tif");//original size
	print("DUPaveP.tif size; W; "+getWidth+"   H; "+getHeight);
	
	//if(times==2){
	//	setBatchMode(false);
	//	updateDisplay();
	//	"do"
	//	exit();
	//}
	
	ImageCarray=newArray(0, 0, 0, 0);
	ImageCorrelation2 ("DUPaveP.tif","JFRC2010_MedPro-Rop.png", rotSearch,ImageCarray,75,NumCPU,3,PNGsave);
	
	OBJScoreR=ImageCarray[0];
	RotR=ImageCarray[1];
	ShiftYR = ImageCarray[2];
	ShiftXR = ImageCarray[3];
	selectWindow("JFRC2010_MedPro-Rop.png");
	close();//"JFRC2010_MedPro-Rop.png"
	print("OBJScoreR; "+OBJScoreR);
	
	selectWindow(projectionSt);
	makePolygon(17,31,22,42,31,51,37,65,31,79,14,79,2,74,2,54,1,38);//L-OL elimination
	run("Fill", "slice");
	
	//		setBatchMode(false);
	//		updateDisplay();
	//		"do"
	//		exit();
	
	ImageCarray=newArray(0, 0, 0, 0);
	ImageCorrelation2 ("DUPaveP.tif", projectionSt, rotSearch,ImageCarray,75,NumCPU,4,PNGsave);
	
	OBJScoreL=ImageCarray[0];
	RotL=ImageCarray[1];
	ShiftYL = ImageCarray[2];
	ShiftXL = ImageCarray[3];
	print("OBJScoreL; "+OBJScoreL);
	
	selectWindow(projectionSt);
	makePolygon(82,34,74,52,66,65,69,76,90,80,99,72,101,58,100,34);// elimination of the R-Op
	run("Fill", "slice");
	ImageCarray=newArray(0, 0, 0, 0);
	ImageCorrelation2 ("DUPaveP.tif", projectionSt, rotSearch,ImageCarray,75,NumCPU,5,PNGsave);
	
	OBJScoreBoth=ImageCarray[0];
	RotBoth=ImageCarray[1];
	ShiftYboth = ImageCarray[2];
	ShiftXboth = ImageCarray[3];
	print("OBJScoreBoth; "+OBJScoreBoth);
	
	if(OBJScoreL>OBJScoreR && OBJScoreL>OBJScoreOri+30 && OBJScoreL>OBJScoreBoth){
		OBJScoreOri = OBJScoreL;
		BrainShape="Left_OL_missing";
		OriginalRot=RotL;
		OriginalXshift = ShiftXL;
		OriginalYshift = ShiftYL;
		ID20xMIP=1;
		finalMIP="Max projection";
		SizeM=1; 
		
	}
	if(OBJScoreR>OBJScoreL && OBJScoreR>OBJScoreOri+30 && OBJScoreR>OBJScoreBoth){
		OBJScoreOri = OBJScoreR;
		BrainShape="Right_OL_missing";
		OriginalRot=RotR;
		OriginalXshift = ShiftXR;
		OriginalYshift = ShiftYR;
		
		ID20xMIP=1;
		finalMIP="Max projection";
		SizeM=1; 
	}
	if(OBJScoreBoth>OBJScoreR && OBJScoreBoth>OBJScoreL && OBJScoreBoth>OBJScoreOri){
		OBJScoreOri = OBJScoreBoth;
		BrainShape="Both_OL_missing";
		OriginalRot=RotBoth;
		OriginalXshift = ShiftXboth;
		OriginalYshift = ShiftYboth;
		
		ID20xMIP=1;
		finalMIP="Max projection";
		SizeM=1; 
	}
	
	finalshiftX=round(OriginalXshift/ZoomratioSmall);
	finalshiftY=round(OriginalYshift/ZoomratioSmall);
	
	opticlobecheckArray[0] = OBJScoreOri;
	opticlobecheckArray[1] = BrainShape;
	opticlobecheckArray[2] = OriginalXshift;
	opticlobecheckArray[3] = OriginalYshift;
	opticlobecheckArray[4] = finalshiftX;
	opticlobecheckArray[5] = finalshiftY;
	opticlobecheckArray[6] = SizeM;
	opticlobecheckArray[7] = finalMIP;
	opticlobecheckArray[8] = ID20xMIP;
	opticlobecheckArray[9] = OriginalRot;
}//function opticlobecheck (rotSearch,NumCPU,){


function TwoDfillHole (){// accept binary
	run("Select All");
	run("Copy");
	
	run("Fill Holes");
	
	for(ix=0; ix<getWidth; ix++){
		if(getPixel(ix, 0)!=0){
			posiSum=posiSum+1;
		}
	}
	
	if(posiSum>(getWidth/2)){
		run("Paste");
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
		
		run("Fill Holes");
	}
	
}

function ScanMakeBinary (){
	
	run("Select All");
	run("Copy");
	
	setThreshold(1, 255);
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Make Binary", "thresholded remaining");
	
	posiSum=0;
	for(ix=0; ix<getWidth; ix++){
		if(getPixel(ix, 0)!=0){
			posiSum=posiSum+1;
		}
	}
	
	if(posiSum>(getWidth*0.4)){
		run("Paste");
		run("Grays");
		setThreshold(1, 255);
		setForegroundColor(255, 255, 255);
		setBackgroundColor(0, 0, 0);
		run("Make Binary", "thresholded remaining");
	}
	posiSum2=0;
	for(ix2=0; ix2<getWidth; ix2++){
		if(getPixel(ix2, 0)!=0){
			posiSum2=posiSum2+1;
		}
	}
	if(posiSum2>(getWidth/2)){
		run("Paste");
		setThreshold(1, 255);
		setForegroundColor(255, 255, 255);
		setBackgroundColor(0, 0, 0);
		run("Make Binary", "thresholded remaining");
		
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
	}
}

function fileOpen(FilePathArray){
	FilePath=FilePathArray[0];
	MIPname=FilePathArray[1];
	
	//	print(MIPname+"; "+FilePath);
	if(isOpen(MIPname)){
		selectWindow(MIPname);
		tempMask=getDirectory("image");
		FilePath=tempMask+MIPname;
	}else{
		if(FilePath==0){
			
			FilePath=getDirectory("plugins")+MIPname;
			
			tempmaskEXI=File.exists(FilePath);
			if(tempmaskEXI!=1)
			FilePath=getDirectory("plugins")+"Brain_Aligner_Plugins"+File.separator+MIPname;
			
			tempmaskEXI=File.exists(FilePath);
			
			if(tempmaskEXI==1){
				open(FilePath);
			}else{
				print("no file ; "+FilePath);
			}
		}else{
			tempmaskEXI=File.exists(FilePath);
			if(tempmaskEXI==1)
			open(FilePath);
			else{
				print("no file ; "+FilePath);
			}
		}
	}//if(isOpen("JFRC2013_63x_Tanya.nrrd")){
	
	FilePathArray[0]=FilePath;
}

function VoxSizeADJ (VoxSizeADJArray,DesireX,objective){
	
	widthVx = VoxSizeADJArray[0];
	heightVx = VoxSizeADJArray[1];
	depthVox = VoxSizeADJArray[2];
	
	if(widthVx!=1 && heightVx!=1){
		getDimensions(Oriwidth, Oriheight, channels, slices, frames);
		
		if(objective!="40x")
		changeratio=widthVx/0.5189;
		else
		changeratio=1.1;
		
		print("objective; "+objective+"  Oriwidth; "+Oriwidth+"   changeratio; "+changeratio+"  Oriwidth*changeratio; "+Oriwidth*changeratio+"   Oriheight*changeratio; "+Oriheight*changeratio);
		if(changeratio!=1){
			run("Size...", "width="+round(Oriwidth*changeratio)+" height="+round(Oriheight*changeratio)+" depth="+nSlices+" constrain interpolation=None");
			run("Canvas Size...", "width="+Oriwidth+" height="+Oriheight+" position=Center zero");
			print("VoxelResized; originally "+widthVx+" to 0.5189161   changeratio; "+changeratio);
			getVoxelSize(widthVx, heightVx, depth, unit);	
		}
		
	}else{//if(widthVx!=1 && heightVx!=1){
		run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+DesireX+" pixel_height="+DesireX+" voxel_depth="+DesireX+"");
		getVoxelSize(widthVx, heightVx, depth, unit);	
	}
	
	run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width=1 pixel_height=1 voxel_depth=1");
	
	VoxSizeADJArray[0] = widthVx;
	VoxSizeADJArray[1] = heightVx;
	VoxSizeADJArray[2] = depthVox;
}//function VoxSizeADJ (VoxSizeADJArray){


function ImageCorrelation(ImageCorrelationArray,widthVx,NumCPU,projectionSt,PNGsave,BrainShape){
	nc82=ImageCorrelationArray[0];
	ImageAligned=ImageCorrelationArray[1];
	wholebraindistance=ImageCorrelationArray[7];
	
	STring="EQ";
	tempSD=1;
	
	mirot=90;//180;
	mirot2=55;//55
	porot=90;//179
	
	if(isOpen("SampMIP.tif")){
		selectWindow("SampMIP.tif");
		close();
		print("SampMIP was Open!!!!????");
	}
	
	selectImage(nc82);
	
	if(projectionSt=="JFRC2010_MedPro.tif")
	run("Z Project...", "start=5 stop="+nSlices-10+" projection=[Median]");//Max Intensity
	
	if(projectionSt=="JFRC2010_AvePro.png")
	run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Average Intensity]");//Max Intensity
	
	if(projectionSt=="JFRC2010_MIP.tif")
	run("Z Project...", "start=5 stop="+nSlices-10+" projection=[Max Intensity]");//Max Intensity
	
	dotindex=lastIndexOf(projectionSt,".");
	tempsavename=substring(projectionSt, 0, dotindex);
	
	resetMinAndMax();
	run("16-bit");
	run("Grays");
	rename("SampMIP.tif");
	
	run("Enhance Contrast", "saturated=0.35");
	run("Apply LUT");
	
	ZoomratioFun=6.2243/widthVx; //10.5813/widthVx;
	print("2406 60px ZoomratioFun; "+ZoomratioFun+"   widthVx; "+widthVx+"  getWidth"+getWidth+"   getHeight"+getHeight+"  round(getWidth/ZoomratioFun); "+round(getWidth/ZoomratioFun));
	run("Size...", "width="+round(getWidth/ZoomratioFun)+" height="+round(getHeight/ZoomratioFun)+" depth=1 constrain interpolation=None");
	
	if(ZoomratioFun==6.2243/widthVx)
	run("Canvas Size...", "width=102 height=102 position=Center zero");
	else
	run("Canvas Size...", "width=60 height=60 position=Center zero");
	
	
	//	newImage("Mask", "8-bit white", getWidth, getHeight, 1);
	//	run("Mask Median Subtraction", "mask=Mask data=SampMIP.tif %=90 histogram=100");
	//	selectWindow("Mask");
	//	close();
	
	
	
	//	setBatchMode(false);
	//		updateDisplay();
	//			"do"
	//		exit();
	
	if(ZoomratioFun==6.2243/widthVx){
		
		run("Image Correlation Atomic EQ", "samp=SampMIP.tif temp="+projectionSt+" +="+porot+" -="+mirot+" overlap=75 parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
		if(PNGsave==1){
			run("Merge Channels...", "c1="+projectionSt+" c2=DUP_SampMIP.tif  c3="+projectionSt+" keep");
			saveAs("PNG", savedir+noext+"_"+tempsavename+".png");
			close();
		}
		
		selectWindow("DUP_SampMIP.tif");
		close();
		
	}else{
		run("Image Correlation Atomic EQ", "samp=SampMIP.tif temp=JFRC2010_60pxMedP.tif +="+porot+" -="+mirot+" overlap=75 parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
		
		run("Merge Channels...", "c1=JFRC2010_60pxMedP.tif c2=DUP_SampMIP.tif  c3=JFRC2010_60pxMedP.tif keep");
		saveAs("PNG", savedir+noext+"_"+tempsavename+".png");
		close();
		selectWindow("DUP_SampMIP.tif");
		close();
	}
	
	
	selectWindow("SampMIP.tif");
	
	resultstringST = call("Image_Correlation_Atomic_EQ.getResult");
	
	resultstring=split(resultstringST,",");
	
	OBJScore=parseFloat(resultstring[3]);
	Rot=parseFloat(resultstring[2]);
	bestmaxX=parseFloat(resultstring[0]);
	bestmaxY=parseFloat(resultstring[1]);
	
	preX=bestmaxX;
	preY=bestmaxY;
	
	elipsoidAngle=parseFloat(Rot);
	//if (elipsoidAngle>90) 
	//elipsoidAngle = -(180 - elipsoidAngle);
	
	elipsoidAngle=elipsoidAngle*-1;// equalizing to later zoom analysis
	preRot=elipsoidAngle;
	
	updown=0;
	if(preRot>90 ||preRot<-90)
	updown=1;
	
	
	abspreX=abs(preX);
	abspreY=abs(preY);
	
	suspicious=0;
	if(updown==1 && abspreX>=10)
	suspicious=1;
	
	if(updown==1 && abspreY>=10)
	suspicious=1;
	
	trueUPD=0;
	
	print("initial objectscore; "+OBJScore+"  preX; "+preX+"  preY; "+preY+"  preRot; "+preRot+" updown; "+updown);
	print("");
	OBJScore=round(OBJScore);
	MaxZoom=1;
	MaxinSlice=0;
	
	if(BrainShape=="Both_OL_missing (40x)")
	threasholdOBJ=850;
	else
	threasholdOBJ=750;
	
	if(OBJScore<threasholdOBJ){
		selectImage(nc82);
		run("Duplicate...", "title=Samp.tif, duplicate");
		run("16-bit");
		rename("Samp.tif");
		
		run("Size...", "width="+round(getWidth/ZoomratioFun)+" height="+round(getHeight/ZoomratioFun)+" depth="+round(nSlices/2)+" constrain interpolation=None");
		run("Canvas Size...", "width=60 height=60 position=Center zero");
		
		//	setBatchMode(false);
		//	updateDisplay();
		//	"do"
		//	exit();
		slicescan=0;
		MaxOBJ3Dscan=0;
		if(slicescan==1){
			print("resizd nSlices; "+nSlices);
			for(inSlice=6; inSlice<nSlices-10; inSlice++){
				selectWindow("Samp.tif");
				setSlice(inSlice);
				run("Duplicate...", "title=SingleSamp.tif");
				
				run("Enhance Contrast", "saturated=3");
				run("Apply LUT");
				
				//	setBatchMode(false);
				//	updateDisplay();
				//	"do"
				//		exit();
				
				run("Image Correlation Atomic EQ", "samp=SingleSamp.tif temp=JFRC2010_50pxSlice.tif +=55 -="+mirot2+" overlap=90 parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
				resultstringST = call("Image_Correlation_Atomic_EQ.getResult");
				
				if(PNGsave==1){
					run("Merge Channels...", "c1=JFRC2010_50pxSlice.tif c2=DUP_SingleSamp.tif c3=JFRC2010_50pxSlice.tif keep");
					saveAs("PNG", savedir+noext+"_JFRC2010_50pxSlice.png");
					close();
				}
				
				if(isOpen("DUP_SingleSamp")){
					selectWindow("DUP_SingleSamp");
					close();
				}
				
				print("resultstringST; "+resultstringST);
				
				resultstring=split(resultstringST,",");
				OBJScore=parseFloat(resultstring[3]);
				
				selectWindow("SingleSamp.tif");
				close();
				
				if(OBJScore>MaxOBJ3Dscan){
					
					MaxinSlice=inSlice;
					MaxOBJ3Dscan=OBJScore;
					
					maxX=parseFloat(resultstring[0]);
					maxY=parseFloat(resultstring[1]);
					Rot=parseFloat(resultstring[2]);
					
					elipsoidAngle=Rot;
					if (elipsoidAngle>90) 
					elipsoidAngle = -(180 - elipsoidAngle);
					
				}
			}
			print("MaxinSlice; "+MaxinSlice+"   MaxOBJ3Dscan; "+MaxOBJ3Dscan+"  elipsoidAngle; "+elipsoidAngle);
			OBJScore=MaxOBJ3Dscan;
			selectWindow("Samp.tif");
			close();
		}//if(slicescan==1){
		
		
		if(OBJScore<threasholdOBJ){
			print("2D Zoom adjustment, due to low obj score; <"+threasholdOBJ+"");
			PreMaxOBJ=OBJScore; PreOBJ=OBJScore;
			PreMaxOBJ=parseFloat(PreMaxOBJ);//Chaneg string to number
			
			
			setForegroundColor(0, 0, 0);
			//0.75-1.3
			for(iZoom=0.75; iZoom<=1.3; iZoom+=0.03){
				
				call("java.lang.System.gc");
				
				if(tempSD==0){
					selectWindow("SampMIP.tif");
					run("Select All");
					run("Duplicate...", "title=ZOOM.tif");
				}//if(tempSD==0){
				
				if(tempSD==1){
					selectWindow(projectionSt);
					run("Select All");
					run("Duplicate...", "title=TempZOOM.tif");
					
					STring="SD";
					
					makePolygon(17,31,22,42,31,51,37,65,31,79,14,79,2,74,2,54,1,38);//L-OL elimination
					run("Fill", "slice");
					
					makePolygon(82,34,74,52,66,65,69,76,90,80,99,72,101,58,100,34);// elimination of the R-Op
					run("Fill", "slice");
					run("Select All");
				}
				
				run("Size...", "width="+round(getWidth*iZoom)+" height="+round(getHeight*iZoom)+" depth=1 constrain interpolation=None");
				
				if(ZoomratioFun==6.2243/widthVx)
				run("Canvas Size...", "width=102 height=102 position=Center zero");
				else
				run("Canvas Size...", "width=60 height=60 position=Center zero");
				
				run("Enhance Contrast", "saturated=1");
				run("Apply LUT");
				
				if(ZoomratioFun==6.2243/widthVx){
					
					if(tempSD==0){
						run("Image Correlation Atomic "+STring+"", "samp=ZOOM.tif temp="+projectionSt+" +=55 -="+mirot2+" overlap=75 parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
						resultstringST = call("Image_Correlation_Atomic_"+STring+".getResult");
						if(PNGsave==1){
							run("Merge Channels...", "c1="+projectionSt+" c2=DUP_ZOOM.tif  c3="+projectionSt+" keep");
							saveAs("PNG", savedir+noext+"_Zoom_"+tempsavename+"_"+iZoom+".png");
							close();
						}
					}else{
						run("Image Correlation Atomic "+STring+"", "samp=TempZOOM.tif temp=SampMIP.tif +="+porot+" -="+mirot+" overlap=70 parallel="+NumCPU+" rotation=2 show calculation=OBJPeasonCoeff");
						resultstringST = call("Image_Correlation_Atomic_"+STring+".getResult");
						
						if(PNGsave==1){
							run("Merge Channels...", "c1=DUP_TempZOOM.tif c2=SampMIP.tif  c3=DUP_TempZOOM.tif keep");
							saveAs("PNG", savedir+noext+"_Zoom_"+tempsavename+"_"+iZoom+".png");
							close();
						}
						selectWindow("DUP_TempZOOM.tif");
						close();
						
						selectWindow("TempZOOM.tif");
						close();
					}
					
					
				}else{
					run("Image Correlation Atomic "+STring+"", "samp=ZOOM.tif temp=JFRC2010_60pxMedP.tif +="+porot+" -="+mirot+" overlap=75 parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
					resultstringST = call("Image_Correlation_Atomic_"+STring+".getResult");
					if(PNGsave==1){
						run("Merge Channels...", "c1=JFRC2010_60pxMedP.tif c2=DUP_ZOOM.tif  c3=JFRC2010_60pxMedP.tif keep");
						saveAs("PNG", savedir+noext+"_Zoom_JFRC2010_60pxMed_"+iZoom+".png");
						close();
					}
				}
				
				if(isOpen("DUP_ZOOM.tif")){
					selectWindow("DUP_ZOOM.tif");
					close();
				}
				
				while(isOpen("ZOOM.tif")){
					selectWindow("ZOOM.tif");
					close();
				}
				
				print("3117; resultstringST; "+resultstringST);
				resultstring=split(resultstringST,",");
				
				OBJScore=parseFloat(resultstring[3]);
				
				Rot=parseFloat(resultstring[2]);
				maxX=parseFloat(resultstring[0]);
				maxY=parseFloat(resultstring[1]);
				
				movingdistance=sqrt(maxX*maxX+maxY*maxY);
				
				premovingdistance=sqrt(preX*preX+preY*preY);
				
				if(wholebraindistance==0)
				wholebraindistance=4;
				
				print("iZoom; "+iZoom+"   OBJScore; "+OBJScore+"  wholebraindistance*2.5; "+wholebraindistance*2.5+"  movingdistance; "+movingdistance);
				gapX=abs(preX-maxX);
				gapY=abs(preY-maxY);
				rotGap= abs(preRot-Rot);
				
				if(OBJScore>830 && Rot<30 && PreMaxOBJ<OBJScore){
					bestmaxX=maxX;
					bestmaxY=maxY;
					elipsoidAngle=Rot;
					MaxZoom=iZoom;
					wholebraindistance=movingdistance;
					PreMaxOBJ=OBJScore;
					
					print("less rotation and high score; "+OBJScore);
					//break;
				}
				
				if(wholebraindistance*2.5>movingdistance || updown==1){
					
					absmaxX=abs(maxX);
					absmaxY=abs(maxY);
					
					if(updown==1){//if upside down
						
						//		print("absmaxX; "+absmaxX+"  absmaxY; "+absmaxY+"  OBJScore; "+OBJScore+"  PreMaxOBJ; "+PreMaxOBJ+"  abs(Rot); "+abs(Rot)+"  trueUPD; "+trueUPD);
						
						if(OBJScore>830 && gapX<5 && gapY<5 && rotGap<7 && absmaxX<7 && absmaxY<7){
							
							trueUPD=1;
							bestmaxX=preX;
							bestmaxY=preY;
							
							bestmaxX=bestmaxX*-1;
							bestmaxY=bestmaxY*-1;
							elipsoidAngle=preRot;
							MaxZoom=iZoom;
							
							print("original rotation is right!; "+MaxZoom);
							break;
							
						}
						
						
						
						if(trueUPD==0){
							if(abs(Rot)<90){
								
								rotGap=0;
								
								//if(suspicious==1){
								
								if(absmaxX<9 && absmaxY<9){
									if(OBJScore>PreMaxOBJ){
										gapX=0;
										preX=maxX;
										preY=maxY;
										gapY=0;
										rotGap=0;
										updown=0;
										preRot=Rot;
										elipsoidAngle=parseFloat(Rot);
										wholebraindistance=movingdistance;
										PreMaxOBJ=OBJScore;
										MaxZoom=iZoom;
										print("---suspicious up-side-down, cancelled to normal----------------");
									}
								}//if(absmaxX<9 && absmaxY<9){
							}	
							//	}//	if(suspicious==1){
						}//if(trueUPD==0){
						
						
						
						
					}//if(updown==1){//if upside down
				}//if(wholebraindistance*2.5>movingdistance || updown==1){
				
				gapmovingdistance=abs(premovingdistance-movingdistance);
				
				if(gapmovingdistance<9 && rotGap<9 || OBJScore>850){
					
					if(OBJScore>=PreMaxOBJ){
						
						print("gapmovingdistance; "+gapmovingdistance+"  preX; "+preX+"  preY; "+preY+"   maxX; "+maxX+"   maxY; "+maxY+"  Rot; "+Rot+"  gapY; "+gapY+"  gapX; "+gapX);
						
						PreMaxOBJ=OBJScore;
						
						elipsoidAngle=parseFloat(Rot);
						//			if (elipsoidAngle>90) 
						//			elipsoidAngle = -(180 - elipsoidAngle);
						
						bestmaxX=maxX;
						bestmaxY=maxY;
						premovingdistance=movingdistance;
						bestmaxX=bestmaxX*-1;
						bestmaxY=bestmaxY*-1;
						
						MaxZoom=iZoom;
					}
				}
				
			}//for(iZoom=0.75; iZoom<=1.3; iZoom+=0.03){
			
			print("");
			print("PreOBJ; "+PreOBJ+" NewOBJ; "+PreMaxOBJ+"   elipsoidAngle; "+elipsoidAngle+"   bestmaxY; "+bestmaxY+"   bestmaxX; "+bestmaxX+"   MaxZoom; "+MaxZoom);
			OBJScore=PreMaxOBJ;
		}
		
	}
	
	//setBatchMode(false);
	//updateDisplay();
	//"do"
	//exit();
	
	if(tempSD==1)
	MaxZoom=abs(1+(1-MaxZoom));
	
	while(isOpen("SampMIP.tif")){
		selectWindow("SampMIP.tif");
		close();
	}
	
	if(OBJScore>600){
		ImageAligned=1;
		print("OBJScore; "+OBJScore);
	}
	
	ImageCorrelationArray[1]=ImageAligned;
	ImageCorrelationArray[2]=bestmaxX;
	ImageCorrelationArray[3]=bestmaxY;
	ImageCorrelationArray[4]=elipsoidAngle;
	ImageCorrelationArray[5]=OBJScore;
	ImageCorrelationArray[6]=MaxZoom;
}

function MergeCH(channels,bitDepth,maxvalue0){
	if(channels==3)
	run("Merge Channels...", "c1=nc82.tif c2=neuron.tif c3=neuron2.tif create");
	else if (channels==2)
	run("Merge Channels...", "c1=nc82.tif c2=neuron.tif create");
	else if (channels==4)
	run("Merge Channels...", "c1=nc82.tif c2=neuron.tif c3=neuron2.tif c4=neuron3.tif create");
	
	run("Make Composite");
	
	if(bitDepth==16){
		resetMax(maxvalue0);
		run("Next Slice [>]");
		setMinAndMax(0, maxvalue1[0]);
		
		if(channels==3){
			run("Next Slice [>]");
			setMinAndMax(0, maxvalue1[1]);
		}
		if(channels==4){
			run("Next Slice [>]");
			setMinAndMax(0, maxvalue1[2]);
		}
	}
}

function RealReset(realresetArray){
	run("Max value");
	maxvalue = call("Max_value.getResult");
	maxvalue1=parseInt(maxvalue);
	
	setMinAndMax(0, maxvalue1);
	
	realresetArray[0]=maxvalue1;
}

function resetMax(maxvalue0){
	if(maxvalue0<4096)
	call("ij.ImagePlus.setDefault16bitRange", 12);
	else
	call("ij.ImagePlus.setDefault16bitRange", 16);
}

function canvasenlarge(xcenter,cropWidth){
	xsize3=getWidth();
	ysize3=getHeight();
	done=0;
	if(xcenter<=cropWidth/2){
		run("Canvas Size...", "width="+xsize3+cropWidth/2-xcenter+" height="+ysize3+" position=Top-Right zero");
		done=1;
	}
	xsize3=getWidth();
	if ((xsize3-xcenter)<=cropWidth/2 && xcenter>=cropWidth/2)
	run("Canvas Size...", "width="+cropWidth/2-(xsize3-xcenter)+xsize3+" height="+ysize3+" position=Top-Left zero");
	
	if(xcenter<cropWidth/2 && xsize3<=cropWidth && done==0)
	run("Canvas Size...", "width="+cropWidth+" height="+ysize3+" position=Top-Right zero");
	
	//	setBatchMode(false);
	//	updateDisplay();
	//	aa
}

function analyzeCenter(AnalyzeCArray){
	run("Analyze Particles...", "size="+AnalyzeCArray[0]/2+"-Infinity display clear");
	
	maxarea=0;
	for(maxdecide=0; maxdecide<nResults; maxdecide++){
		
		brainArea = getResult("Area", maxdecide);
		if(brainArea>maxarea){
			maxarea=brainArea;
			xcenterCrop=getResult("X", maxdecide);
			ycenterCrop=getResult("Y", maxdecide);
		}
	}//for(maxdecide=0; maxdecide<nResults; maxdecide++){
	
	AnalyzeCArray[1]=xcenterCrop;
	AnalyzeCArray[2]=ycenterCrop;
}//function analyzeCenter(AnalyzeC_Array){


function resetBrightness(maxvalue0){// resetting brightness if 16bit image
	if(maxvalue0<4096)
	call("ij.ImagePlus.setDefault16bitRange", 12);
	else
	call("ij.ImagePlus.setDefault16bitRange", 16);
}


function colordecision(colorarray){
	posicolor2=colorarray[0];
	run("Z Project...", "projection=[Max Intensity]");
	setMinAndMax(0, 10);
	run("RGB Color");
	run("Size...", "width=5 height=5 constrain average interpolation=Bilinear");
	posicolor2=0;
	for(colorsizeX=0; colorsizeX<5; colorsizeX++){
		for(colorsizeY=0; colorsizeY<5; colorsizeY++){
			
			Red=0; Green=0; Blue=0;
			colorpix=getPixel(colorsizeX, colorsizeY);
			
			Red = (colorpix>>16)&0xff;  
			Green = (colorpix>>8)&0xff; 
			Blue = colorpix&0xff;
			
			if(Red>0){
				posicolor2="Red";
				
				if(Green>0 && Blue>0)
				posicolor2="White";
				
				if(Blue>0 && Green==0)
				posicolor2="Purple";
				
			}
			if(Green>0 && Red==0 && Blue==0)
			posicolor2="Green";
			
			if(Green==0 && Red==0 && Blue>0)
			posicolor2="Blue";
			
			if(Green>0 && Red==0 && Blue>0)
			posicolor2="Green";
			
			if(Green>0 && Red>0 && Blue==0)
			posicolor2="Yellow";
		}
	}
	close();
	
	print("3069 posicolor; "+posicolor2);
	colorarray[0]=posicolor2;
}

function rotationF(rotation,unit,vxwidth,vxheight,depth,xTrue,yTrue){
	setBackgroundColor(0, 0, 0);
	run("Rotate... ", "angle="+rotation+" grid=1 interpolation=None fill enlarge stack");
	wait(1000);
	makeRectangle(xTrue-300, yTrue-465, 600, 1024);
	run("Crop");
	
	getDimensions(width, height, channels, slices, frames);
	if(height<1024 || width<600)
	run("Canvas Size...", "width=600 height=1024 position=Top-Left zero");
	run("Select All");
	run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+vxwidth+" pixel_height="+vxheight+" voxel_depth="+depth+"");
	run("Grays");
}//function


function ImageCorrelation2 (sample,templateImg, rotSearch,ImageCarray,overlap,NumCPU,trynum,PNGsave){
	selectWindow(sample);
	rename("SampMIP.tif");
	
	NumCPU=round(NumCPU);
	rotSearch=round(rotSearch);
	
	binary=0;
	
	if(binary==1){
		sampbinary=is("binary");
		
		if(sampbinary==0){
			setAutoThreshold("Mean dark");
			//setThreshold(28, 255);
			setOption("BlackBackground", true);
			run("Convert to Mask");
		}
	}
	print("2789");
	selectWindow(templateImg);
	rename("Temp22.tif");
	
	if(binary==1){
		tempbinaly=is("binary");
		
		if(tempbinaly==0){
			setAutoThreshold("Mean dark no-reset");
			run("Convert to Mask");
		}
	}
	mirot=0;
	
	print("ImageCorrelation2 running; rotSearch; "+rotSearch+"  overlap; "+overlap+"  NumCPU;"+NumCPU+"  trynum; "+trynum);
	if(trynum==2 || trynum==3 || trynum==4 || trynum==5){
		run("Image Correlation Atomic SD", "samp=SampMIP.tif temp=Temp22.tif +="+rotSearch+" -="+mirot+" overlap="+overlap+" parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
		resultstringST = call("Image_Correlation_Atomic_SD.getResult");
	}else{
		run("Image Correlation Atomic EQ", "samp=SampMIP.tif temp=Temp22.tif +="+rotSearch+" -="+mirot+" overlap="+overlap+" parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
		resultstringST = call("Image_Correlation_Atomic_EQ.getResult");
	}
	//if(trynum==3){
	//	setBatchMode(false);
	//	updateDisplay();
	//	"do"
	//	exit();
	//}
	
	print("3474 resultstringST; "+resultstringST);
	
	resultstring=split(resultstringST,",");
	
	OBJScore=parseFloat(resultstring[3]);
	Rot=parseFloat(resultstring[2]);
	maxX=parseFloat(resultstring[0]);
	maxY=parseFloat(resultstring[1]);
	
	if(PNGsave==1){
		run("Merge Channels...", "c1=Temp22.tif c2=DUP_SampMIP.tif  c3=Temp22.tif keep");
		saveAs("PNG", savedir+noext+"_"+templateImg+"_"+trynum+"_"+OBJScore+".png");
		close();
	}
	if(isOpen("DUP_SampMIP.tif")){
		selectWindow("DUP_SampMIP.tif");
		close();
	}
	
	selectWindow("Temp22.tif");
	rename(templateImg);
	
	selectWindow("SampMIP.tif");
	rename(sample);
	
	
	
	ImageCarray[0]=OBJScore;
	ImageCarray[1]=Rot;
	ImageCarray[2]=maxY;
	ImageCarray[3]=maxX;
}

function C1C20102Takeout(takeout){// using
	origi=takeout[0];
	
	dotIndex = lastIndexOf(origi, "_C1.tif");
	if (dotIndex!=-1)
	origi = substring(origi, 0, dotIndex); 
	
	dotIndex = lastIndexOf(origi, "_C2.tif");
	if (dotIndex!=-1)
	origi = substring(origi, 0, dotIndex);
	
	dotIndex = lastIndexOf(origi, "_C1.nrrd");
	if (dotIndex!=-1)
	origi = substring(origi, 0, dotIndex); 
	
	dotIndex = lastIndexOf(origi, "_C2.nrrd");
	if (dotIndex!=-1)
	origi = substring(origi, 0, dotIndex);
	
	dotposition=lastIndexOf(origi, "_01.tif");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_02.tif");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_01.nrrd");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_02.nrrd");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_01.zip");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_02.zip");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_R.mha");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_G.mha");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "_C1.zip");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, "GMR");
	if (dotposition!=-1)
	origi=substring(origi, dotposition, lengthOf(origi));
	
	dotposition=lastIndexOf(origi, "VT");
	if (dotposition!=-1)
	origi=substring(origi, dotposition, lengthOf(origi));
	
	dotposition=lastIndexOf(origi, "_C2.zip");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	dotposition=lastIndexOf(origi, ".");
	if (dotposition!=-1)
	origi=substring(origi, 0, dotposition);
	
	takeout[0]=origi;
}


function CLEAR_MEMORY() {
	//	d=call("ij.IJ.maxMemory");
	//	e=call("ij.IJ.currentMemory");
	for (trials=0; trials<2; trials++) {
		call("java.lang.System.gc");
		wait(100);
	}
}

function FILL_HOLES(DD2, DD3) {
	
	if(DD3==1){
		MASKORI=getImageID();
		run("Duplicate...", "title=MaskBWtest.tif duplicate");
		MaskBWtest2=getImageID();
		
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
		
		run("Fill Holes", "stack");
		
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
		
		//	print(nSlices+"   2427");
		run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Average Intensity]");
		getStatistics(area, MaskINV_AVEmean, min, max, std, histogram);
		close();
		
		if(MaskINV_AVEmean<5 || MaskINV_AVEmean>250){
			selectImage(MaskBWtest2);
			close();
			
			selectImage(MASKORI);
			run("Fill Holes", "stack");
		}else{
			selectImage(MASKORI);
			close();
			selectImage(MaskBWtest2);
		}
		
		
	}else if (DD2==1){
		MASKORI=getImageID();
		run("Duplicate...", "title=MaskBWtest.tif");
		MaskBWtest2=getImageID();
		
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
		
		run("Fill Holes", "stack");
		
		run("Invert LUT");
		run("RGB Color");
		run("8-bit");
		
		getStatistics(area, MaskINV_AVEmean, min, max, std, histogram);
		
		if(MaskINV_AVEmean<20 || MaskINV_AVEmean>230){
			selectImage(MaskBWtest2);
			close();
			
			selectImage(MASKORI);
			run("Fill Holes", "stack");
		}else{
			selectImage(MASKORI);
			close();
			selectImage(MaskBWtest2);
		}
	}//if (2DD==1){
}

function lateralDepthAdjustment(op1center,op2center,lateralArray,nc82,templateBr,NumCPU,shrinkTo2010,objective,PNGsave){
	
	nc82ID=getImageID();
	orizslice=nSlices();
	
	run("Reslice [/]...", "output=1.000 start=Left rotate avoid");
	resliceW=getWidth(); resliceH=getHeight();
	print("Original op1center; "+op1center+"  op2center; "+op2center);
	wait(100);
	call("java.lang.System.gc");	
	
	rename("reslice.tif");
	Resliced=getImageID();
	
	if(op1center!=0 && op2center!=0){
		
	}else if(op1center==0 && op2center!=0){
		op1center=280;
	}else if(op1center!=0 && op2center==0){
		op2center=921;
	}else{
		op1center=280; op2center=921;
	}
	
	print("lateral Z-Projection; from "+op1center+" to "+op2center+"  or center of image; "+round(nSlices/2));
	
	
	if(op2center<round(nSlices/2)){
		print("lateral Z-Projection; from "+op1center+" to "+op2center+"  or center of image; "+round(nSlices/2));
		run("Z Project...", "start="+op1center+" stop="+op2center+" projection=[Max Intensity]");
	}else{
		print("lateral Z-Projection; from "+op1center+200+" to "+op2center-200+"  or center of image; "+round(nSlices/2));
		run("Z Project...", "start="+op1center+200+" stop="+op2center-200+" projection=[Max Intensity]");
	}
	getVoxelSize(VxWidthF, VxHeightF, VxDepthF, VxUnitF);
	getDimensions(widthF, heightF, channelsF, slicesF, frames);
	rename("smallMIP.tif");
	print("widthF Lateral (z-slice); "+widthF);
	
	//	newImage("mask1.tif", "8-bit white", widthF, heightF, 1);
	//	run("Mask Median Subtraction", "mask=mask1.tif data=smallMIP.tif %=100 histogram=100");
	
	//	selectWindow("mask1.tif");
	//	close();
	
	//selectWindow("smallMIP.tif");
	
	run("Enhance Contrast", "saturated=2");
	getMinAndMax(a,b);
	
	run("16-bit");
	print("a; "+a+"  b; "+b);
	if(a!=0 && b!=65535 && b!=255 && round(b*1.1)!=65535){
		setMinAndMax(0, round(b*1.1));
		run("Apply LUT");
	}
	
	print("VxWidthF; "+VxWidthF+"   VxHeightF; "+VxHeightF+"  VxDepthF; "+VxDepthF);
	
	xyRatio=5.0196078/VxWidthF;// just 5 time smaller, 5 micron vx width
	yRatio=3.1122/VxHeightF;
	
	FinalHsize=round(heightF/yRatio);
	FinalWsize=round(widthF/xyRatio);
	
	print("xyRatio; "+xyRatio+"   FinalHsize; "+FinalHsize+"  FinalWsize; "+FinalWsize+"   yRatio; "+yRatio);
	
	run("Gamma samewindow noswing", "gamma=1.60 in=InMacro cpu=1");
	rename("smallMIP.tif");
	
	
	//	setBatchMode(false);
	//	updateDisplay();
	//	"do"
	//	exit();
	
	startiWidth=40;
	endiWidth=200;
	
	if(VxDepthF<0.3){
		startiWidth=15;
		endiWidth=90;
	}
	
	setAutoThreshold("Otsu dark");//Mean Otsu mean 127 micron
	getThreshold(lower, upper);
	setThreshold(lower, upper);
	setOption("BlackBackground", true);
	
	setForegroundColor(255, 255, 255);
	setBackgroundColor(0, 0, 0);
	run("Make Binary", "thresholded remaining");
	
	run("Size...", "width="+round(FinalWsize)+" height="+round(FinalHsize)+" interpolation=None");
	
	run("Canvas Size...", "width=65 height=110 position=Center zero");
	run("Properties...", "channels=1 slices=1 frames=1 unit=microns pixel_width="+VxWidthF*xyRatio+" pixel_height="+VxHeightF*xyRatio+" voxel_depth="+VxDepthF+"");
	run("Select All");
	run("Copy");
	MaxOBJL=0; MaxWidth=0; negativeOBJ=0;
	run("Properties...", "channels=1 slices=1 frames=1 unit=microns pixel_width="+VxWidthF*xyRatio+" pixel_height="+VxHeightF*xyRatio+" voxel_depth="+VxDepthF+"");
	
	for(iWidth=startiWidth; iWidth<endiWidth; iWidth++){
		run("Properties...", "channels=1 slices=1 frames=1 unit=microns pixel_width="+VxWidthF*xyRatio+" pixel_height="+VxHeightF*xyRatio+" voxel_depth="+VxDepthF+"");
		
		selectWindow("smallMIP.tif");
		
		run("Size...", "width="+iWidth+" height=80 interpolation=None");
		run("Remove Outliers...", "radius=2 threshold=50 which=Dark");
		run("Fill Holes");
		
		run("Canvas Size...", "width=65 height=110 position=Center zero");
		
		run("Image Correlation Atomic EQ", "samp=smallMIP.tif temp=Lateral_JFRC2010_5time_smallerMIP.tif +=10 -=10 overlap=90 parallel="+NumCPU+" rotation=1 show calculation=OBJPeasonCoeff");
		
		resultstringST = call("Image_Correlation_Atomic_EQ.getResult");
		print("resultstringST; "+resultstringST);
		
		resultstring=split(resultstringST,",");
		
		OBJScoreL=parseFloat(resultstring[3]);
		print(OBJScoreL+"  "+iWidth);
		
		if(OBJScoreL>MaxOBJL){
			
			run("Merge Channels...", "c1=Lateral_JFRC2010_5time_smallerMIP.tif c2=DUP_smallMIP.tif  c3=Lateral_JFRC2010_5time_smallerMIP.tif keep");
			saveAs("PNG", savedir+noext+"_JFRC2010_50pxMIP.png");
			close();
			
			//		print(OBJScoreL);
			MaxOBJL=OBJScoreL;
			Rot=parseFloat(resultstring[2]);
			maxX=parseFloat(resultstring[0]);
			maxY=parseFloat(resultstring[1]);
			
			elipsoidAngle=Rot;
			if (elipsoidAngle>90) 
			elipsoidAngle = -(180 - elipsoidAngle);
			
			MaxWidth=iWidth;
			negativeOBJ=0;
		}else{
			negativeOBJ=negativeOBJ+1;
		}
		selectWindow("DUP_smallMIP.tif");
		close();
		
		
		//	if(negativeOBJ==20)
		//	iWidth=350;
		selectWindow("smallMIP.tif");
		run("Paste");
	}
	
	print("2949 nImages; "+nImages()+"   MaxWidth; "+MaxWidth);
	
	run("Size...", "width="+MaxWidth+" height=110 interpolation=None");
	run("Canvas Size...", "width=65 height=110 position=Center zero");
	setMinAndMax(0, 254);
	run("Apply LUT");
	run("8-bit");
	if(PNGsave==1){
		saveAs("PNG", ""+savedir+noext+"_Lateral.png");
		close();
	}
	while(isOpen(noext+"_Lateral.png")){
		selectWindow(noext+"_Lateral.png");
		close();
	}
	
	while(isOpen("smallMIP.tif")){
		selectWindow("smallMIP.tif");
		close();
	}
	
	if(templateBr=="JFRC2010" || templateBr=="JFRC2013"){
		if(objective=="20x")
		Zsize=195;
		else
		Zsize=200;
	}else
	Zsize=151;
	
	Realvxdepth2=Zsize/((35/((FinalWsize/65)*MaxWidth))*widthF); //is real width of stack Z 
	
	maxrotation=elipsoidAngle/(Realvxdepth2/VxWidthF);
	
	print("MaxOBJL Lateral; "+MaxOBJL+"   BestiW; "+MaxWidth+"  Yshift; "+maxY+"  maxX; "+maxX+"  lateral rotation; "+maxrotation+"   Realvxdepth; "+Realvxdepth2);
	
	selectImage(nc82);
	close();
	
	if(isOpen(nc82ID)){
		selectImage(nc82ID);
		close();
	}
	if(isOpen("nc82.tif")){
		selectWindow("nc82.tif");
		close();
	}
	
	//titlelist=getList("image.titles");
	//for(iImage=0; iImage<titlelist.length; iImage++){
	//	print("Opened; "+titlelist[iImage]);
	//}
	
	
	selectWindow("reslice.tif");
	if(shrinkTo2010==true){
		if(bitDepth==8)
		run("16-bit");
		
		run("Rotation Hideo headless", "rotate="+maxrotation+" 3d in=InMacro");
		run("Translate...", "x=0 y="+round(maxY*yRatio)+" interpolation=None stack");
		run("Reslice [/]...", "output=1 start=Left rotate avoid");
		rename("nc82.tif");
		nc82=getImageID();
		print("nc82 lateral translated; "+round(maxY*yRatio)+"  shrinkTo2010; "+shrinkTo2010);
	}
	
	
	while(isOpen("reslice.tif")){
		selectWindow("reslice.tif");
		close();
	}
	
	CLEAR_MEMORY();
	
	
	//	setBatchMode(false);
	//				updateDisplay();
	//				"do"
	//				exit();
	
	
	lateralArray[0]=Realvxdepth2;
	lateralArray[1]=nc82;
	lateralArray[2]=maxrotation;
	lateralArray[3]=round((maxX*xyRatio)/2);
	lateralArray[4]=round(maxY*yRatio);
	lateralArray[5]=MaxOBJL;
}

function DupAvePprocessing (nc82,NumCPU,bitd,projectionSt){
	
	selectWindow("nc82.tif");
	oriwidth=getWidth(); oriheight=getHeight(); orislice=nSlices();
	
	//if(bitd!=8){
	//		print("Mask dimension; oriwidth; "+oriwidth+"   oriheight; "+oriheight+"  orislice; "+orislice);
	
	//		newImage("mask.tif", "8-bit white", oriwidth, oriheight, orislice);
	//		run("Mask Median Subtraction", "mask=mask.tif data=nc82.tif %=100 histogram=100");
	
	//		selectWindow("mask.tif");
	//		close();
	//	}
	selectImage(nc82);
	
	if(projectionSt=="JFRC2010_MedPro.tif")
	run("Z Project...", "start=5 stop="+nSlices-10+" projection=[Median]");//Max Intensity
	
	if(projectionSt=="JFRC2010_AvePro.png")
	run("Z Project...", "start=15 stop="+nSlices-10+" projection=[Average Intensity]");//Max Intensity
	
	if(projectionSt=="JFRC2010_MIP.tif")
	run("Z Project...", "start=5 stop="+nSlices-10+" projection=[Max Intensity]");//Max Intensity
	
	rename("OriginalProjection.tif");
	
	resetMinAndMax();
	run("16-bit");
	
	run("Duplicate...", "title=DUPaveP.tif");
	getMinAndMax(min, max);
	if(min!=0 && max!=255)
	run("Apply LUT");
	
	//setBatchMode(false);
	//updateDisplay();
	//"do"
	//exit();
	
	//run("Gamma ", "gamma=1.5 in=InMacro cpu="+NumCPU+"");
	//gammaup=getTitle();
	
	//selectWindow("DUPaveP.tif");
	//close();
	
	//selectWindow(gammaup);
	//rename("DUPaveP.tif");
	
	run("Enhance Contrast", "saturated=1");
	getMinAndMax(min, max);
	
	bitd=bitDepth();
	if(bitd==8)
	run("16-bit");
	
	setMinAndMax(min, max);
	if(min!=0 && max!=65535)
	run("Apply LUT");
}//function DupAvePprocessing (

function rotateshift3D (resliceLongLength,finalshiftX,Zoomratio,finalshiftY,elipsoidAngle,shrinkTo2010,cropWidth,cropHeight,Ori_widthVx,Ori_heightVx,depth,reverseR){
	run("Canvas Size...", "width="+resliceLongLength+" height="+resliceLongLength+" position=Center zero");
	run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+depth+"");
	print("3482 Translated X; "+round(finalshiftX)+"  Y; "+round(finalshiftY)+", nc82, elipsoidAngle; "+elipsoidAngle+"   Zoomratio; "+Zoomratio+"  Canvas W; "+round(cropWidth/Zoomratio)+"   Canvas H; "+round(cropHeight/Zoomratio));
	print("reverseR; "+reverseR);
	if(reverseR==0){
		if(bitDepth==8)
		run("16-bit");
		run("Rotation Hideo headless", "rotate="+elipsoidAngle+" 3d in=InMacro");
		
		run("Translate...", "x="+round(finalshiftX)+" y="+round(finalshiftY)+" interpolation=None stack");
	}else{
		run("Translate...", "x="+round(finalshiftX)+" y="+round(finalshiftY)+" interpolation=None stack");
		if(bitDepth==8)
		run("16-bit");
		run("Rotation Hideo headless", "rotate="+elipsoidAngle+" 3d in=InMacro");
		print("reverseR; true");
	}
	run("Properties...", "channels=1 slices="+nSlices+" frames=1 unit=microns pixel_width="+Ori_widthVx+" pixel_height="+Ori_heightVx+" voxel_depth="+depth+"");
	
	orizoomratio=Zoomratio;
	if(shrinkTo2010==false)
	Zoomratio=1;
	run("Canvas Size...", "width="+round(cropWidth/Zoomratio)+" height="+round(cropHeight/Zoomratio)+" position=Center zero");
	
	Zoomratio=orizoomratio;
}












