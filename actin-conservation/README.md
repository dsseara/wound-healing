# Actin conservation in wound healing

DEPENDENCIES:
llmFig.m, bresenham.m (both found [here](https://github.com/dsseara/mtool))

This repository contains functions to analyze the image intensity from kymographs of a wound healing experiment to assess where fluorescently labeled actin is flowing.

### Before using the code
Before using these functions, first create a kymograph along a slice of a wound healing movie using imageJ. After creating the kymograph, select the regions along which you want to measure the actin intensity. For example, these could include the lamellapodia over time, the purse string over time, the area behind the purse string over time, or whatever else you find interesting. Change the width of the line using `Edit>Options>Line Width` to get a rough idea of how wide an area each ROI will have to be. *If you have more than one ROI, make sure they all start at the same time*.

Once you have the ROIs, save them using `File>Save As>XY Coordinates`. This saves a `.txt` file with the xy-coordinates of each vertex of the segmeented line you drew. 

### Using the code
To use these functions, first clone the repository:
```
$ cd path/of/your/choosing/
$ git clone https://github.com/dsseara/wound-healing
```

Next, open `actinConservationWorkflow.m`. In there, there is a list of variables that you must change to analyze the experiments you specifically want to. These include:

```
dropboxPath = path to where all raw data and analyses using this repository are stored
savepath = specific subfolder of dropboxPath where a particular run of this repository 
fnames = files of xy-coords of ROIs saved using ImageJ
imagefname = path to kymograph image to anayze
integrationWidths = Nx2 array of widths to the left and right of the N ROIs chosen. This is normally found by trial and error, but should be about half of the width in either direction of the line width chosen to pick the ROI in ImageJ above. Chosen to minimize both overlap and exluded areas between regions.
rescalePixelsX = Scaling of xy-coords of ROIs from pixels of the original kymograph to a scaled version of the kymograph along spatial dimension (not always necessary).
rescalePixelsT = Scaling of xy-coords of ROIs from pixels of the original kymograph to a scaled version of the kymograph along temporal dimension (not always necessary)
pix2um = conversion from pixel values to microns
pix2min = conversion from pixel values to mins

	For example, if the original kymograph was a 100x50 pixel image with 0.1 um/pixel and 5 min/frame, but was rescaled to (200x300), and the ROI points are still given in 100x50 pixel coordinates, we would have:
		rescalePixelsX = 300/50
		rescalePixelsT = 200/100
		pix2um = 50 * 0.1 / 300
		pix2min = 100 * 5 / 200

legendArr = array of strings for legends and saving
savestuff = Boolean to save stuff
savefname = names of files to save the intensity time series;
```

From these, the function should be able to run itself. 

It picks each ROI, interpolates a line between the verticies, adds up all the intensities in the space dimension (between the values of ROIline ± integrationWidths) for each time point, and plots these values. An assumption is made that each rows correspond time, and columns correspond to space.

It also plots the regions over which the integration is done as a sanity check that you're calculating what you think you are.

There is also a section at the end of `actinConservationWorkflow.m` that does something specific for the case where the lamellapodia recedes into the purse string. The total integral of intensity of the lamellapodia is calculated, and the integral of the purse string intensity (minus the first point) is found, to see if the increase in purse string intensity is attributable to the lamellapodia. This should be commented out if need be.