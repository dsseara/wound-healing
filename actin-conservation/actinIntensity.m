% This function calculates the total intensity over a specified region in a kymograph
%
% Prior to running this function, a segmented line ROI should be drawn on a kymograph in imageJ,
% and the xy-coordinates of the line should be saved. This will interpolate a line between the
% given points, and sum along the row of each pixel, out a certain distance given by the two
% elements in integrationWidths.
% 
% Parameters
% ----------
% fnames : string
%     Structure with filenames that contain the xy coordinates of ROIs drawn on imageJ
% img : array
%     array of loaded kymograph image data
% integrationWidths : 1x2 array
%     Array that contains the width to integrate over to the left and right of the ROI line.
%     First element is number of pixels to the left of the line, 2nd element is number to the right
% savestuff : bool
%     True if you want to save the integrated intensities to a txt file. False if not.
% savefname : string
%     If savestuff, the name of the file to save
% conversions : array, optional
%     Array that contains the conversion from physical units to pixel values. To be used
%     as indices in the loaded movie data. If xy coordinates are in pixels (i.e. whole numbers),
%     leave as []
%
% Returns
% -------
% intensity : array
%     Array of the integrated intensity over time of a kymograph
% roiPointsFull : array
%     Array of the full, interpolated values between the vertices exported from the imageJ line
%     segment ROI
%
% Created by Daniel Seara, 09/27/2017
% Lab of Living Matter, Yale University
% PI: Dr. Michael P. Murrell
% livingmatter.yale.edu

function [intensity, tArray, roiPointsFull] = actinIntensity(roifname, img, integrationWidths, savestuff, savefname, conversions, pix2min)
    
    % load roi points
    roiPoints = dlmread(roifname);

    % Get total number of points on ROI line
    roiNPoints = size(roiPoints, 1);

    if ~isempty(conversions)
        roiPoints = floor(roiPoints .* repmat(conversions, roiNPoints, 1));
    end

    % now get the straight lines between the points given by the ROI
    roiPointsFull = [];

    for ii = 1:roiNPoints-1
        [x, y] = bresenham(roiPoints(ii, 1), roiPoints(ii, 2),...
                           roiPoints(ii+1, 1), roiPoints(ii+1, 2));
        roiPointsFull = [roiPointsFull; x, y];
    end

    [~, ncols] = size(img);

    time = [];
    intensity = [];

    % See docs for unique on these indices, but basically:
    % roiPointsFull(ia, 1) = uniqueTimes
    % roiPointsFull(:, 1) = uniqueTimes(ic)
    [uniqueTimes, ia, ic] = unique(roiPointsFull(:, 2));

    % Check is ia is increasing or decreasing, which will effect how to do the sum
    % below.
    plusminus = sign(ia(2)-ia(1));

    % Ensure that the integration region doesn't exceed the size of the image
    for ii = 1:numel(ia(1:end-1))
        disp(ii)
        % keyboard
        ind = ia(ii);
        indNext = ia(ii + 1) - plusminus;

        if roiPointsFull(indNext, 1) + integrationWidths(2) > ncols &&...
           roiPointsFull(ind, 1) - integrationWidths(1) >= 0

            intensity = [intensity;...
                sum(img(roiPointsFull(ind, 2), roiPointsFull(ind, 1)-integrationWidths(1):end))];
        
        elseif roiPointsFull(indNext, 1) + integrationWidths(2) < ncols &&...
               roiPointsFull(ind, 1) - integrationWidths(1) <= 0
            
            intensity = [intensity;...
                sum(img(roiPointsFull(ind, 2), 1:roiPointsFull(indNext, 1)+integrationWidths(2)))];
        
        elseif roiPointsFull(indNext, 1) + integrationWidths(2) > ncols &&...
               roiPointsFull(ind, 1) - integrationWidths(1) <= 0
            
            intensity = [intensity;...
                sum(img(roiPointsFull(ind, 2), 1:end))];
        
        else
            intensity = [intensity;...
                sum(img(roiPointsFull(ind, 2), roiPointsFull(ind, 1)-integrationWidths(1):...
                                              roiPointsFull(indNext, 1)+integrationWidths(2)))];
        end
    end

    % Get unique points to return
    roiPointsFull = roiPointsFull(ia, :);

    % Get time array to return and save out
    tArray = (1:numel(intensity)) .* pix2min;

    if savestuff
        fid = fopen(savefname, 'w');
        fprintf(fid, '%5.4f \t %5.4f \n', tArray, intensity);
        fclose(fid);
    end
