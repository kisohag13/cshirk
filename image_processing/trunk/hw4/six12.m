% hw #4, 6.12
%
% Chris Shirk (cshirk@ieee.org)
%
% Implement EBMA (Exhaustive Block Matching Algorithm) w/
% block size 16x16
%
% Allow user to choose the search range (R)
%

function six12(R, halfPel)

    if (nargin ~= 2)
        error 'six12(R, halfPel) => R: search in px, halfPel: boolean, whether to expand to half-pel search EBMA'
    end

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
    
    % Determine whether we're using half-pel accuracy
    %if (halfPel == 1)
    %    anchorFrame = interp2(anchorFrame, 1.5, 'linear');
    %    targetFrame = interp2(targetFrame, 1.5, 'linear');
        %figure
        %imshow(anchorFrame/max(max(anchorFrame)));
        %title('Anchor Frame');
        
    %end

    subplot(2,2,1);
    imshow(anchorFrame/max(max(anchorFrame)));
    title('Anchor Frame');
    subplot(2,2,2);
    imshow(targetFrame/max(max(targetFrame)));
    title('Target Frame: 0% Done');
    
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
    
    %%% Assume frame dimensions > given block size
    %%% Assume frame dimensions multiple of given block size
    
    % iteriate across the blocks
    num_blks_y = (h / blk_sz) - 1;
    num_blks_x = (w / blk_sz) - 1;
    
    mv = []; % motion vectors
   
    for blk_y=1:num_blks_y
        
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
            
            r_y_from = max(start_y - R, 1);
            r_y_to = min(end_y + R, h - blk_sz);
            r_x_from = max(start_x - R, 1);
            r_x_to = min(end_x + R, w - blk_sz);
            
            for r_y=r_y_from:r_y_to 
           
                for r_x=r_x_from:r_x_to
                
                    % Ok, entire block within bounds
                    % Now compute the error
                    
                    error_sum = sum(sum( ...
                        abs( ...
                            anchorFrame(r_y:r_y+blk_sz, r_x:r_x+blk_sz, 1:d) - ...
                            targetFrame(start_y:end_y, start_x:end_x, 1:d) ...
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
            
            sprintf('blk x,y (%d,%d) -- from anchor x,y (%d,%d) to target x,y (%d,%d)', ...
                blk_x, blk_y, best_r_x, best_r_y, start_x, start_y)
            
            predictedFrame(start_y:end_y, start_x:end_x, 1:d) = ...
                anchorFrame(best_r_y:(best_r_y+blk_sz), best_r_x:(best_r_x+blk_sz), 1:d);
            
            
            %predictedFrame(start_y:end_y, start_x:end_x, 1:d) = ...
            %    anchorFrame( ...
            %        best_r_y:(best_r_y + blk_sz), best_r_x:(best_r_x + blk_sz), 1:d ...
            %    );
            
            
            % Save motion vectors
            %mv(blk_y, blk_x) = struct('del_x', r_x - start_x, 'del_y', r_y - start_y);
            
            %sprintf('blk x,y=(%d,%d)    MV: x,y=(%d,%d)    sum=%d', blk_x, blk_y, blk_mv_x(blk_x), blk_mv_y(blk_y), min_error)
            
            %y_off = blk_mv_y(blk_y, blk_x);
            %x_off = blk_mv_x(blk_y, blk_x);
            
            %sprintf('gonna remap: predict(%d:%d,%d:%d) from anchor(%d:%d,%d:%d)', ...
             %   start_y, end_y, start_x, end_x, start_y + y_off, end_y + y_off, start_x + x_off, end_x + x_off)
            
            % We know the best match, so generate a block of the predicted frame
            
            
            
               %     (start_y + y_off):(end_y + y_off), (start_x + x_off):(end_x + x_off), 1:d ...
                %);
           
            
            
            %for j=start_y:end_y
             %   for i=start_x:end_x
              %      predictedFrame(j + blk_mv_y(blk_y, blk_x), i + blk_mv_x(blk_y, blk_x), 1:d) = anchorFrame(j, i, 1:d);
               %     %predictedFrame(j,i,1:d) = anchorFrame(j + blk_mv_y(blk_y, blk_x),i + blk_mv_x(blk_y, blk_x),1:d);
                %end
            %end
            
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
    %subplot(2,2,1);
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
    
    psnr_str = sprintf('psnr = %.2f dB', psnr);
    psnr_str
   
    