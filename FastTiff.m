function data = FastTiff(filename)
%From matlab forum
%https://www.mathworks.com/matlabcentral/answers/105739-how-to-show-tiff-stacks 

tstack  = Tiff(filename);
[I,J] = size(tstack.read());
K = length(imfinfo(filename));
data = zeros(I,J,K);
data(:,:,1)  = tstack.read();
for n = 2:K
    tstack.nextDirectory()
    data(:,:,n) = tstack.read();
end

end