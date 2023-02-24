%% Code originally given by Antonio Ladron
%{
Used and edited by Mike Giannetto Feb 14 2023
This code will work for 2D images just fine
%}

%% RUN THIS PART OF THE CODE IN PREPARATION BEFORE UPLOADE TO BLUEHIVE
clear all
close all
%Get information about the video
outputFilename = input("Set Output Filename>>",'s');

[~,~,info]=read_raw('Image_0001_0001.raw',[1],[],0);
bitdepth=info.ImageBitDepthReal;
nframes=info.AllocatedFrames; % Frames specified 
nframes2=info.RecordedFrames; % Actual frames read
framerate=info.FrameRate;
umperpix=info.umperpix; % Scale factor
fps=framerate;
save([outputFilename '.mat'],'fps','umperpix','nframes','nframes2');

% Load image into MATLAB workspace
img = read_raw('Image_0001_0001.raw',[1:nframes2],[],0);

save([outputFilename  '.mat'],'img','-append'); %save to same .mat variable

bg0=uint16(mean((vessel_ch),3));
imwrite(bg0,'bg1r.tif','compression','none');
bg1=imread('bg1r.tif');
imagesc(bg0);
save('PTVr.mat','bg1','vessel_channel','-append');


%% Saving output as .tif 

for ii = 1:length(img)
    imwrite((img{ii}), [sprintf('Ch0%d',ii) '_' 'outputFilename' '.tif'],...
        'compression','none');
end
