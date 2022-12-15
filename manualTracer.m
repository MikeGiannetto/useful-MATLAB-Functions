function [outputImage] = manualTracer(inputImage)
%This function takes in an image and outputs a binary image where the drawn
%region = 1 and the rest is zero and the size of the input image
figure; imagesc(inputImage); 
h = drawfreehand('Closed', 0, 'FaceSelectable', 0, 'FaceAlpha', 0, 'Color', 'r');
hx = h.Position; delete(h);

outputImage = poly2mask(hx(:,1),hx(:,2), size(inputImage,1), size(inputImage,2)); 

