function [ H, r, c ] = rotate_harris(image, threshold, window_size, angle)

if nargin == 3
    angle = rand*360;
    disp(angle)
end

image = imrotate(image, angle);
[ H, r, c ] = harris_corner_detector(image, threshold, window_size);

end