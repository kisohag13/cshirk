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
