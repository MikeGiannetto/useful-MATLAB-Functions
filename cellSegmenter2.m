function [outputImage,positionofBlobs, sizeofBlobs] = cellSegmenter2(inputImage)
%This function takes in a binary image and outputs three variable
% outputImage is a image where each blob has a unique alphanumeric value and 
% the background has a value of 0. outputImage is what is fed into the function 
% cell segmenter
% positionofBlobs is a N X 2 variable that includes the x and y position of each 
% blob found in the output imahe 
% sizeofBlobs is a N X 1 vector that describes the size of each object in the 
% image 
outputImage = bwlabel(inputImage); 
rp = regionprops(bwlabel(inputImage)); 
sizeofBlobs=[rp(:).Area]; 
positionofBlobs = [rp(:).Centroid]; 
positionofBlobs = reshape(positionofBlobs, 2, length(positionofBlobs)/2); 



end

