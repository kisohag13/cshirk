% homework #6 -- imvecquant.m
% matlab program
% Chris Shirk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function imvecquant(L)
%
close all

global img;
img = imread('xyz-short-stepper-grayscale.gif');

%imshow(img);
%pause

if (nargin ~= 1)
    L = 256;
    disp(sprintf('Defaulting to L=%d', L));
end

% Note: assuming image evenly divisible into 4x4 blocks
global h;
global w;
global d;
[h, w, d] = size(img);

if ((mod(h, 4) ~= 0) || (mod(w, 4) ~= 0))
    error 'Sorry, enforcing that the image height and width be evenly divisible by 4'
end

%%%
% Note: 4x4 = 16 pixels... assuming 24 bit depth,
% 24^16 vs. 256... quite a lot of savings
% from quantization
%%%
global blkSz;
blkSz = 4; % Specified by homework problem


disp(sprintf('Image size: %d x %d pixels', w, h));
disp(sprintf('Given vector of 4x4 pixels, image is %d blocks x %d blocks', ...
    w / blkSz, h / blkSz));


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate codebook (library of reconstruction codewords)
% Given 4x4 blocks, treat each pixel independentely
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global codebook;
codebook = zeros(L, 4, 4); % L codewords of 4x4 grayscale pixels

L_side = floor(L^.5);
for i=1:(L_side * L_side) % Define codewords
    x_freq = mod(i - 1, L_side) / L_side;
    y_freq = floor(i / L_side) / L_side;
    
    disp(sprintf('for i=%d, x_freq = %d, y_freq = %d', i, x_freq, y_freq));
    
    for a=1:blkSz % x dimension
        for b=1:blkSz % y dimension
            
            pixel_freq = (a / blkSz * x_freq + b / blkSz * y_freq) / 2; % avg it out
            codebook(i, a, b) = floor(pixel_freq * 256);
            
            disp(sprintf('codebook(%d,%d,%d) = %d', i, a, b, codebook(i, a, b)));
            
        end
    end
end

pause
codebook

% Finish initializing
for i=(L_side * L_side + 1):L
    % Do later for slightly improved results
    % Inefficiency is (L - floor(sqrt(L))^2) / L
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Which quant. region  the vector region corresponds to
%
% Note: w * h / 4 / 4
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
global numVecs;
numVecs = w * h / blkSz / blkSz;
vecLevel = zeros(numVecs, 1);


% Codebook has been generated -- now iterate through
% 4x4 regions and assign to one of the codes in the codebook
for i=1:numVecs
    vecLevel(i) = findClosestCode(i);
end


% Loop until codebook / reassignments stabilize
nIterations = 0;
while (1)
    nIterations = nIterations + 1;
    
    % Iteriate through all codes in codebook
    %   Iteriate through all 4x4 pixel vectors assigned to given code
    %   Generate a new code from amongst the selected vectors
    %   To generate a new code, just do some averaging
    for i=1:length(codebook)
        
        nReferences = 0;
        
        % Find all 4x4 vectors that reference that code
        for j=1:numVecs
            
            
            
        end
       
        
        
    end
    
    
    % Iteriate through all 4x4 pixel vectors
    % Assign closest code in codebook
    % If assigned code has changed, set bKeepGoing = 1
    
    
    bKeepGoing = 0;
    
    if (bKeepGoing == 0) break; end
end


disp(sprintf('nIterations = %d', nIterations));


%%%%%%%%%%%%%%%%%%%%%
function [quant_idx] = findClosestCode(i)

    global codebook;
    global img;
    global numVecs;
    global blkSz;
    global h;
    global w;
    global d;
    
    % for i=100 --> 99 * 4 mod 400 = 
    x_offset = mod((i - 1) * blkSz, w) + 1;
    y_offset = floor((i - 1) * blkSz / w) * blkSz + 1;
    
    disp(sprintf('for i=%d, x_offset = %d, y_offset = %d', i, x_offset, y_offset));
    
    mse = +inf;
    quant_idx = 0;
    
    % Find best-fit code
    for j=1:length(codebook)
        
        tmp = 0;
        for a=0:(blkSz - 1)
            for b=0:(blkSz - 1)
                
                disp(sprintf(' img(%d,%d)=%d  codebook(%d,%d,%d)=%d', ...
                   y_offset + a, x_offset + b, img(y_offset + a, x_offset + b, 1), ...
                  j, a + 1, b + 1, codebook(j, a+1, b+1)));
                
                
                
                foo = (img(y_offset + a, x_offset + b, 1) - codebook(j, a + 1, b + 1))^2;
                
                tmp = tmp + foo;
            end
        end
        
        %pause
        
        if (tmp < mse)
            mse = tmp;
            quant_idx = j;
        end
        
    end % iteriate across codebook
    
    disp(sprintf('for i=%d, quant idx = %d, mse = %d', i, quant_idx, mse));
