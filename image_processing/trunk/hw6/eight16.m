% eight16.m -- Problem 8.16
% Chris Shirk
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function eight16

close all

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Generate 2-D i.i.d. Gaussian source
% Two components in each sample are independent 
% w/ zero mean and unit variance
% I can specify the Number of samples
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nSrcSamples = 256;
global src;
src = randn(nSrcSamples, 2); % 2 dimensional i.i.d. source


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Set the codebook size
% codebook contains x,y of quant. region centroid
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nQuantLevels = 16;
global codebook;
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


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Loop through the source samples and assign them
% to the closest quant. region
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
for i=1:length(src)
    srcLevel(i) = findClosestCentroid(i);
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Keep adjusting centroids and reassociating samples with
% quantization regions... when we achieve stability, exit
% loop, for we have converged on a local optimum
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
nIterations = 0;
while(1)
    
    nIterations = nIterations + 1;
    
    % Recalculate centroids
    % Get a particular quant. region
    for i=1:length(codebook)
        
        nReferences = 0;
        x = 0;
        y = 0;
        
        % Find all source samples that reference that region
        for j=1:length(src)
            
            if (srcLevel(j) == i)
                nReferences = nReferences + 1;
                x = x + src(j, 1);
                y = y + src(j, 2);
            else
                %disp(sprintf('srcLevel(%d) = %d', j, srcLevel(j)));
            end
            
        end
       
        % Nothing actually fits in this particular quantization
        % region... so fix the region to a known point
        if (nReferences == 0)
            %disp(sprintf('i=%d', i));
            %pause
            
            % No source samples corresponded to given
            % quantization region, so reset the region back
            % to 0,0
            codebook(i, 1) = 0;
            codebook(i, 2) = 0;
            
            
            
        else
            
            % Got all source samples for given region,
            % now recalculate centroid
            codebook(i, 1) = x / nReferences;
            codebook(i, 2) = y / nReferences;
           
        end
        
        
        
    end
    
    
    
    % Centroids have been recalculated
    % Now check whether the source samples
    % still correspond to the same quant. regions!
    bKeepGoing = 0;
    
    for i=1:length(src)
        
        tmp = findClosestCentroid(i);
        if (tmp == srcLevel(i))
        else
            bKeepGoing = 1;
            
            srcLevel(i) = tmp;
            
        end
        
        
    end
    
    
    if (bKeepGoing == 0) break; end
    
    % We've got to iteriate again, so show a plot
    figure
    newtitle = sprintf('%d Samples, %d Quant. Levels, Iteration %d', length(src), length(codebook), nIterations);
    
    
    plot(src(1:length(src), 1), src(1:length(src), 2), 'bx');
    hold on;
    plot(codebook(1:length(codebook), 1), codebook(1:length(codebook), 2), 'go');
    title(newtitle);
    
    
end

disp(sprintf('nIterations = %d', nIterations));

disp 'Final codebook:'
codebook




%%%%%%%%%%%%%%%%%%%%%
function [quant_idx] = findClosestCentroid(i)
    global src;
    global codebook;

    distance = +inf;
    quant_idx = 0;
    
    % Find closest centroid
    for j=1:length(codebook)
        
        tmp = ((src(i, 1) - codebook(j, 1))^2 + (src(i, 2) - codebook(j, 2))^2) ^.5;
        
        if (tmp < distance)
            distance = tmp;
            quant_idx = j;
        end
        
    end
    











% The point is this
% The number of samples is in the context of the training set
% The training set is what we establish -- it configures the quantizer
% to process an unlimited amount of inputs in the future

% The Lloyd algorithm runs through the training set (what we specify)
% and configures the encoder...


% Note: I can also choose the codebook size
%




% 