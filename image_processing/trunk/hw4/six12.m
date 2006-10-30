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

    subplot(2,2,1);
    imshow(anchorFrame/max(max(anchorFrame)));
    title('Anchor Frame');
    subplot(2,2,2);
    imshow(targetFrame/max(max(targetFrame)));
    title('Target Frame');
    
    % Perhaps we need to copy that image metadata again
    predictedFrame = anchorFrame;
    
    % Get dimensions of frames, ensure equivalent
    [h,w,d] = size(anchorFrame);
    sprintf('anchor = %d x %d', w, h);
    [h2,w2,d2] = size(targetFrame);
    if ((h2 ~= h) || (w2 ~= w) || (d2 ~= d))
        error 'Video frames have different dimensions (h,w,d)';
    else
        sprintf('frames are %d x %d x %d', w, h, d)
        %pause
    end
    
    % Assume frame dimensions > given block size
    % Assume frame dimensions multiple of given block size
    
    
    
    
    % do EBMA across the blocks
    best_fit = [+inf -1 -1]; % init: error, r_y, r_x
    
    % iteriate across the blocks
    num_blks_y = (h / blk_sz) - 1;
    num_blks_x = (w / blk_sz) - 1;
    
    blk_mv_y = []; % Y motion vectors for blocks
    blk_mv_x = []; % X ..
   
    for blk_y=1:num_blks_y
        
        subplot(2,2,2);
        percent_done = sprintf('Target Frame; %d %% Done', floor(blk_y * 100 / num_blks_y));
        title(percent_done);
        drawnow();
        
        for blk_x=1:num_blks_x
            
            % now for given block, search for best match
            start_y = (blk_y - 1) * 16 + 1;
            end_y = start_y + blk_sz;
            start_x = (blk_x - 1) * 16 + 1;
            end_x = start_x + blk_sz;
            
            % sprintf('start_y = %d, end_y = %d, start_x = %d, end_x = %d', start_y, end_y, start_x, end_x)
            
            % Init the min error for the MV to infinity...
            % any error we actually get will be smaller
            min_error = +inf;
            for r_y=-R:R
                
                % Exceeds Height?
                if ((start_y + r_y < 1) || (end_y + r_y > h))
                    continue
                end
                
                for r_x=-R:R
                    
                    % Exceeds width?
                    if ((start_x + r_x < 1) || (end_x + r_x > w))
                        continue
                    end
                    
                    
                    % Ok, entire block within bounds
                    % Now compute the error
                    sum = 0;
                    for j=start_y:end_y
                        for i=start_x:end_x
                            
                            %sprintf('y=%d x=%d', j + r_y, i + r_x) % Debug
                            
                            sum = sum + abs(targetFrame(j + r_y, i + r_x, 1:d) - anchorFrame(j, i, 1:d));
                        end
                    end
                    
                    
                    %sprintf('min_error = %d, sum = %d', min_error, sum)
                    if (sum < min_error)
                        
                        if (min_error == +inf)
                            %sprintf('now: sum=%d x,y=(%d,%d)', sum, r_x, r_y)
                        else
                        
                            %sprintf('was: sum=%d x,y=(%d,%d)   now: sum=%d x,y=(%d,%d)', sum, blk_mv_x(blk_x), blk_mv_y(blk_y), min_error, r_x, r_y)
                        end
                        %pause
                        
                        min_error = sum;
                        % Save motion vectors for this block so I can
                        % reference them later
                        blk_mv_y(blk_y, blk_x) = r_y;
                        blk_mv_x(blk_y, blk_x) = r_x;
                    end
                    
                end
            end
            
            %sprintf('blk x,y=(%d,%d)    MV: x,y=(%d,%d)    sum=%d', blk_x, blk_y, blk_mv_x(blk_x), blk_mv_y(blk_y), min_error)
            
            % We know the best match, so generate the predicted frame
            for j=start_y:end_y
                for i=start_x:end_x
                    predictedFrame(j + blk_mv_y(blk_y, blk_x), i + blk_mv_x(blk_y, blk_x), 1:d) = anchorFrame(j, i, 1:d);
                end
            end
            
        end
    end
    
    % Plot estimated motion field
    subplot(2,2,3);
    quiver(blk_mv_x, blk_mv_y);
    title('Estimated motion field');
    
    % Plot predicted image
    subplot(2,2,4);
    imshow(predictedFrame/max(max(predictedFrame)));
    title('Predicted Image');
    
    
    % Plot prediction-error image
    % Scaled difference image: abs(2*(predicted image - target frame)+128) 
    subplot(2,2,1);
    scaledDiff = abs(2*(predictedFrame - targetFrame) + 128);
    imshow(scaledDiff/max(max(scaledDiff)));
    title('Scaled difference image');
    
    % Calculate PSNR of predicted frame w.r.t. original anchor frame
    mse = 0;
    for j=1:h
        for i=1:w
            mse = mse + (predictedFrame(j,i,1:d) - anchorFrame(j,i,1:d))^2;
        end
    end
    
    psnr = 10 * log10((max(max(predictedFrame)))^2 / mse);
    
    psnr
    sprintf('psnr = %f dB', psnr)
   
    