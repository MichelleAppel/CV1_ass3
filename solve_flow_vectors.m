function [ flow_vectors ] = solve_flow_vectors(image1_regions, image2_regions)
% FOR EACH REGION, CALCULATE THE OPTICAL FLOW
[ row_regions, column_regions ] = size(image1_regions);

%[ regionHeight, regionWidth ] = size(cell2mat(image1_regions(1)));
[ regionHeight, regionWidth ] = size(cell2mat(image1_regions(1)));

flow_vectors = zeros(row_regions * column_regions, 4);
counter = 1;
for i = 1:row_regions
    for j = 1:column_regions
        %im1region = cell2mat(image1_regions(i, j));
        %im2region = cell2mat(image2_regions(i, j));
        im1region = image1_regions(i, j);
        im2region = image2_regions(i, j);       

        [ h, w ] = size(cell2mat(im1region));
        
        % Incoming fugly piece of code to apply that Gauss
        G = gauss2D(20 , max(regionHeight, regionWidth));

        % Make matching dimensions
        if regionHeight ~= h
            b = floor((regionHeight - h)/2);
            G = G( b:b+h - 1 ,:);
        end
        
        if regionWidth ~= w
            b = floor((regionWidth - w)/2);
            G = G(:, b:b+w-1 );
        end        
       
        im1region = G .* double(cell2mat(im1region)); % Apply
        im2region = G .* double(cell2mat(im2region)); % Apply
        
        
        [ Gx, Gy ] = imgradientxy(im1region);  % Compute the gradients wrt x & y
        Gt = im1region - im2region;           % Compute the gradients wrt t
        
        A(:, 1) = double(reshape(Gx, h*w, 1));
        A(:, 2) = double(reshape(Gy, h*w, 1)); 
        b       = double(reshape(Gt, h*w, 1)); 
        v = (transpose(A) * A) \ (transpose(A) * b);
        
        A = [];  % reset to prevent dimension error
        
        avg_y_pixel = i*regionHeight-0.5*h;
        avg_x_pixel = j*regionWidth-0.5*w;
        
        flow_vectors(counter, :) = [avg_x_pixel, avg_y_pixel, v(1), v(2)];
        counter = counter + 1;
    end
end
end