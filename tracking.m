function tracking(image, regionWidth, regionHeight)
[ h, w, ~ ] = size(image);
[ ~, r, c ] = harris_corner_detector(image, 26, 0.02);

if nargin == 1
    regionWidth = 15;
    regionHeight = 15;
end

x_region_bound = floor(regionWidth / 2);
y_region_bound = floor(regionHeight / 2);

%regions = mat2cell()


left_bound = max(1, c-x_region_bound);
right_bound = min(w, c+x_region_bound);
upper_bound = max(1, r-y_region_bound);
lower_bound = min(h, r+y_region_bound);

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