%% AQP4 polarization plug and chug function
% Michael Giannetto
% Nedergaard Lab
% Originally created 2/26/2022
% Most recently edited: 9/14/2022
%{
This function takes an excel file as an input, where every other column is a
blood vessel line scan measured in ImageJ using plot profile function. Each
vessel should have 4 rows above the measurement in this order Animal ID, brain
region, vessel number, image number. Then the 5th row should be "brightness/position".
Brightness/position of each vessel should be pasted into file from imagej
plot profile.
If need an example excel file, see AER polarization data.

The excel file is loaded into MATLAB, the polariztion index of each
blood vessel is then calculated and output as an excel file. Polarization
is calculated as mean peak intensity (3 positions around each peak) minus
background signal (mean first 37 positions of trace)

Edited 9/14/2022 
Now prompts the user to select which excel file to open,asks user to
specify the output name and image resolution. This allows the function to be used
without coding experience. This function will return a data table to the workspace and
output an excel file of that table

Edited 12/15/2022
Now automatically creates output filename based on the input filename. No
longer asks for MATLAB variable in workspace.
%}

%% User defined variables
function [dataTable]= AQP4plugchug()
clear
excelFile = uigetfile('*.*'); %User selects input excel file
outputFile = strcat("aqp4_Pol_",excelFile); %Define output filename
resolution = inputdlg("Specify Image Resolution"); % Define resolution, accepts 1024 or 2048

workspace = inputdlg("Type <yes> if you want to create MATLAB variable");
resolution = str2num(resolution{1});
if excelFile == 0
    error('Must select an excel file')
end
if resolution == 0
    error('Must specify image resolution')
end

%% Load excel file, calculate polarization index
%Create a double precision matrix data, and cell array cell
[data, text, cellData] = xlsread(excelFile);


bloodVessels = data(3:end,2:2:end); %Create a matrix with only blood vessel scan info
endData = size(data,2);
%This step is necessary to get correct ID names
AnimalID = cellData(1,1:2:endData); %Create a cell array will animalID's
Section = cellData(2,1:2:endData);
Vessel = cellData(3,1:2:endData); %Create a cell array with vessel numbers
Image = cellData(4,1:2:endData);

%Function calculates polarization index. See end of script
[PolIndex, peakLoc, peakInt, base, width, tooWide] =...
    aqp4Pol(bloodVessels,resolution);

%Take mean of peak and baseline. Useful to look at later
meanPeak = mean(peakInt,1);
meanBaseline = mean(base,1);

%Check for outliers (width between peaks larger than 5 um)
widthOK = repmat("OK",size(bloodVessels,2),1);
widthOK(tooWide) = 'Too Wide';

%% Saving the data

% Create table of data, format is needed to save to excel
T = table(AnimalID',Section',Vessel',Image',PolIndex',meanPeak',meanBaseline',width',widthOK,...
    'VariableNames',{'AnimalID','Section','Vessel','Image#','PolIndex','meanPeak','meanBaseline','width',...
    'Too Wide?'});
if string(workspace{1}) == 'yes'
    dataTable=T;
else
end
writetable(T,outputFile)

%% AQP4 polarization function
% Michael Giannetto
% Nedergaard lab 
% Created 2/26/2022
% Edited 2/26/2022
%{
This function takes only the blood vessel scan as an input (the Y
fluorescence value, NOT the x axis px value). Not all output arguments need
to be used.

>>INPUT>>
vessels = a matrix of blood vessels where every column is the flourescence
value for that blood vessel

resolution = the resolution of the images analzyed. Script only supports
1024 or 2048. input should be the numbers <1024> or <2048>.

<<OUTPUTS<<
polarIndex = polariztion index for each blood vessel. Calculated by finding
peaks, taking mean of peak at 3 position around peak, then subtracting
background. Each column is a blood vessel

peakLocations = position of peaks for each blood vessel. Can be used to
verify that the function worked correctly and to estimate width of blood vessels.
Each column is a vessel

peakINT = 6 rows, where the two peaks and 2 values around each peak are saved.
Each column is a vessel. So position 2 = peak1, position 1&3 are the
neighboring pixels.

baselineINT = The first 37 rows of each trace, the baseline values used for 
 polarization calculation.  

%Parameters for find peaks can be altered as needed for data
% Currently: MinPeakWidth should exlude 3rd peaks in middle of vessel
% MinPeakDistance should also help exclude 3 peaks in middle of vessel
% MinPeak Height should exclude low intensity peaks in background
% SortStr sorts peaks found in descending order (largest first)
% NPeaks returns only the first 2 peaks (2 largest peaks)

% These peaks should be tested on multiple blood vessels!! Make sure it
% works!

% Function has been verified with results from manual calculation of ~60
% vessels by Estephanie Balbuena

       EDIT 9/14/2022
Script has been updated to support 1024x1024 and 2048x2048 images. Now
requires the resolution of the image as a second input argument. If there
is no resolution provided, the script will print an error. 
%}
function [polarIndex, peakLocations, peakINT, baselineINT, vesselWidth,tooWide]...
    = aqp4Pol(vessels,resolution)

