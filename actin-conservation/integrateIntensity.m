% This function integrates the intensity over time plot that is the output of actinIntensity.m
%
% Prior to running this function, run actinIntensity
%
% Parameters
% ----------
% intensity : array
%     array of the intensity over time, output of actinIntensity.m
% tArray : array
%     array of tvalues to integrate over, to be used in trapz function
% normBool : boolean
%     boolean that specifies, if true, to subtract off the first value of the array intensity.
%     If true, gives the total change in intensity over time.
%
% Returns
% -------
% totalIntensity : scalar
%     Result of integration
%
% Created by Daniel Seara, 09/29/2017
% Lab of Living Matter, Yale University
% PI: Dr. Michael P. Murrell
% livingmatter.yale.edu
function totalIntensity = integrateIntensity(intensity, tArray, normBool)
    if normBool
        totalIntensity = trapz(tArray, intensity(1:numel(tArray))-intensity(1));
    else
        totalIntensity = trapz(tArray, intensity(1:numel(tArray)));
    end
end
