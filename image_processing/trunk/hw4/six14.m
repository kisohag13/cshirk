% hw #4, 6.14
%
% Chris Shirk (cshirk@ieee.org)
%
% Similar to 6.12, but do spatial interpolation on the motion field
%
%
%
% Allow user to choose the search range (R)
%

function six14(R)

    tic;

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
    predictedFrame = targetFrame;
    
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
            
            %disp(sprintf('blk x,y (%d,%d) -- from anchor x,y (%d,%d) to target x,y (%d,%d)', ...
            %    blk_x, blk_y, best_r_x, best_r_y, start_x, start_y));
            
            %%% Don't do calculation of predicted frame here..
            %%% We have to interpolate the motion field from block space to pixel space
            %predictedFrame(start_y:end_y, start_x:end_x, 1:d) = ...
            %    anchorFrame(best_r_y:(best_r_y+blk_sz-1), best_r_x:(best_r_x+blk_sz-1), 1:d);
            
            
            % Save motion vectors
            mv_y(blk_y, blk_x) = best_del_y;
            mv_x(blk_y, blk_x) = best_del_x;
            
        end
        
        subplot(2,2,2);
        percent_done = sprintf('Target Frame; %d %% Done', floor(blk_y * 100 / num_blks_y));
        title(percent_done);
        
        drawnow();
        
    end
    
    % From Beser...!
    for i=1:4
        [m_Height,m_Width]=size(mv_x);
        Up_mvfx=zeros(m_Height*2,m_Width*2);
        Up_mvfx(1:2:m_Height*2,1:2:m_Width*2)=mv_x;
        Up_mvfx(1:2:m_Height*2-1,2:2:m_Width*2-1)=(mv_x(:,1:m_Width-1)+mv_x(:,2:m_Width))/2;
        Up_mvfx(2:2:m_Height*2-1,1:2:m_Width*2-1)=(mv_x(1:m_Height-1,:)+mv_x(2:m_Height,:))/2;
        Up_mvfx(2:2:m_Height*2-1,2:2:m_Width*2-1)= ...
            (mv_x(1:m_Height-1,1:m_Width-1)+mv_x(1:m_Height-1,2:m_Width)+mv_x(2:m_Height,1:m_Width-1)+mv_x(2:m_Height,2:m_Width))/4;
        mv_x=Up_mvfx;

        [m_Height,m_Width]=size(mv_y);
        Up_mvfy=zeros(m_Height*2,m_Width*2);
        Up_mvfy(1:2:m_Height*2,1:2:m_Width*2)=mv_y;
        Up_mvfy(1:2:m_Height*2-1,2:2:m_Width*2-1)=(mv_y(:,1:m_Width-1)+mv_y(:,2:m_Width))/2;
        Up_mvfy(2:2:m_Height*2-1,1:2:m_Width*2-1)=(mv_y(1:m_Height-1,:)+mv_y(2:m_Height,:))/2;
        Up_mvfy(2:2:m_Height*2-1,2:2:m_Width*2-1)= ...
            (mv_y(1:m_Height-1,1:m_Width-1)+mv_y(1:m_Height-1,2:m_Width)+mv_y(2:m_Height,1:m_Width-1)+mv_y(2:m_Height,2:m_Width))/4;
        mv_y=Up_mvfy;

    end
    
    subplot(2,2,1);
    tmp_sz = size(mv_y);
    quiver(mv_x, mv_y(tmp_sz(1):-1:1, 1:tmp_sz(2)));
    
    axis image;

    
    
    % Now plot predicted image with interpolated motion vectors
    for j=1:288
        for i=1:352
            
            get_x = i - round(mv_x(j, i));
            get_y = j - round(mv_y(j, i));
            
            if ((get_x > 0) && (get_x < 353) && (get_y > 0) && (get_y < 289))
                predictedFrame(get_y, get_x, 1:d) = anchorFrame(j, i, 1:d);
            end
            
        end
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
    