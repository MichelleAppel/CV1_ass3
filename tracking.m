function tracking(directory_name, regionWidth, regionHeight)

close ALL

if nargin == 1
    regionWidth = 25;
    regionHeight = 25;
end

% Import all images from directory
D = directory_name;
S = dir(fullfile(D,'*.jpg'));
imgCell = cell(numel(S));
for k = 1:numel(S)
    file = fullfile(D,S(k).name);
    imgCell{k} = imread(file);
end

% Step 1: Locate feature points on first image
first_image = imgCell{1};
[ ~, r, c ] = harris_corner_detector(first_image, 26, 0.015);

% Step 2: Compute flow vector for all image pairs
flow_vectors = zeros(length(r), 4, length(length(imgCell)-1));

for i = 1:length(imgCell)-1
    regions_image_1 = get_regions(imgCell{i}, r, c, regionWidth, regionHeight);
    regions_image_2 = get_regions(imgCell{i+1}, r, c, regionWidth, regionHeight);
    flow_vectors(:, :, i) = solve_flow_vectors(regions_image_1, regions_image_2, r, c);
    
    

    frame = figure;
    set(frame, 'Visible', 'off');
    imshow(imgCell{i});
    hold on;
    quiver(flow_vectors(:, 1, i), flow_vectors(:, 2, i), flow_vectors(:, 3, i), flow_vectors(:, 4, i), 'linewidth', 1, 'color', 'g', 'MaxHeadSize', 2);
    M(i) = getframe;
    close ALL
    
    % Update feature points
    c = round(c + regionWidth*flow_vectors(:, 3, i));
    r = round(r + regionHeight*flow_vectors(:, 4, i));
    
end
movie(M)


end

%%
function [ flow_vectors ] = solve_flow_vectors(image1_regions, image2_regions, r, c)
% FOR EACH REGION, CALCULATE THE OPTICAL FLOW
[ h, w, no_regions ] = size(image1_regions);

flow_vectors = zeros(no_regions, 4);
counter = 1;
for i = 1:no_regions
    im1region = image1_regions(:, :, i);
    im2region = image2_regions(:, :, i);       

    % Incoming fugly piece of code to apply that Gauss
    G = gauss2D(20 , max(h, w));
    
    im1region = G .* im1region; % Apply
    im2region = G .* im2region; % Apply

    [ Gx, Gy ] = imgradientxy(im1region);  % Compute the gradients wrt x & y
    Gt = im1region - im2region;           % Compute the gradients wrt t

    A(:, 1) = double(reshape(Gx, h*w, 1));
    A(:, 2) = double(reshape(Gy, h*w, 1)); 
    b       = double(reshape(Gt, h*w, 1)); 
    v = (transpose(A) * A) \ (transpose(A) * b);

    A = [];  % reset to prevent dimension error

    flow_vectors(counter, :) = [c(i), r(i), v(1), v(2)];
    counter = counter + 1;

end
end

%%
function [ regions ] = get_regions(image, r, c, regionWidth, regionHeight)

x_region_bound = floor(regionWidth / 2);
y_region_bound = floor(regionHeight / 2);

[ h, w ] = size(image);

left_bound = max(1, c-x_region_bound);
right_bound = min(w, c+x_region_bound);
if mod(regionWidth, 2) == 0
    right_bound = right_bound + 1;
end
upper_bound = max(1, r-y_region_bound);
lower_bound = min(h, r+y_region_bound);
if mod(regionHeight, 2) == 0
    lower_bound = lower_bound + 1;
end

image = rgb2gray(image);
regions = zeros(regionWidth, regionHeight, length(r));

    for i = 1:length(r)
        region = image(upper_bound(i):lower_bound(i), left_bound(i):right_bound(i));
        [ region_w, region_h ] = size(region);

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