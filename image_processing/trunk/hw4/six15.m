% hw #4, 6.15
%
% Chris Shirk (cshirk@ieee.org)
%
% HBMA
%
% Allow user to choose the search range (R)
%

function six15(R)

    tic;
    
    orig_R = R;

    % Poor usage guide
    if (nargin ~= 1)
        error 'six12(R) => R: search in px'
    end

    % Clear old figure
    close all;

    % Hardcoded Block size = 16x16
    blk_sz = 16;

    %%% Read two video frames in Y format
    fid= fopen('foreman69.Y','r+','n'); 
    [Target_Image]= fread(fid,'uint8');
    fclose(fid);
    anchorFrame = reshape(Target_Image,352,288)'; 

    fid = fopen('foreman72.Y','r+','n');
    [Target_Image]= fread(fid,'uint8');
    fclose(fid);
    targetFrame = reshape(Target_Image,352,288)';
    
    % Display anchor and target frame
    subplot(2,2,1);
    imshow(anchorFrame/max(max(anchorFrame)));
    title('Anchor Frame');
    subplot(2,2,2);
    imshow(targetFrame/max(max(targetFrame)));
    title('Target Frame: 0% Done');
    
    % Get dimensions of frames, ensure equivalent
    [h,w,d] = size(anchorFrame);
    [h2,w2,d2] = size(targetFrame);
    if ((h2 ~= h) || (w2 ~= w) || (d2 ~= d))
        error 'Video frames have different dimensions (h,w,d)';
    else
        disp(sprintf('frames are %d x %d x %d, or %d x %d blocks', w, h, d, ceil(w/blk_sz), ceil(h/blk_sz)));
    end
    
    % Perhaps we need to copy that image metadata again
    predictedFrame = anchorFrame;
    predictedFrame(1:h, 1:w, 1:d) = 0;
    
    %%% Assume frame dimensions > given block size
    %%% Assume frame dimensions multiple of given block size
    
    % iteriate across the blocks
    % assume 140 px wide, 20 px wide blocks, 7 blocks...
    % spanning 1:20, 21:40, 41:60, 61:80, 81:100, 101:120, 121:140
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    mv_x = []; % init. the motion vectors
    mv_y = [];
    offset_y = [];
    offset_x = [];
    
    
    %%% Given 352x288 src, and 3 levels,
    %%% Level 1: 88 x 72
    %%% Level 2: 176 x 144
    %%% Level 3: 352 x 288 -- plus I need to do a half-pel search...
    
    
    %%% Level 1
    %% To achieve 88x72, instead of sampling 1 out of every 4 pixels,
    %% let's shrink the image
    
    l1_anchor = imresize(anchorFrame, .25, 'bilinear');
    l1_target = imresize(targetFrame, .25, 'bilinear');
    R = orig_R / 4;
    
    size(l1_anchor)
    size(l1_target)
    
    [h,w,d] = size(l1_anchor);
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    for blk_y=1:num_blks_y
        
        for blk_x=1:num_blks_x
            
            % Convert target block into origin coordinates
            start_y = (blk_y - 1) * blk_sz + 1;
            end_y = start_y + blk_sz - 1;
            start_x = (blk_x - 1) * blk_sz + 1;
            end_x = start_x + blk_sz - 1;
            
            
            % Init the min error to infinity...
            % any error we actually get will be smaller
            min_error = +inf;
            
            r_y_from = max(start_y - R, 1);
            r_y_to = min(start_y + R, h - blk_sz);
            
            r_x_from = max(start_x - R, 1);
            r_x_to = min(start_x + R, w - blk_sz);
            
            for r_y = r_y_from:r_y_to 
           
                for r_x = r_x_from:r_x_to
                
                    % Ok, entire block within bounds
                    % Now compute the error
                    
                    error_sum = sum(sum( ...
                        abs( ...
                            l1_anchor(r_y:r_y+blk_sz-1, r_x:r_x+blk_sz-1, 1:d) - ...
                            l1_target(start_y:end_y, start_x:end_x, 1:d) ...
                        ) ...
                    ));
                
                
                    %sprintf('min_error = %d, sum = %d', min_error, sum)
                    if (error_sum < min_error)
                        
                        min_error = error_sum;

                        best_r_x = r_x;
                        best_r_y = r_y;
                        best_del_x = r_x - start_x;
                        best_del_y = r_y - start_y;
                        
                    end
                    
                end
            end
            
            
            
            % Target to Anchor motion vector -- grid is on target frame
            mv_y(blk_y, blk_x) = best_del_y;
            mv_x(blk_y, blk_x) = best_del_x;
            
        end
        
        
    end
    
    
    %%% Level 2: 176 x 144
    l2_anchor = imresize(anchorFrame, .25, 'bilinear');
    l2_target = imresize(targetFrame, .25, 'bilinear');
    R = orig_R / 2;
    
    
    size(l2_anchor)
    size(l2_target)
    
    [h,w,d] = size(l2_anchor);
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    for blk_y=1:num_blks_y
        
        for blk_x=1:num_blks_x
            
            
        end
        
        
        
    end
    
    
    toc;
    
    