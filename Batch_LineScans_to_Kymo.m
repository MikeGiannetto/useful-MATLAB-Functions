function []= Batch_LineScans_to_Kymo(kymoLength,numChannels, linescan)
%% Capillary Linescan Kymograph Maker 
% Michael Giannetto
% Nedergaard Lab
% 08/29/2022
%{
Takes a set of linescans, and makes them a single .tif image "kymograph"

                    >>>>>> INPUTS >>>>>>>
Optional input! kymoLength = length of kymograph in y direction, default is 512. If you
enter "max" it will generate one huge kymograph instead of an image stack.

Optional input! numChannels = number of color channels acquired. Default is
one color channel. If processing multiple channels and process with defualt
settings then the output will be a single .tif with the channels back to
back. 

Optional input! linescan = Enter 'line' when converting linescan data, will
be necessary to get correct sampling rate "fps"

User dialog prompt input should be all the scans under one "parent" folder 
containing folders from ThorLabs 2 photon microscope, with linescans saved 
as raw .tif, and all the default files/folder structure left alone!!

                    <<<<<<<<<OUTPUTS<<<<<<<<<
Each linescan folder will create 2 outputs which will be saved to the
current folder
Output names will be the same as the name of each experiment folder.

Output will be a .tif image stack 512x512x(variable stack size), or a .tif
stack for each color channel input

Output will be a .mat file containing thorLabExperiment info, um/px,fps


------------------------------------------------------------------------
Should be used when you have several capillary linescans you want to make
into kymographs all at once

%Edited 9/8/2022 to make compatible with multichannel images, and images
that are not linescans.Can now be used for general tif saving from ThorLabs 
2P. Will need to specify number of channels used for acquisition if more 
than 1 channel is present.
%}

%% Code starts here
% Optional - change the length of kymograph in y direction (default is
% 512px)or length of linescan in X dirextion

if ~exist('kymoLength','var')
    kymoLength = 512;
end
if ~exist('linescan','var')
    linescan='no';
end
if ~exist('numChannels','var')
    numChannels = 1;
end
%%
folderName = uigetdir;
parentFolder = dir(folderName); %gets name of parent folder
for kk = 3:size(parentFolder,1)
    
fileInfo = dir([parentFolder(kk).folder '\' parentFolder(kk).name]); 
numScan = size(fileInfo,1) - 6; %Finds number of scans taken

%Create filename for saving
startingFolder = pwd;
defaultFileName = fullfile(startingFolder);
baseFileName = [defaultFileName '\' parentFolder(kk).name] ;

baseFileNameTIF = [baseFileName '.tif'];
fullFileName =  baseFileNameTIF;

%Get ThorLab experiment data and save
thorExpData = read_Thor_xml([fileInfo(1).folder '\' 'Experiment.xml']);

um_px = thorExpData.umperpix ;
scanLength = thorExpData.ImageWidth;
if strcmp('linescan','line') == 1
    fps = thorExpData.FrameRate * thorExpData.ImageHeight; %calclulates sample rate for linescan
else
    fps = thorExpData.FrameRate; %sample rate for normal acquisition
end
save ([baseFileName '.mat'],'thorExpData','um_px','fps','scanLength');

%Check if width/height of new kymograph is less than original image input,
%if it is, set the width/length of the kymograph to the image dimensions.
%This helps the function work with normal images and not just linescans,
%and makes sure that the linescan length is correct
if kymoLength < thorExpData.ImageHeight 
    kymoLength = thorExpData.ImageHeight;
end
if strcmp(linescan,'no')
    kymoLength = thorExpData.ImageHeight;
end

%Put individual scans into a single large image
% REQUIRES "FastTiff" function to work 
% https://www.mathworks.com/matlabcentral/answers/105739-how-to-show-tiff-stacks 
scanTogether =[]; 
for ii = 3:(numScan + 2)
    temp1 = FastTiff([fileInfo(ii).folder '\' fileInfo(ii).name]);
    scanTogether = [scanTogether ; temp1];
end

%first part runs if input is 'max', generates single large frame
if kymoLength == 'max' 
    capillary = uint16(scanTogether);
    imwrite(capillary,fullFileName)
else
%runs with any other kymoLength
%Create 3dim variable of data
numFrames = floor(size(scanTogether,1) / kymoLength);
capillary = zeros(kymoLength,scanLength,numFrames);
capillary(:,:,1) = scanTogether(1:kymoLength,:);
for ii = 2:numFrames
    capillary(:,:,ii) = scanTogether(((ii-1)*kymoLength+1):(ii*kymoLength),:);
end

%Write stack to tif file (will save in current directory)
capillary = uint16(capillary);
if numChannels == 1
    for ii=1:numFrames
    imwrite(capillary(:,:,ii),fullFileName,'writemode','append');
    end
elseif numChannels > 1 %runs if more than one channel is present
    channelSize = numFrames / numChannels;
    capChannelIndex = [1:channelSize;(1+channelSize):(channelSize*2);...
        (1 + channelSize*2):(channelSize*3);(1 + channelSize*3):(channelSize *4)];
    channelNames = {'Ch1' 'Ch2' 'Ch3' 'Ch4'};
    for ii = 1:numChannels
        ind = capChannelIndex(ii,:);
        chFileName = [baseFileName channelNames{ii} '.tif'];
        for jj = 1:channelSize
        imwrite(capillary(:,:,ind(jj)),chFileName,'writemode','append');
        end
    end
end

        
end


end
end
