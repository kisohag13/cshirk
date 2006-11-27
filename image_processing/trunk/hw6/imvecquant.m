% homework #6 -- imvecquant.m
% matlab program
% Chris Shirk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imvecquant(L)
%
close all

img = imread('xyz-short-stepper-grayscale.jpg');

if (nargin ~= 1)
    L = 256;
    disp(sprintf('Defaulting to L=%d', L));
end

% Note: assuming image evenly divisible into 4x4 blocks

[h, w, d] = size(img);

if ((mod(h, 4) ~= 0) || (mod(w, 4) ~= 0))
    error 'Sorry, enforcing that the image height and width be evenly divisible by 4'
end

%%%
% Note: 4x4 = 16 pixels... assuming 24 bit depth,
% 24^16 vs. 256... quite a lot of savings
% from quantization
%%%
blkSz = 4; % Specified by homework problem


disp(sprintf('Image size: %d x %d pixels', w, h));
disp(sprintf('Given vector of 4x4 pixels, image is %d blocks x %d blocks', ...
    w / blkSz, h / blkSz));


% Generate codebook (library of reconstruction codewords)
% Given 4x4 blocks, treat each pixel independentely
codebook = zeros(L, 4, 4); % L codewords of 4x4 pixels... each pixel having a grayscale value

L_side = floor(L^.5);
for i=1:(L_side * L_side)
    x_freq = mod(i, L_side);
    y_freq = floor(i, L_side);
end

% Finish initializing
for i=(L_side * L_side + 1):L
    % Do later for slightly improved results
    % Inefficiency is (L - floor(sqrt(L))^2) / L
end


% Codebook has been generated -- now iterate through
% 4x4 regions and assign to one of the codes in the codebook


% Loop until codebook / reassignments stabilize
while (1)
    
    % Iteriate through all codes in codebook
    %   Iteriate through all 4x4 pixel vectors assigned to given code
    %   Generate a new code from amongst the selected vectors
    %   To generate a new code, just do some averaging
    
    
    % Iteriate through all 4x4 pixel vectors
    % Assign closest code in codebook
    % If assigned code has changed, set bKeepGoing = 1
    
    
    bKeepGoing = 0;
    
    if (bKeepGoing == 0) break; end
end

