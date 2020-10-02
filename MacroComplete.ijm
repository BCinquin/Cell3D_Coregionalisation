// 3D Analysis of Two channels
// Use of 3D ROI MANAGER
//need to install CLIJ ! GPU ImageJ
//////////////////////////////////
//////////Open Images/////////////
/////// Working Space   //////////
//////////////////////////////////
run("CLIJ Macro Extensions", "cl_device=");
PathImage_Nucleus= File.openDialog("Choose Nucleus image");
DirSource=File.getParent(PathImage_Nucleus);
PathImage_2ndLabel= File.openDialog("Choose Differentiation image");
DirSource2=File.getParent(PathImage_2ndLabel);
Dir1 = getDirectory("Choose a Directory to save images");

Dialog.create("Information Relative to Analysed Images");
Dialog.addMessage("Nucleus Image is        "+PathImage_Nucleus);
Dialog.addMessage("Second Channel Image is "+PathImage_2ndLabel);
Dialog.addMessage("Saving Path is          "+Dir1);
Dialog.addMessage("If this is not correct please press cancel     ");
Dialog.show();
//////////////////////////////////
//////////Preprocess Images///////
//////////////////////////////////

//Open Images
open(PathImage_Nucleus);
Name_Nucleus =getTitle();
open(PathImage_2ndLabel);
Name_2ndlabel =getTitle();
//Normalize Intensity for better Segmentation
run("Enhance Contrast...", "saturated=0.3 normalize process_all");	
run("Subtract Background...", "rolling=80 stack");

//Using Clij

//run("CLIJ Macro Extensions", "cl_device=");
Ext.CLIJ_clear();
Ext.CLIJ_push(Name_Nucleus);
Ext.CLIJ_automaticThreshold(Name_Nucleus, "CLIJ_"+Name_Nucleus, "Otsu");

Ext.CLIJ_convertUInt8("CLIJ_"+Name_Nucleus, "CLIJ_8"+Name_Nucleus);
Ext.CLIJ_multiplyImageAndScalar("CLIJ_8"+Name_Nucleus, "CLIJ_8_bin"+Name_Nucleus, 255);
//Remove Outliers
Ext.CLIJ_pull("CLIJ_8_bin"+Name_Nucleus);
Ext.CLIJ_clear();
run("Remove Outliers...", "radius=10 threshold=50 which=Bright stack");

run("Distance Transform Watershed 3D", "distances=[Borgefors (3,4,5)] output=[16 bits] normalize dynamic=2 connectivity=26");
rename("CLIJ_8_bin_watershed");
Ext.CLIJ_push("CLIJ_8_bin_watershed");
Ext.CLIJ_convertUInt8("CLIJ_8_bin_watershed", "CLIJ_8_bin_8_watershed");
Ext.CLIJ_multiplyImageAndScalar("CLIJ_8_bin_8_watershed", "CLIJ_8_bin_8_bin_watershed", 255);
Ext.CLIJ_pull("CLIJ_8_bin_8_bin_watershed");
Ext.CLIJ_clear();
run("Watershed", "stack");
rename(Name_Nucleus+"watershaded_mask");
//////////////////////////////////
//////Fist channel : Nucleus//////
//////////////////////////////////
run("3D Objects Counter", "threshold=128 slice=62 min.=200 max.=179512320 exclude_objects_on_edges objects summary");
getMinAndMax(min, max);
Nucleus_Num = max;
rename("3DObjects_Nucleus");
//Each number is a nucleus
PositiveCell_Index=newArray(Nucleus_Num);
count = 0;

for (i = 1; i < Nucleus_Num; i++) {
	selectWindow("3DObjects_Nucleus");
	run("Select All");	
	setThreshold(i, i);
	run("Analyze Particles...", "size=200-Infinity display exclude clear include add stack");
	for (j = 0; j < roiManager("count"); j++) {
		if (j<roiManager("count")-1){
			roiManager("select", j);
			ActualSlice = getSliceNumber();
			roiManager("select", j+1);
			NextSlice = getSliceNumber();
			if(ActualSlice == NextSlice){
				print(ActualSlice,NextSlice);
				selectArray = newArray(j,j+1);
				roiManager("select",selectArray);
				roiManager("Combine");
				roiManager("Add");
				roiManager("select",selectArray);
				roiManager("Delete"); 
			}
		}
	}
		roiManager("Sort");
		Array_to_delete = newArray(roiManager("count"));
		Roi_number = roiManager("count");
	for (j=0;j <Roi_number;j++){
		roiManager("Select",j);
		Array_to_delete[j]=j;
		run("Make Band...", "band=5");
		roiManager("Add");
	}
	roiManager("select",Array_to_delete);
	roiManager("Delete");
	//Differentation Test Make sure it's the only table
	selectWindow(Name_2ndlabel);
	Intensity_Array = newArray(Roi_number);
	for (j=0;j <Roi_number;j++){
		roiManager("Select",j);
		run("Measure");
		Intensity_Array[j] = getResult("Mean", j);
	}
	Array.getStatistics(Intensity_Array, min, max, mean, stdDev);
	if(mean >20000){
		print("This is the "+count+1+"th positive cell");
		PositiveCell_Index[count] = i;
		count = count+1;
	}
	roiManager("deselect");roiManager("delete");
	selectWindow("ROI Manager");run("Close");
}
		

//Build RoiArray : How many Rois belong to the same slice
/*Array_SliceNumber =newArray(roiManager("count"));
for (i = 0; i < roiManager("count"); i++) {
	roiManager("select", i);
	ROI_Name = Roi.getName();
	Slice = substring(ROI_Name,0,4);
	SliceNumber = parseInt(Slice);	
	Array_SliceNumber[i] = SliceNumber;
}
Array.show(Array_SliceNumber);
RoiArray= newArray(1);
for (i = 0; i < Array_SliceNumber.length-1; i++) {
	RoiArray[0] =i;
	if (Array_SliceNumber[i]==Array_SliceNumber[i+1]){
		RoiArray = Array.concat(RoiArray, i+1);
	}
	//if (RoiArray.length == 1){
	//	RoiArray= RoiArray.deleteValue(RoiArray, i); Array.
	//}
}
combine(RoiArray);
	Array.show(RoiArray);
	Array_SliceNumber = Array.deleteIndex(Array_SliceNumber,0);



function combine(RoiArray){
	roiManager("select", RoiArray);
	if (RoiArray.length>1){
		roiManager("Combine");
		roiManager("Add");
		roiManager("Delete");
	}
	else {
		roiManager("Add");
		roiManager("Delete");
	}
}
*/
//////////////////////////////////
///Second Channel : Second Label//
//////////////////////////////////


//////////////////////////////////
///// 3D Spatial Statistics //////
//////////////////////////////////