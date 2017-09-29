% Script for generating data on actin conservation in a kymograph.
% Only change the variables in the blocks of text surrounded by
% the word "Change"
% Most of the variables go into the helper function integrateActinIntensity
% See the documentation there for definitions of all the variables.
%
% Created by Daniel Seara, 09/27/2017
% Lab of Living Matter, Yale University
% PI: Dr. Michael P. Murrell
% livingmatter.yale.edu

clear, close all

%%% CHANGE %%%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%
fnames = {'/Users/Danny/Dropbox/Manuscript_WoundHealing/Figure5_Transition/ck666/cellBodyROI_xyCoords.txt',...
    '/Users/Danny/Dropbox/Manuscript_WoundHealing/Figure5_Transition/ck666/purseStringROI_xyCoords.txt',...
    '/Users/Danny/Dropbox/Manuscript_WoundHealing/Figure5_Transition/ck666/cellFrontROI_xyCoords.txt'};
imagefname = '/Users/Danny/Dropbox/Manuscript_WoundHealing/Figure5_Transition/ck666/kymograph_500x500.tif';
integrationWidths = [10, 10; 10, 10; 10, 10]; % found by trial and error to produce minimal overlap
rescalePixelsX = 1; % Rescale pixel values to  whole numbers if kymograph  has been rescaled in space dimension
rescalePixelsT = 1; % Rescale pixel values to  whole numbers if kymograph  has been rescaled in time dimension
pix2um = 238 * 0.167 / 500; % Change pixel values to physical values in space dimension
pix2min = 62 * 5 / 500; % Change pixel values to physical values in time dimension
legendArr = {'cell body', 'purse string', 'cell front'};

savestuff = false;
savePath = '/Users/Danny/Dropbox/Manuscript_WoundHealing/Figure5_Transition/ck666';
savefname = {'cellBodyIntegratedIntensity.txt', 'purseStringIntegratedIntensity.txt', 'cellFrontIntensity.txt'};
%%% CHANGE %%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%%

kymo = imread(imagefname);
[nrows, ncols] = size(kymo);

%% 
% Get intensity over time for each cell part
for ii = 1:numel(fnames)
    savefname_full = fullfile(savePath, savefname{ii});
    [intensity{ii}, roiPoints{ii}] = actinIntensity(fnames{ii}, kymo,...
        integrationWidths(ii, :), savestuff, savefname_full, [rescalePixelsX, rescalePixelsT]);
end

% Plot the intensities over time
colors = lines(numel(intensity));

figure, hold on;
for ii = 1:numel(intensity)
    plot((1:numel(intensity{ii})).*pix2min,...
         intensity{ii}, 'Color', colors(ii,:))
end

xlabel('time (mins)')
ylabel('Intensity (a.u.)')
legend(legendArr{:}, 'Location', 'southeast');
llmFig % implements figure aesthetics

if savestuff
    saveas(gcf, fullfile(savePath, 'actinIntensity.fig'), 'fig')
    saveas(gcf, fullfile(savePath, 'actinIntensity.tif'), 'tif')
    saveas(gcf, fullfile(savePath, 'actinIntensity.eps'), 'epsc')
end

%%
% Plot all the cell regions analyzed
figure
h = pcolor((1:ncols).*pix2um, (1:nrows).*pix2min, kymo);
colormap(gray);
set(h, 'EdgeColor', 'none');
axis square;
hold on;

for ii = 1:numel(roiPoints)
    plot((roiPoints{ii}(:,1)+integrationWidths(ii, 2)).*pix2um,...
        roiPoints{ii}(:, 2).*pix2min, '--', 'Color', colors(ii,:), 'LineWidth', 2)
    plot((roiPoints{ii}(:,1)-integrationWidths(ii, 1)).*pix2um,...
        roiPoints{ii}(:, 2).*pix2min, '--', 'Color', colors(ii,:), 'LineWidth', 2)
end
xlabel('position (\mum)')
ylabel('time (min)')
set(gca, 'YDIr', 'reverse')
llmFig

if savestuff
    saveas(gcf, fullfile(savePath, 'intensityRegions.fig'), 'fig')
    saveas(gcf, fullfile(savePath, 'intensityRegions.tif'), 'tif')
    saveas(gcf, fullfile(savePath, 'intensityRegions.eps'), 'epsc')
end

%%
% This next part begins the integration over intensities of different cell parts to
% attempt to account for the flow of actin from one part to another.
% As written, it finds the total fluorescence in the lamellapodium, and compares it to the
% change in fluorescence of the purse string and cell body.
%
% See documentation in integrateIntensity.m

%%% CHANGE %%%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%
tArray = (1:numel(intensity{3})).*pix2min; % only integrate over extend of lamellapodia
normBools = [true, true, false]; % only normalize cell body and purse string, not lamellapodia
%%% CHANGE %%%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%

integrals = [];

% Perform integrations
for ii = 1:numel(intensity)
    integrals(ii) = integrateIntensity(intensity{ii}, tArray, normBools(ii));
end

fHand = figure;
aHand = axes('parent', fHand);
hold(aHand, 'on')
colors = lines(numel(integrals));
for ii = 1:numel(integrals)
    bar(ii, integrals(ii), 'parent', aHand, 'facecolor', colors(ii,:));
end
set(gca, 'XTick', 1:numel(integrals), 'XTickLabel', legendArr)

ylabel('Integrated Intensity')
set(gca,'XTickLabelRotation', -45)
llmFig

if savestuff
    saveas(gcf, fullfile(savePath, 'intensityIntegrals.fig'), 'fig')
    saveas(gcf, fullfile(savePath, 'intensityIntegrals.tif'), 'tif')
    saveas(gcf, fullfile(savePath, 'intensityIntegrals.eps'), 'epsc')
end