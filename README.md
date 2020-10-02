# Cell3D_Coregionalisation
on 2 channels confocal stack : looking for cells presenting differentiation markers

This macro is using CLIJ plugin to perform some steps using the GPU to increase the speed
The two channels need to be separated
The first one is the nuclei channel
The second one is the differentiation marker channel
The intensity is normalised with a substract background step to ease the segmentation process

Image is binarized
outliers are taken away
3D Watershading is performed to separate nuclei when they are too close to each other (along the Z axis)
2D Watershad is performed, slice by slice in 2D

3D Objects counter is use and a value is given for each nuclei
Select each nuclei
    When it exist several ROI for a slice, they are combined 
    I want One ROI per slice and per nucleus
    I will draw a band around each nuclei
    Mesure the intensity present in the differentiation channel
    If the intensity is above a certain value, the cell is counted as positive : showing differentiation markers
    
    
