% hw #4, 6.12
%
% Chris Shirk (cshirk@ieee.org)
%
% Implement EBMA (Exhaustive Block Matching Algorithm) w/
% block size 16x16
%
% Allow user to choose the search range (R)
%

close all;

% Block size = 16x16
blk_sz = [16 16];


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

