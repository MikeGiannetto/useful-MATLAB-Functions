function [calciumTraces backgroundTrace] = extractCalcium(maskImage,calciumStack)
% This function will take a cell mask and then extract calcium traces 
% the inpiuts are maskImage and calciumStack
% 
% calciumStack is a calcium Movie in which you want to extract calcium traces 
% from identified blobs. 
% 
% maskImage can either be a binary image or a set of labeled blobs from 
% cellSegmenter2. if maskImage is a binary, you 
% 
% The output calciumTraces is the average pixel value for each blob in the image over time 
% if the input maskImage is binary, then calciumTraces will be a vector 
%     backgroundTraces is the values of the movie over time for all pixels 
%     that are not blobs


m = maskImage; 
c = double(calciumStack); 

u = unique(m(:)); 

for ii = 1:length(u); 
    ti = zeros(size(m)); 
    
    tx = find(m == u(ii)); 
    ti(tx) = 1; ti = double(ti); 
    mx=repmat(ti, 1, 1, size(c,3)); 
    
    mx = mx.*c; 
    calciumTraces(ii,:) = sum(sum(mx,1),2)./length(tx); 
    
    
    
    
end

backgroundTrace = calciumTraces(1,:); 
calciumTraces = calciumTraces(2:end,:); 

end

