function lucas_kanade(image1, image2, regionWidth, regionHeight, sigma)
% LUCAS_KANADE  Find optical flow between two images.
% Input parameters:
%   image1          A rgb or grayscale image.
%   image2          A rgb or grayscale image (equal size as image1).
%   regionWidth     The width of regions used to calculate
%                   optical flow (default: 15).
%   regionHeight    The height of regions used to calculate
%                   optical flow (default: 15).
%   sigma           The standard deviation for the Gaussian filter 
%                   over the image regions.
%   

clc % clear command window
close ALL % close all figures

% Default parameters
if nargin == 2
    regionWidth = 15; % Set default region width
    regionHeight= 15; % Set default region height
end
if nargin < 5
    sigma = 20; % Set default standard deviation for Gaussian filter
end

[ height, width, channels ] = size(image1); % Get the image1 size (equal to image2)
if channels == 3
   image1 = rgb2gray(image1); % Convert to grayscale
   image2 = rgb2gray(image2); % Convert to grayscale
end

% 1. Divide input images on non-overlapping regions.

% determine the amount of rows and columns
columnAmount = floor(width / regionWidth);
rowAmount = floor(height / regionHeight);

% determine the amount of rows and columns per region
columnDivision = [regionWidth * ones(1, columnAmount), mod(width, regionWidth)];
rowDivision = [regionHeight * ones(1, rowAmount), mod(height, regionHeight)];

% divide the image into regions of the determined dimensions
image1_regions = mat2cell(image1, rowDivision, columnDivision);
image2_regions = mat2cell(image2, rowDivision, columnDivision);


% 2. For each region compute A, A.T and b, and estimate optical flow (v).

[ row_regions, column_regions ] = size(image1_regions); % Amount of regions
flow_vectors = zeros(row_regions * column_regions, 4); % Init
counter = 1;
for i = 1:row_regions % Loop through all regions
    for j = 1:column_regions
        im1region = cell2mat(image1_regions(i, j)); % Turn cell into matrix
        im2region = cell2mat(image2_regions(i, j)); % Turn cell into matrix

        [ h, w ] = size(im1region); % Height and width of current region
        
        % Incoming fugly piece of code to apply that Gauss
        %G = gauss2D(sigma , max(regionHeight, regionWidth));
        G = fspecial('gaussian', max(regionHeight, regionWidth), sigma);

        % Make matching dimensions
        if regionHeight ~= h
            b = floor((regionHeight - h)/2);
            G = G( b:b+h - 1 ,:);
        end
        
        if regionWidth ~= w
            b = floor((regionWidth - w)/2);
            G = G(:, b:b+w-1 );
        end        
       
        im1region = G .* double(im1region); % Apply Gaussian
        im2region = G .* double(im2region); % Apply Gaussian
        
        [ Gx, Gy ] = imgradientxy(im1region); % Compute the gradients wrt x & y
        Gt = im1region - im2region;           % Compute the gradients wrt t
        
        A(:, 1) = double(reshape(Gx, h*w, 1)); % First column of A matrix (Gx)
        A(:, 2) = double(reshape(Gy, h*w, 1)); % Second column of A matrix (Gy)
        b       = double(reshape(Gt, h*w, 1)); % b vector (Gt)
        v = (transpose(A) * A) \ (transpose(A) * b); % Calculate optical flow
        
        A = []; % Reset to prevent dimension error
        
        % For drawing the vector, determine middle y and x of region
        avg_y_pixel = i*regionHeight-0.5*h;
        avg_x_pixel = j*regionWidth-0.5*w;
        
        flow_vectors(counter, :) = [avg_x_pixel, avg_y_pixel, v(1), v(2)];
        counter = counter + 1;
    end
end


% 3. Display the resulting optical flow onto the image.
figure, imshow(image1);
hold on;
quiver(flow_vectors(:, 1), flow_vectors(:, 2), ...
    flow_vectors(:, 3), flow_vectors(:, 4), ...
    'linewidth', 1, 'color', 'g', 'MaxHeadSize', 2);

end