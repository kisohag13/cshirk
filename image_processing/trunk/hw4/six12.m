% hw #4, 6.12
%
% Chris Shirk (cshirk@ieee.org)
%
% Implement EBMA (Exhaustive Block Matching Algorithm) w/
% block size 16x16
%
% Allow user to choose the search range (R)
%

function six12(R)

    close all;

    % Block size = 16x16
    blk_sz = 16; % 16 x 16

    %%% Read two video frames in Y format
    fid= fopen('foreman69.Y','r+','n'); 
    [Target_Image]= fread(fid,'uint8');
    fclose(fid);
    anchorFrame = reshape(Target_Image,352,288)'; 

    fid = fopen('foreman72.Y','r+','n');
    [Target_Image]= fread(fid,'uint8');
    fclose(fid);
    targetFrame = reshape(Target_Image,352,288)'; 

    
    subplot(2,1,1);
    imshow(anchorFrame/max(max(anchorFrame)));
    title('Anchor Frame');
    subplot(2,1,2);
    imshow(targetFrame/max(max(targetFrame)));
    title('Target Frame');
    
    % Get dimensions of frames, ensure equivalent
    [h,w,d] = size(anchorFrame);
    sprintf('anchor = %d x %d', w, h);
    [h2,w2,d2] = size(targetFrame);
    if ((h2 ~= h) || (w2 ~= w) || (d2 ~= d))
        error 'Video frames have different dimensions (h,w,d)';
    end
    
    % Assume frame dimensions > given block size
    % Assume frame dimensions multiple of given block size
    
    
    
    
    % do EBMA across the blocks
    best_fit = [+inf -1 -1]; % init: error, r_y, r_x
    
    for r_y=0:(R-1)
        for r_x=0:(R-1)
            
            sum = 0;
            for j=1:blk_sz
                for i=1:blk_sz
                    sum = sum + abs(targetFrame(j + r_y, i + r_x, 1:d) - anchorFrame(j,i,1:d));
                end
            end
            
            if (sum < best_fit(1))
                best_fit(1) = sum;
                best_fit(2) = r_y;
                best_fit(3) = r_x;
            end
            
        end
    end
    
    sprintf('error = %d, r_y = %d, r_x = %d', best_fit(1), best_fit(2), best_fit(3))
    
   
    