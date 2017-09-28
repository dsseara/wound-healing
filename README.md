# Wound healing actin conservation

This repository contains functions to analyze the image intensity from kymographs of a wound healing experiment to assess where fluorescently labeled actin is flowing.

Before using these functions, first create a kymograph along a slice of a wound healing movie using imageJ. After creating the kymograph, select the regions along which you want to measure the actin intensity. For example, these could include the lamellapodia over time, the purse string over time, the area behind the purse string over time, or whatever else you find interesting. Change the width of the line using `Edit>Options>Line Width` to get a rough idea of how wide an area each ROI will have to be. *If you have more than one ROI, make sure they all start at the same time*.

Once you have the ROIs, save them using `File>Save As>XY Coordinates`. This saves a `.txt` file with the xy-coordinates of each vertex of the segmeented line you drew. 

To use these functions, first clone the repository:
```
$ cd path/of/your/choosing/
$ git clone https://github.com/dsseara/woundActinConservation
```

Next, open `actinConservationWorkflow.m`. In there, there is a list of variables that you must change to analyze the experiments you specifically want to. These include:

fnames = 
imagefname = 'kymograph_500x500.tif';
integrationWidths = [70, 20; 20, 20; 70, 50]; % found by trial and error to produce minimal overlap
savestuff = false;
savefname = {'cellBodyIntegratedIntensity.txt', 'purseStringIntegratedIntensity.txt', 'lamellaIntegratedIntensity.txt'};
conversions = 500 ./ [165, 32]; % 500 pixels per (165 cm, 32 frames), from kymograph tif stack
legendArr = {'cell body', 'purse string', 'lamellapodia'};