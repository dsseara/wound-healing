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
dropboxPath = '/Users/Danny/Downloads/reactinconservationcodeandfirstresults';
savePath = fullfile(dropboxPath);
fnames = {fullfile(savePath,'actinkymo1CB.txt'),...
    fullfile(savePath, 'actinkymo1PS.txt'),...
    fullfile(savePath, 'actinkymo1LM.txt')};
imagefname = fullfile(savePath, 'actinkymo1.tif');
integrationWidths = [10, 15; 0, 25; 20, 40]; % found by trial and error to produce minimal overlap
rescalePixelsX = 1; % Rescale pixel values to  whole numbers if kymograph  has been rescaled in space dimension
rescalePixelsT = 1; % Rescale pixel values to  whole numbers if kymograph  has been rescaled in time dimension
pix2um = 0.167; % Change pixel values to physical values in space dimension
pix2min = 5; % Change pixel values to physical values in time dimension
legendArr = {'cell body', 'purse string', 'lamellapodia'};

savestuff = false;
savefname = {'intensityTimeSeries_cellBody.txt', 'intensityTimeSeries_purseString.txt', 'intensityTimeSeries_lamellapodia.txt'};
%%% CHANGE %%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%%

kymo = imread(imagefname);
[nrows, ncols] = size(kymo);

%% 
% Get intensity over time for each cell part
for ii = 1:numel(fnames)
    savefname_full = fullfile(savePath, savefname{ii});
    [intensity{ii}, tArray{ii}, roiPoints{ii}] = actinIntensity(fnames{ii}, kymo,...
        integrationWidths(ii, :), savestuff, savefname_full, [rescalePixelsX, rescalePixelsT], pix2min);
end

% Plot the intensities over time
colors = lines(numel(intensity));

figure, hold on;
for ii = 1:numel(intensity)
    plot(tArray{ii}, intensity{ii}, 'Color', colors(ii,:))
end

xlabel('time (mins)')
ylabel('Intensity (a.u.)')
legend(legendArr{:}, 'Location', 'southeast');
llmFig('font', 'Arial') % implements figure aesthetics

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
% set(gca, 'YDir', 'reverse')
% llmFig('font', 'Arial')

if savestuff
    saveas(gcf, fullfile(savePath, 'intensityRegions.fig'), 'fig')
    saveas(gcf, fullfile(savePath, 'intensityRegions.pdf'), 'pdf')
end

%%
% This next part begins the integration over intensities of different cell parts to
% attempt to account for the flow of actin from one part to another.
% As written, it finds the total fluorescence in the lamellapodium, and compares it to the
% change in fluorescence of the purse string and cell body.
%
% See documentation in integrateIntensity.m

% Get shortest time array, only integrate as long as that one
[minSize, minInd] = min(cellfun(@(C) size(C,1), intensity));
shortestTime = tArray{minInd};


integrals = [];

% Perform integrations
for ii = 1:numel(intensity)
    integrals(ii) = trapz(tArray{ii}(1:minSize), intensity{ii}(1:minSize)-min(intensity{ii}));
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
llmFig('font', 'Arial')

if savestuff
    saveas(gcf, fullfile(savePath, 'intensityIntegrals.fig'), 'fig')
    saveas(gcf, fullfile(savePath, 'intensityIntegrals.tif'), 'tif')
    saveas(gcf, fullfile(savePath, 'intensityIntegrals.eps'), 'epsc')
end

%%
% Perform linear regression on specified region

%%% CHANGE %%%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%
linRegFlag = false;
savefname = fullfile(savePath, 'linearRegressionResults.csv');
%%% CHANGE %%%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%

if linRegFlag
    p = zeros(numel(intensity), 2); % array to store slope and intercept of linear fit
    figure, hold on;
    for ii = 1:numel(intensity)
        x0 = tArray{ii};
        mask = x0>60 & x0<80;
        x0 = x0(mask);
        maskedData = intensity{ii}(mask);
        x1 = linspace(min(x0), max(x0), 100);
        [p(ii, :), s] = polyfit(x0, maskedData', 1);
        y1 = polyval(p(ii, :), x1);
        plot((1:numel(intensity{ii})).*pix2min, intensity{ii}, 'Color', colors(ii, :))
        plot(x1, y1+100, 'k--')%, 'Color', colors(ii, :))
    end
    llmFig('font', 'Arial')

    if savestuff
        slope = p(:, 1);
        intercept = p(:, 2);
        t = table(slope, intercept, 'RowNames', legendArr);
        writetable(t, savefname, 'WriteRowNames', true)
    end
end