function [ H, r, c ] = rotate_harris(image, threshold, window_size, angle)

if nargin < 4
    angle = rand*360;
    disp(angle)
end

if nargin == 2
    window_size = 26;
end

% TODO: Instead of zero padding mirror image
image = imrotate(image, angle);
[ H, r, c ] = harris_corner_detector(image, threshold, window_size);

end