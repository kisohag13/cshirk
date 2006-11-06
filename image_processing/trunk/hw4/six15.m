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
    predictedFrame = targetFrame;
    
    %%% Assume frame dimensions > given block size
    %%% Assume frame dimensions multiple of given block size
    
    % iteriate across the blocks
    % assume 140 px wide, 20 px wide blocks, 7 blocks...
    % spanning 1:20, 21:40, 41:60, 61:80, 81:100, 101:120, 121:140
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    %mv_x = []; % init. the motion vectors
    %mv_y = [];
    %offset_y = [];
    %offset_x = [];
    
    
    %%% Given 352x288 src, and 3 levels,
    %%% Level 1: 88 x 72
    %%% Level 2: 176 x 144
    %%% Level 3: 352 x 288 -- plus I need to do a half-pel search...
    
    
    %%% Level 1
    %% To achieve 88x72, instead of sampling 1 out of every 4 pixels,
    %% let's shrink the image
    
    l1_anchor = imresize(anchorFrame, .5, 'bilinear');
    l1_target = imresize(targetFrame, .5, 'bilinear');
    R = orig_R / 4;
    
    size(l1_anchor)
    size(l1_target)
    
    [h,w,d] = size(l1_anchor);
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    disp(sprintf('L1: #y = %d, #x = %d', num_blks_y, num_blks_x))
    
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
            l1_mv_y(blk_y, blk_x) = best_del_y;
            l1_mv_x(blk_y, blk_x) = best_del_x;
            
        end
        
        
    end
    
    
    %%% Level 2: 352 x 288
    %%%%%% old: 176 x 144
    l2_anchor = anchorFrame; %imresize(anchorFrame, .25, 'bilinear');
    l2_target = targetFrame; %imresize(targetFrame, ., 'bilinear');
    R = orig_R; % / 2;
    
    
    size(l2_anchor)
    size(l2_target)
    
    [h,w,d] = size(l2_anchor);
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    disp(sprintf('L2 #y = %d, #x = %d', num_blks_y, num_blks_x))
    
    for blk_y=1:num_blks_y
        
        for blk_x=1:num_blks_x
            
            
            % Look up where to search by 
            % R/2^(L-1)
            % Level 1: 32 / 2^(1-1) = 32 / 2^0 = 32 / 1 = 32
            % Level 2: 32 / 2^(2-1) = 32 / 2 = 16
            %
            % Correction vector: blk_sz;
            
            % L2     L1
            % ---------
            % 1     1
            % 2     1
            % 3     2
            % 4     2
            % ...
            % 22    11
            %
            % (L2 - 1)/2 + 1 ==> 0 / 2 + 1 = 1
            %                ==> 21 / 2 + 1 = 11.5 = 11
            
            l1_blk_y = floor((blk_y - 1) / 2) + 1;
            l1_blk_x = floor((blk_x - 1) / 2) + 1;
            
            start_y = l1_mv_y(l1_blk_y, l1_blk_x) + (blk_y - 1) * blk_sz + 1;
            end_y = start_y + blk_sz - 1;
            
            start_x = l1_mv_x(l1_blk_y, l1_blk_x) + (blk_x - 1) * blk_sz + 1;
            end_x = start_x + blk_sz - 1;
            
            
            % This reduces our calculations in the sense that
            % blk_sz should be less than R=32 specified in the problem...
            correction = blk_sz;
            
            
            % Init the min error to infinity...
            % any error we actually get will be smaller
            min_error = +inf;
            
            r_y_from = max(start_y - correction, 1);
            r_y_to = min(start_y + correction, h - blk_sz);
            
            r_x_from = max(start_x - correction, 1);
            r_x_to = min(start_x + correction, w - blk_sz);
            
            
            for r_y = r_y_from:r_y_to 
           
                for r_x = r_x_from:r_x_to
                
                    % Ok, entire block within bounds
                    % Now compute the error
                    
                    error_sum = sum(sum( ...
                        abs( ...
                            l2_anchor(r_y:r_y+blk_sz-1, r_x:r_x+blk_sz-1, 1:d) - ...
                            l2_target(start_y:end_y, start_x:end_x, 1:d) ...
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
            l2_mv_y(blk_y, blk_x) = best_del_y;
            l2_mv_x(blk_y, blk_x) = best_del_x;
            
            
            predictedFrame(start_y:end_y, start_x:end_x, 1:d) = ...
                anchorFrame(best_r_y:(best_r_y+blk_sz-1), best_r_x:(best_r_x+blk_sz-1), 1:d);
            
            
            
        end
        
    end
    
    
    %%% Level 3: half-pel search %%%%%%%%%%%%%%%%%%%%%%%%
    
    % Double the x,y dimensions of anchor frame so that we can do half-pel
    % search
    anchorFrame = imresize(anchorFrame, 2, 'bilinear');
    tmp_sz = size(anchorFrame);
    disp(sprintf('Resized Anchor to %d x %d', tmp_sz(2), tmp_sz(1)));
    
    
     % iteriate across the Target Frame blocks
    % assume 140 px wide, 20 px wide blocks, 7 blocks...
    % spanning 1:20, 21:40, 41:60, 61:80, 81:100, 101:120, 121:140
    num_blks_y = (h / blk_sz);
    num_blks_x = (w / blk_sz);
    
    R = 1; % only do half-pel correction
    
    %%% Iteriate across the Target Frame blocks...
    for blk_y=1:1:num_blks_y
        for blk_x=1:1:num_blks_x
            
            % Convert target block into origin coordinates
            start_y = (blk_y - 1) * blk_sz + 1;
            end_y = start_y + blk_sz - 1;
            start_x = (blk_x - 1) * blk_sz + 1;
            end_x = start_x + blk_sz - 1;
            
            % sprintf('start_y = %d, end_y = %d, start_x = %d, end_x = %d', start_y, end_y, start_x, end_x)
            
            % Init the min error to infinity...
            % any error we actually get will be smaller
            min_error = +inf;
            
            % Get coordinates of scaled anchor frame
            % orig: 1 ==> 1
            % orig: 2 ==> 3
            % orig: 3 ==> 5
            % orig: 4 ==> 7
            r_y_from = max(2 * start_y - R - 1, 1);
            r_y_to = min(2 * start_y + R - 1, 2 * (h - blk_sz));
            
            r_x_from = max(2 * start_x - R - 1, 1);
            r_x_to = min(2 * start_x + R - 1, 2 * (w - blk_sz));
            
            for r_y = r_y_from:r_y_to 
           
                for r_x = r_x_from:r_x_to
                
                    % Ok, entire block within bounds
                    % Now compute the error
                    
                    try
                        error_sum = sum(sum( ...
                            abs( ...
                                anchorFrame(r_y:2:r_y+2 * blk_sz-1, r_x:2:r_x+2 * blk_sz-1, 1:d) - ...
                                targetFrame(start_y:end_y, start_x:end_x, 1:d) ...
                            ) ...
                        ));
                
                    catch
                        
                        size(anchorFrame)
                    
                        disp(sprintf('anchorFrame(%d:%d, %d:%d)', r_y, r_y+2*blk_sz-1, r_x, r_x+2*blk_sz-1));
                        disp(sprintf('targetFrame(%d:%d, %d:%d)', start_y, end_y, start_x, end_x));
                       
                        error 'oy'
                    
                    end
                    
                   
                    
                    %sprintf('min_error = %d, sum = %d', min_error, sum)
                    if (error_sum < min_error)
                        
                        min_error = error_sum;

                        best_r_x = r_x;
                        best_r_y = r_y;
                        best_del_x = r_x - 2 * start_x;
                        best_del_y = r_y - 2 * start_y;
                        
                    end
                    
                end
            end
            
            %disp(sprintf('blk x,y (%d,%d) -- from anchor x,y (%d,%d) to target x,y (%d,%d)', ...
            %    blk_x, blk_y, best_r_x, best_r_y, start_x, start_y));
            
            % Save motion vectors, make them negative because our
            % perspective is changing...
            mv_y(blk_y, blk_x) = -best_del_y;
            mv_x(blk_y, blk_x) = -best_del_x;
            
            % super lazy
            offset_y(blk_y, blk_x) = best_r_y + blk_sz/2;
            offset_x(blk_y, blk_x) = best_r_x + blk_sz/2;
            
        end
    
        drawnow();
        
    end
    
    
    
    
    
    
    
    
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%% Finalize %%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    
    % Plot predicted image
    subplot(2,2,4);
    imshow(predictedFrame/max(max(predictedFrame)));
    title('Predicted Image');
    
    
    % Plot prediction-error image
    % Scaled difference image: abs(2*(predicted image - target frame)+128) 
    subplot(2,2,3);
    scaledDiff = abs(2*(predictedFrame - targetFrame) + 128);
    imshow(scaledDiff/max(max(scaledDiff)));
    title('Scaled difference image');
    hold on;
    
    
    
    % Calculate PSNR of predicted frame w.r.t. original anchor frame
    % Actually, no, do it w.r.t. the target frame
    mse = 0;
    for j=1:h
        for i=1:w
            mse = mse + (predictedFrame(j,i,1:d) - targetFrame(j,i,1:d))^2;
        end
    end
    mse = mse / w / h;
    
    psnr = 10 * log10((max(max(predictedFrame)))^2 / mse);
    
    disp(sprintf('psnr = %.4f dB', psnr));
    
    
    
    toc;
    
    