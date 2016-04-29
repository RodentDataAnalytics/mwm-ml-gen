function [ x, y ] = trajectory_snapshot_position( fn, showimg )
%TRAJECTORY_SNAPSHOT_POSITION Extracts position from one trajectory
%snapshot
%   TRAJECTORY_SNAPSHOT_POSITION(FN) extracts X and Y coordinates from
%   image path FN
    img = imread(fn);      
    if showimg   
        figure;
        imshow(img, 'Border','tight');
    end
    
    %% cropping phase I - select arena plus surroundings according to the
    %% background colour        
    % RGB {204, 204, 204} (light grey) is the background colour of the arena
    pixelmask = (img(:,:,1) == 204 & img(:,:,2) == 204 & img(:,:,3) == 204); 
    h = size(img, 1);
    w = size(img, 2);
    s = sum(pixelmask, 2);
    % select rows/columns where at least 75% of the pixels have the
    % background colour
    c = find(sum(pixelmask, 1) > 0.5*h);
    r = find(sum(pixelmask, 2) > 0.5*w);
    % crop image    
    dr = find([diff([0; r]); inf] > 1);
    lr = diff([0; dr]);
    [~, rm] = max(lr);
    top = r(dr(rm - 1));
    bottom = r(dr(rm) - 1);
    
    dc = find([diff([0, c]), inf] > 1);
    lc = diff([0 dc]);
    [~, cm] = max(lc);
    left = c(dc(cm - 1));
    right = c(dc(cm) - 1);
    
    img = img(top:bottom, left:right);
    if showimg   
        figure;
        imshow(img, 'Border','tight');
    end
                
    %% cropping phase II - select arena only (circular area)
    % convert to BW and find white pixels
    bwimg = im2bw(img, 0.8);    
    [nzr, nzc] = find(bwimg);        
    top = min(nzr(:));
    bottom = max(nzr(:));
    left = min(nzc(:));
    right = max(nzc(:));    
    img = img(top:bottom, left:right);
    
    if showimg   
        figure;
        imshow(img, 'Border','tight');
    end
    
    % compute arena diameter (equal to the width of the cropped image) and
    % a possible vertical band due to not all arena area being covered by
    % the image
    diam = size(img, 2);
    band = diam - size(img, 1);
    
    %%
    %% find a 10x10 square in the image: this is our location
    %%    
    % first convert image to BW
    bw = imcomplement(im2bw(img, 0.3));    
    % then 'close' any gaps where our position square lies (due to it
    % overlapping with other lines)
    se = strel('square', 2);
    bw = imclose(bw, se);
    if showimg   
        figure;
        imshow(bw, 'Border','tight');
    end
    % find differences between adjacent pixels in image
    d = diff([0, reshape(bw', 1, size(img,1)*size(img,2)), 0]);    
    % start of 1s sequences
    s = find(d == 1);    
    % length of sequences
    l = find(d == -1) - s;
    % all sequences of at least 8px
    idx = find(l > 8);
    % row and starting column indexes of sequences
    r = ceil(s(idx)/diam);
    c = mod(s(idx), diam);    
    
    % find longest sequence of continugous rows
    d = diff([0 r]);
    s = find([d inf] > 1);
    l = diff([0 s]);
    % l = find(d == -1) - s;
    [lm,m] = max(l);
    if lm < 5 % at least 5 rows        
        error('Something wrong');
    end
    idx = s(m-1);
            
    % compute position
    px = mode(c(idx : (idx + lm - 1))) + 5; % in pixels
    py = r(idx) + 5 + band; % in pixels
    x = (px - diam/2) / (diam/2); % in radius of arena units
    y = -(py - diam/2) / (diam/2); % idem   
end