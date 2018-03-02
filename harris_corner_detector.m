function [ H, r, c ] = harris_corner_detector(image, threshold, window_size)
image = rgb2gray(image);           % Convert to grayscale
[ Gx, Gy ] = imgradientxy(image);  % Compute the gradients

[ h, w ] = size(image);            % Get the image size
Q = zeros(h, w, 2, 2);             % Initialize Q matrix

A = imgaussfilt(Gx.^2, 1);         % A element of Q
B = imgaussfilt(Gx.*Gy, 1);        % B element of Q
C = imgaussfilt(Gy.^2, 1);         % C element of Q

H = zeros(h, w);                   % Initialize H matrix
                                   % Fill in cornerness values
H(:, :) = (A .* C - B.^2) - 0.04 * (A + C).^2;

                                   % Create mask for maximum values within
                                   % window size
mask = imregionalmax(H, window_size); 
local_maxima = mask.*H;            % Multiply with cornerness values

indices = local_maxima < threshold;% When local maximum smaller then threshold
local_maxima(indices) = 0;         % Set to zero

%figure, imshow(image)
%figure, imshow(local_maxima)

[ r, c ] = find(local_maxima > 0); % Put result in rows and columns

end