function [ H, r, c ] = rotate_harris(image, window_size, threshold, angle)
% ROTATE_HARRIS  Find corners in a rotated image.
% Input parameters:
%   image       A rgb or grayscale image, which will be rotated.
%   window_size The window size for determining local maxima of cornerness;
%               a value from [4, 6, 8, 18, 26] (default: 26).
%   treshold    The treshold for local maxima to be determined as corner;
%               a value between 0 and 1 (default: 0.03).
%   angle       The angle for rotating the image (default: random).

if nargin < 4
    angle = rand*360;               % Set random angle
    disp(angle)
end

if nargin == 1
    window_size = 26;               % Set default window size
    threshold = 0.03;               % Set default treshold
elseif nargin == 2
    threshold = 0.03;               % Set default treshold
end

% TODO: Instead of zero padding mirror image
image = imrotate(image, angle, 'bilinear'); % or 'bicubic'
[ H, r, c ] = harris_corner_detector(image, window_size, threshold);

end