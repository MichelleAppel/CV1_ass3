function tracking(directory_name, regionWidth, regionHeight)

if nargin == 1
    regionWidth = 15;
    regionHeight = 15;
end

D = directory_name;
S = dir(fullfile(D,'*.jpg'));
imgCell = cell(numel(S));
for k = 1:numel(S)
    file = fullfile(D,S(k).name);
    imgCell{k} = imread(file);
end

first_image = imgCell{1};
[ ~, r, c ] = harris_corner_detector(first_image, 26, 0.02);

flow_vectors = zeros(2, 1, length(length(imgCell)-1));
for i = 1:length(imgCell)-1
    regions_image_1 = get_regions(imgCell{i}, r, c, regionWidth, regionHeight);
    regions_image_2 = get_regions(imgCell{i+1}, r, c, regionWidth, regionHeight);
    flow_vectors(:, :, i) = solve_flow_vectors(regions_image_1, regions_image_2);
end
flow_vectors

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