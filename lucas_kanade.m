function lucas_kanade(image1, image2, regionWidth, regionHeight)
% LUCAS_KANADE  Find optical flow between two images.
% Input parameters:
%   image1          A rgb or grayscale image.
%   image2          A rgb or grayscale image (equal size as image1).
%   regionWidth     The width of regions used to calculate
%                   optical flow (default: 15).
%   regionHeight    The height of regions used to calculate
%                   optical flow (default: 15).

image1 = rgb2gray(image1);            % Convert to grayscale
image2 = rgb2gray(image2);            % Convert to grayscale
[ rows, columns ] = size(image1);     % Get the image1 size (equal to image2)
% synth1.pgm and synth2.pgm    % 128x128
% sphere1.ppm and sphere2.ppm  % 200x200x3
%figure, imshow(image1)
%figure, imshow(image2)

if nargin == 2
    regionWidth = 15; % default
    regionHeight= 15; % default
end

% 1. Divide input images on non-overlapping (15x15) regions.

% determine the amount of rows and columns
columnAmount = floor(columns / regionWidth);
rowAmount = floor(rows / regionHeight);

% determine the amount of rows and columns per region
columnDivision = [regionWidth * ones(1, columnAmount), mod(columns, regionWidth)];
rowDivision = [regionHeight * ones(1, rowAmount), mod(rows, regionHeight)];

% divide the image into regions of the determined dimensions
image1_regions = mat2cell(image1, rowDivision, columnDivision);
image2_regions = mat2cell(image2, rowDivision, columnDivision);

% 2. For each region compute A, AT and b. 
% Then, estimate optical flow as given in Equation 20.

[ row_regions, column_regions ] = size(image1_regions);

figure, imshow(image1)
hold on;

% FOR EACH REGION, CALCULATE THE OPTICAL FLOW
for i = 1:row_regions
    for j = 1:column_regions
        im1region1 = cell2mat(image1_regions(i, j));
        im2region1 = cell2mat(image2_regions(i, j));

        [ Gx, Gy ] = imgradientxy(im1region1);  % Compute the gradients wrt x & y
        Gt = im1region1 - im2region1;           % Compute the gradients wrt t
        [ h, w ] = size(Gx);
        
        A(:, 1) = double(reshape(Gx, h*w, 1));
        A(:, 2) = double(reshape(Gy, h*w, 1)); 
        b       = double(reshape(Gt, h*w, 1)); 
        v = (transpose(A) * A) \ (transpose(A) * b);
        
        A = [];  % reset to prevent dimension error
        
        avg_y_pixel = i*15-0.5*h;
        avg_x_pixel = j*15-0.5*w;
        
        quiver(avg_x_pixel, avg_y_pixel, 25*v(1), 25*v(2),'linewidth',5)
    end
end


% 3. When you have estimation for optical flow (Vx,Vy) of each region, 
% you should display the results. 
% There is a MATLAB function quiver which plots a set of 
% two-dimensional vectors as arrows on the screen. 
% Try to figure out how to use this to plot your optical flow results.

%im = imread('autumn.tif');
%[x,y] = meshgrid(-2:.2:2,-1:.15:1);
%z = x .* exp(-x.^2 - y.^2); [px,py] = gradient(z,.2,.15);
%quiver(x,y,px,py); axis image %plot the quiver to see the dimensions of the plot
%hax = gca; %get the axis handle
%image(hax.XLim,hax.YLim,im); %plot the image within the axis limits
%hold on; %enable plotting overwrite
%quiver(x,y,px,py) %plot the quiver on top of the image (same axis limits)

end