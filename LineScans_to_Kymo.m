function [thorExpData]= LineScans_to_Kymo()
%% Capillary Linescan Kymograph Maker 
% Michael Giannetto
% Nedergaard Lab
% 08/29/2022
%{
Takes a set of linescans, and makes them a single .tif image "kymograph"

Input should be a folder from ThorLabs 2 photon microscope, with linescans
saved as raw .tif, and all the default files/folder structure left alone!!

Output will be a single .tif image stack 512x512x(variable stack size)
Output will be a .mat file containing thorLabExperiment info, um/px,fps

%Function should be in same folder working in
%}

%% Code starts here
clear
folderName = uigetdir;
fileInfo = dir(folderName); %prompts user to select folder with linescans
numScan = size(fileInfo,1) - 7; %Finds number of scans taken

%Create filename for saving
startingFolder = pwd;
defaultFileName = fullfile(startingFolder, '*.*');
[baseFileName, folder] = uiputfile(defaultFileName, 'Specify a file');
if baseFileName == 0
  % User clicked the Cancel button.
  return;
end
baseFileNameTIF = [baseFileName '.tif'];
fullFileName = fullfile(folder, baseFileNameTIF);

%Put individual scans into a single large image
% REQUIRES "FastTiff" function to work 
% https://www.mathworks.com/matlabcentral/answers/105739-how-to-show-tiff-stacks 
scanTogether =[]; 
for ii = 3:(numScan + 2)
    temp1 = FastTiff([fileInfo(ii).folder '\' fileInfo(ii).name]);
    scanTogether = [scanTogether ; temp1];
end

%Create 3dim variable of data
numFrames = floor(size(scanTogether,1) / 512);
capillary = zeros(512,512,numFrames);
capillary(:,:,1) = scanTogether(1:512,:);
for ii = 2:numFrames
    capillary(:,:,ii) = scanTogether(((ii-1)*512+1):(ii*512),:);
end
capillary = uint16(capillary);

%Write stack to tif file (will save in current directory)
for ii=1:numFrames
imwrite(capillary(:,:,ii),fullFileName,'writemode','append');
end

%Get ThorLab experiment data and save
thorExpData = read_Thor_xml([fileInfo(1).folder '\' 'Experiment.xml']);
fps = thorExpData.FrameRate * size(temp1,1) ;
um_px = thorExpData.umperpix ;
save ([baseFileName '.mat'],'thorExpData','um_px','fps');

end
