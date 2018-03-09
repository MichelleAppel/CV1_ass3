function [ H, r, c ] = harris_corner_detector(image, window_size, threshold)
% HARRIS_CORNER_DETECTOR  Find corners in an image.
% Input parameters:
%   image       A rgb or grayscale image.
%   window_size The window size for determining local maxima of cornerness;
%               a value from [4, 6, 8, 18, 26] (default: 26).
%   treshold    The treshold for local maxima to be determined as corner;
%               a value between 0 and 1 (default: 0.03).

close ALL % close all figures

% Default parameters
if nargin == 1
    window_size = 26;               % Set default window size
    threshold = 0.03;               % Set default treshold
elseif nargin == 2
    threshold = 0.03;               % Set default treshold
end
      
[ h, w, channels ] = size(image);   % Get the image size
image_rgb = image;
if channels == 3
    image = rgb2gray(image);        % Convert to grayscale
end

[ Gx, Gy ] = imgradientxy(image);	% Compute the gradients

A = imgaussfilt(Gx.^2, 1);          % A element of Q matrix
B = imgaussfilt(Gx.*Gy, 1);         % B element of Q matrix
C = imgaussfilt(Gy.^2, 1);          % C element of Q matrix

H = zeros(h, w);                    % Initialize H matrix
                                    % Fill in cornerness values
H(:, :) = (A .* C - B.^2) - 0.04 * (A + C).^2;

     
mask = imregionalmax(H, window_size); % Create mask for max values in window size
local_maxima = mask.*H;             % Multiply with cornerness values
local_maxima = local_maxima / max(max(local_maxima)); % Normalize values

indices = local_maxima < threshold; % When local maximum smaller then threshold
local_maxima(indices) = 0;          % Set to zero

[ r, c ] = find(local_maxima > 0);  % Put result in rows and columns

                                    % Plot derivates and detected corners
figure, imshow(Gx), title('Derivative of image in x-direction')
figure, imshow(Gy), title('Derivative of image in y-direction')
figure, imshow(image_rgb), title('Detected corners')
hold on;
plot(c, r, 'go', 'LineWidth', 2, 'MarkerSize', 15);

end