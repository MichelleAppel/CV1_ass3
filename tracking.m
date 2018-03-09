% TODO: Fix moving tracking points
% TODO: Output movie (mp4)
% TODO: Misschien nog even kijken naar threshold error pingpong (0.01 ? of iets)

function tracking(directory_name, regionWidth, regionHeight)
% Input parameters:
%   directory_name  The directory containing the images
%   regionWidth     The width of regions used to calculate
%                   optical flow (default: 15).
%   regionHeight    The height of regions used to calculate
%                   optical flow (default: 15).

if nargin == 1
    regionWidth = 15;
    regionHeight = 15;
end

% Import all images from directory
D = directory_name;
S = dir(fullfile(D,'*.jpeg'));

no_images = numel(S);
imgCell = cell(no_images); % Cell that is going to contain the images

for k = 1:no_images
    file = fullfile(D,S(k).name);
    imgCell{k} = imread(file); % Put images in cell
end

% Step 1: Locate feature points on first image
first_image = imgCell{1};
[ ~, r, c ] = harris_corner_detector(first_image, 26, 0.02);

close ALL;

% Step 2: Compute flow vector for all image pairs
flow_vectors = zeros(length(r), 4, length(length(imgCell)-1));

for i = 1:length(imgCell)-1
    regions_image_1 = get_regions(imgCell{i}, r, c, regionWidth, regionHeight);
    regions_image_2 = get_regions(imgCell{i+1}, r, c, regionWidth, regionHeight);
    flow_vectors(:, :, i) = solve_flow_vectors(regions_image_1, regions_image_2, r, c);
    
    % Make image for the movie
    figure;
    set(gcf, 'units', 'normalized', 'outerposition', [0 0 0.42 0.42]); % Needed to fit the movie within the frame for some reason
    set(gcf, 'Visible', 'off');
    imshow(imgCell{i});
    hold on;
    % Draw arrows
    quiver(flow_vectors(:, 1, i), flow_vectors(:, 2, i), flow_vectors(:, 3, i), flow_vectors(:, 4, i), 'linewidth', 1, 'color', 'g', 'MaxHeadSize', 2);
    saveas(gcf, strcat('output/tracking/', directory_name, string(i), '.png'));
    M(i) = getframe(); 
    
    close ALL
    
    % Update feature points
    c = round(c + 12*flow_vectors(:, 3, i));
    r = round(r + 12*flow_vectors(:, 4, i));
end
movie(M, 42)

end

%% Solve the flow vectors for two images
function [ flow_vectors ] = solve_flow_vectors(image1_regions, image2_regions, r, c)
% Input parameters:
%   image1_regions  The regions of image 1
%   image2_regions  The regions of image 1
%   r               The row (x) coordinates of the centroids of the regions
%   c               The column (y) coordinates of the centroids of the regions

[ h, w, no_regions ] = size(image1_regions);

flow_vectors = zeros(no_regions, 4);
for i = 1:no_regions
    im1region = image1_regions(:, :, i);
    im2region = image2_regions(:, :, i);       

    % Apply Gauss
    G = fspecial('gaussian', h, 100);

    im1region = double(im1region);
    im2region = double(im2region);
    
    [ Gx, Gy ] = imgradientxy(im1region);  % Compute the gradients wrt x & y
    Gx = Gx .* G;
    Gy = Gy .* G;

    Gt = im1region - im2region;           % Compute the gradients wrt t
    Gt = Gt .* G;
    
    A(:, 1) = double(reshape(Gx, h*w, 1));
    A(:, 2) = double(reshape(Gy, h*w, 1)); 
    b       = double(reshape(Gt, h*w, 1)); 
    v = (transpose(A) * A) \ (transpose(A) * b);

    A = [];  % reset to prevent dimension error

    flow_vectors(i, :) = [c(i), r(i), v(1), v(2)];
end
end

%% Get regions with centroids (r, c)
function [ regions ] = get_regions(image, r, c, regionWidth, regionHeight)
% Input parameters:
%   image           A rgb or grayscale image
%   r               The row (x) coordinates of the centroids of the regions
%   c               The column (y) coordinates of the centroids of the regions
%   regionWidth     The width of regions
%   regionHeight    The height of regions

x_region_bound = floor(regionWidth  / 2); % The offset from the centroid
y_region_bound = floor(regionHeight / 2); % The offset from the centroid

[ h, w ] = size(image);

left_bound = max(1, c-x_region_bound);  % The coordinate of the left side of the region
right_bound = min(w, c+x_region_bound); % The coordinate of the right side of the region
if mod(regionWidth, 2) == 0 % When even
    right_bound = right_bound + 1; % Add 1
end

upper_bound = max(1, r-y_region_bound); % The coordinate of the upper side of the region
lower_bound = min(h, r+y_region_bound); % The coordinate of the lower side of the region
if mod(regionHeight, 2) == 0 % When even
    lower_bound = lower_bound + 1; % Add 1
end

image = rgb2gray(image); % Convert to grayscale

amount_of_regions = length(r);
regions = zeros(regionWidth, regionHeight, amount_of_regions);

    for i = 1:amount_of_regions % Create regions
        region = image(upper_bound(i):lower_bound(i), left_bound(i):right_bound(i));
        [ region_w, region_h ] = size(region);

        % Create padding when on the edge of an image
        if region_w < regionWidth || region_h < regionHeight
            padding_region = zeros(regionWidth, regionHeight);

            padding_left_region_bound = floor((regionWidth - region_w) / 2)+1;
            padding_right_region_bound = floor((regionWidth + region_w) / 2);
            padding_upper_region_bound = floor((regionHeight - region_h) / 2)+1;
            padding_lower_region_bound = floor((regionHeight + region_h) / 2);

            padding_region(padding_left_region_bound:padding_right_region_bound, padding_upper_region_bound:padding_lower_region_bound) = region;
            region = padding_region;
        end
        
        regions(:, :, i) = region;
    end
end