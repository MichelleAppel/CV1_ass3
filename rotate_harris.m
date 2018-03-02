function [ H, r, c ] = rotate_harris(image, angle, threshold, window_size)

% TODO: random angle
image = imrotate(image, angle);
[ H, r, c ] = harris_corner_detector(image, threshold, window_size);

end