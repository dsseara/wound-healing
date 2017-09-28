% Script for generating data on actin conservation in a kymograph.
% Only change the variables in the first block of text surrounded by
% the word "Change" to enter the names of the ROI files
% Most of the variables go into the helper function integrateActinIntensity
% See the documentation there for definitions of all the variables.
%
% Created by Daniel Seara, 09/27/2017
% Lab of Living Matter, Yale University
% PI: Dr. Michael P. Murrell
% livingmatter.yale.edu

clear, close all

%%% CHANGE %%%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%
fnames = {'cellBodyROI_xyCoords.txt', 'purseStringROI_xyCoords.txt', 'lamellapodiaROI_xyCoords.txt'};
imagefname = 'kymograph_500x500.tif';
integrationWidths = [70, 20; 20, 20; 70, 50]; % found by trial and error to produce minimal overlap
savestuff = false;
savefname = {'cellBodyIntegratedIntensity.txt', 'purseStringIntegratedIntensity.txt', 'lamellaIntegratedIntensity.txt'};
conversions = 500 ./ [165, 32]; % 500 pixels per (165 cm, 32 frames), from kymograph tif stack
legendArr = {'cell body', 'purse string', 'lamellapodia'};
%%% CHANGE %%%%%%%%%%%%% CHANGE %%%%%%%%%%%% CHANGE %%%%%%%%%%%%%%

kymo = imread(imagefname);

%% 
% Perform the integration
for ii = 1:numel(fnames)
    [integratedIntensity{ii}, roiPoints{ii}] = integrateActinIntensity(fnames{ii}, kymo,...
        integrationWidths(ii, :), savestuff, savefname{ii}, conversions);
end

% Plot the integrated intensities
colors = lines(numel(integratedIntensity));

figure, hold on;
for ii = 1:numel(integratedIntensity)
    plot((1:numel(integratedIntensity{ii}))./conversions(2),...
         integratedIntensity{ii}, 'Color', colors(ii,:))
end

xlabel('time (mins)')
ylabel('total intensity')
legend(legendArr{:}, 'Location', 'southeast');
llmFig % implements figure aesthetics

if savestuff
    saveas(gcf, 'actinIntensityConservation.fig', 'fig')
    saveas(gcf, 'actinIntensityConservation.tif', 'tif')
    saveas(gcf, 'actinIntensityConservation.eps', 'epsc')
end

%%
% Plot all the integrated regions
figure
h = pcolor(kymo);
colormap(gray);
set(h, 'EdgeColor', 'none');
xlim([0, size(kymo, 2)]);
ylim([0, size(kymo, 1)]);
axis equal;
hold on;

for ii = 1:numel(roiPoints)
    plot(roiPoints{ii}(:,1), roiPoints{ii}(:, 2),...
        'Color', colors(ii,:), 'LineWidth', 2)
    plot(roiPoints{ii}(:,1)+integrationWidths(ii, 2), roiPoints{ii}(:, 2),...
        '--', 'Color', colors(ii,:), 'LineWidth', 2)
    plot(roiPoints{ii}(:,1)-integrationWidths(ii, 1), roiPoints{ii}(:, 2),...
        '--', 'Color', colors(ii,:), 'LineWidth', 2)
end

%%
% This next part begins the integration over intensities of different cell parts to
% attempt to account for the flow of actin from one part to another.
% As written, it finds the total fluorescence in the lamellapodium, and compares it to the
% change in fluorescence of the purse string and cell body.
% Change according to your own interests.

cellBody = integratedIntensity{1};
purseString = integratedIntensity{2};
lamella = integratedIntensity{3};

pix2min = (conversions(2)*5); % Each frame is 5 mins apart

t = (1:numel(lamella))./pix2min;
lamella_integral = trapz(t, lamella);
purseString_integral_normed = trapz(t, purseString(1:numel(lamella)) - purseString(1));
cellBody_integral_normed =  trapz(t, cellBody(1:numel(lamella)) - cellBody(1));

integrals = [cellBody_integral_normed; purseString_integral_normed; lamella_integral; ];
fHand = figure;
aHand = axes('parent', fHand);
hold(aHand, 'on')
colors = lines(numel(integrals));
for ii = 1:numel(integrals)
    bar(ii, integrals(ii), 'parent', aHand, 'facecolor', colors(ii,:));
end
set(gca, 'XTick', 1:numel(integrals), 'XTickLabel', {'cell body', 'purse string', 'lamellapodia'})

if savestuff
    saveas(gcf, 'normalizedIntegrals.fig', 'fig')
    saveas(gcf, 'normalizedIntegrals.tif', 'tif')
    saveas(gcf, 'normalizedIntegrals.eps', 'epsc')
end