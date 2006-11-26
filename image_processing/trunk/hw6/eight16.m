%
% eight16.m -- Problem 8.16
% Chris Shirk
%


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 2-D i.i.d. Gaussian source
% Two components in each sample are independent 
% w/ zero mean and unit variance
% I can specify the Number of samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nSrcSamples = 256;
src = randn(nSrcSamples, 2); % 2 dimensional i.i.d. source


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the codebook size
% codebook contains x,y of quant. region centroid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nQuantLevels = 16;
codebook = zeros(nQuantLevels, 2);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Which quant. region  the source sample
% corresponds to; the region's centroid x,y can be
% looked up in the codebook
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
srcLevel = zeros(nSrcSamples, 1);



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the initial centroid values in the codebook..
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
xMin = min(src(1:length(src)));
xMax = max(src(1:length(src)));
yMin = min(src(1:length(src), 2));
yMax = max(src(1:length(src), 2));

qx = (xMax - xMin) / length(codebook);
qy = (yMax - yMin) / length(codebook);

for i=1:length(codebook)
    codebook(i, 1) = xMin + qx / 2 + (i - 1) * qx;
    codebook(i, 2) = yMin + qy / 2 + (i - 1) * qy;
end

disp 'Original codebook:'
codebook



% The point is this
% The number of samples is in the context of the training set
% The training set is what we establish -- it configures the quantizer
% to process an unlimited amount of inputs in the future

% The Lloyd algorithm runs through the training set (what we specify)
% and configures the encoder...


% Note: I can also choose the codebook size
%




% 