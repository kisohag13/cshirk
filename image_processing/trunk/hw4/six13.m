% hw #4, 6.13
%
% Chris Shirk (cshirk@ieee.org)
%
% Just like six12., but do half-pel accuracy
% Yes, I should make it into one program, but I am pressed 4 time
%
% Allow user to choose the search range (R)
%

function six12(R)

    % Poor usage guide
    if (nargin ~= 1)
        error 'six12(R) => R: search in px'
    end

    % Clear old figure
    close all;

    % Hardcoded Block size = 16x16
    blk_sz = 16; %16; % 16 x 16

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
   
    for blk_y=1:num_blks_y
        
        for blk_x=1:num_blks_x
            
            % Convert target block into origin coordinates
            start_y = (blk_y - 1) * 16 + 1;
            end_y = start_y + blk_sz - 1;
            start_x = (blk_x - 1) * 16 + 1;
            end_x = start_x + blk_sz - 1;
            
            % sprintf('start_y = %d, end_y = %d, start_x = %d, end_x = %d', start_y, end_y, start_x, end_x)
            
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
                    
                    try
                        error_sum = sum(sum( ...
                            abs( ...
                                anchorFrame(r_y:r_y+blk_sz-1, r_x:r_x+blk_sz-1, 1:d) - ...
                                targetFrame(start_y:end_y, start_x:end_x, 1:d) ...
                            ) ...
                        ));
                
                    catch
                        
                        size(anchorFrame)
                    
                        disp(sprintf('anchorFrame(%d:%d, %d:%d)', r_y, r_y+blk_sz-1, r_x, r_x+blk_sz-1));
                        disp(sprintf('targetFrame(%d:%d, %d:%d)', start_y, end_y, start_x, end_x));
                       
                        error 'oy'
                    
                    end
                    
                   
                    
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
            
            disp(sprintf('blk x,y (%d,%d) -- from anchor x,y (%d,%d) to target x,y (%d,%d)', ...
                blk_x, blk_y, best_r_x, best_r_y, start_x, start_y));
            
            predictedFrame(start_y:end_y, start_x:end_x, 1:d) = ...
                anchorFrame(best_r_y:(best_r_y+blk_sz-1), best_r_x:(best_r_x+blk_sz-1), 1:d);
            
            
            % Save motion vectors, make them negative because our
            % perspective is changing...
            mv_y(blk_y, blk_x) = -best_del_y;
            mv_x(blk_y, blk_x) = -best_del_x;
            
            % super lazy
            offset_y(blk_y, blk_x) = best_r_y + blk_sz/2;
            offset_x(blk_y, blk_x) = best_r_x + blk_sz/2;
            
        end
        
        subplot(2,2,2);
        percent_done = sprintf('Target Frame; %d %% Done', floor(blk_y * 100 / num_blks_y));
        title(percent_done);
        drawnow();
        
    end
    
    
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
    
    % Plot estimated motion field
    subplot(2,2,1);
    hold on;
    tmp_sz = size(mv_y);
    quiver(offset_x, offset_y, mv_x, mv_y(tmp_sz(1):-1:1, 1:tmp_sz(2)));
    title('Est. Anchor Motion field');
    %axis image;
    
    %blk_mv_y_sz = size(blk_mv_y);
    % for image, (0,0) is top-left.. but for graphs (quiver), (0,0) is
    % bottom left
    %quiver(blk_mv_x, blk_mv_y(blk_mv_y_sz(1):-1:1, 1:blk_mv_y_sz(2)));
    %title('Est. motion field, Anchor');
    %axis image;
    %axis([0 num_blks_x 0 num_blks_y]);
    
    
    
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
    
    disp(sprintf('psnr = %.2f dB', psnr));
    
    