numVessel = size(vessels,2); % Find how many vessels (columns) in matrix
lenVessel = size(vessels,1); % Find how long vessels (rows) in matrix
polarIndex = zeros(1,numVessel); %Create output variable
peakLocations = zeros(2,numVessel); % Create output variable
peakINT = zeros(6,numVessel); %Create output variable
baselineINT = zeros(37,numVessel); %Create output variable
vesselWidth = zeros(1,numVessel);
width = zeros(2,numVessel);
if ~exist('resolution','var')
    resolution=0;
end

%This section runs for 1024 x 1024 images
if resolution == 1024 
tmpPeakInd = zeros(6,1);
scale = 0.3107; %.3107 um in one pixel, for 1024x1024 image
for ii = 1:numVessel
        [~,peakLocations(:,ii),width(:,ii)] = findpeaks(vessels(:,ii),...
                  'MinPeakWidth',1,...
                  'MinPeakDistance',3,...
                  'MinPeakHeight',45,...
                  'SortStr','descend',...
                  'NPeaks',2);
              %Create temporary index around peak 1
              tmpPeakInd(2) = peakLocations(1,ii);
              tmpPeakInd(1) = tmpPeakInd(2) -1;
              tmpPeakInd(3) = tmpPeakInd(2)+1;
              %Temporary index around peak 2
              tmpPeakInd(5) = peakLocations(2,ii);
              tmpPeakInd(4) = tmpPeakInd(5)-1;
              tmpPeakInd(6) = tmpPeakInd(5)+1;
              
        peakINT(:,ii) = vessels(tmpPeakInd,ii);
        vesselWidth(1,ii) = (abs(peakLocations(1,ii) - peakLocations(2,ii))*scale);
        vesselWidthPeak(1,ii) = width(1,ii);
end
baselineINT = vessels(1:37,:);
polarIndex = mean(peakINT,1) - mean(baselineINT,1);

elseif resolution == 2048
tmpPeakInd = zeros(10,1);
scale = .1554 ; %.1554 um in one pixel, scale factor for 2048x2048 image
for ii = 1:numVessel
        [~,peakLocations(:,ii),width(:,ii)] = findpeaks(vessels(1:250,ii),...
                  'MinPeakDistance',10,...
                  'MinPeakHeight',45,...
                  'SortStr','descend',...
                  'NPeaks',2);
              for jj = 2:5
                %Create temporary index around peak 1
                tmpPeakInd(1) = peakLocations(1,ii)- 2 ;
                tmpPeakInd(jj) = tmpPeakInd(1) + (jj-1);
              end
              for kk= 7:10
                %Temporary index around peak 2
                tmpPeakInd(6) = peakLocations(2,ii) - 2;
                tmpPeakInd(kk) = tmpPeakInd(6) + (kk-1);
              end
        peakINT(:,ii) = vessels(tmpPeakInd,ii); %save peak indices
        vesselWidth(1,ii) = (abs(peakLocations(1,ii) - peakLocations(2,ii))) * scale;
        vesselWidthPeak(1,ii) = width(1,ii);
end
baselineINT = vessels(1:70,:);
polarIndex = mean(peakINT(1:5,:),1) - mean(baselineINT,1);
else
    sprintf('Please specify image resolution')
end
%Check for outliers/problems
tooWide = find(vesselWidth>5); %finds widths greater than 5um
for ii=1:length(tooWide)
fprintf('Peak distance larger than expected for Vessel in row #%d \n',tooWide(ii));
end