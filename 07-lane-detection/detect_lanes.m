function detect_lanes(filename)

% Φόρτωση εικόνας
img = imread(filename);
[rows, cols, ~] = size(img);

% Μετατροπή σε grayscale
img_gray = rgb2gray(img);

% Gaussian εξομάλυνση
img_smooth = imgaussfilt(img_gray, 2);

% ROI mask
vertices = [0.08*cols, rows; 0.43*cols, 0.63*rows; 
            0.58*cols, 0.63*rows; 0.92*cols, rows];
mask = poly2mask(vertices(:,1), vertices(:,2), rows, cols);
img_roi = img_smooth;
img_roi(~mask) = 0;

% Canny
edges = edge(img_roi, 'canny', [0.10 0.20]);

% Hough
[H, theta, rho] = hough(edges);
peaks = houghpeaks(H, 10, 'Threshold', 0.3*max(H(:)));
lines = houghlines(edges, theta, rho, peaks, 'FillGap', 40, 'MinLength', 30);

% Φιλτράρισμα και παλινδρόμηση
left_points = [];
right_points = [];

for k = 1:length(lines)
    dx = lines(k).point2(1) - lines(k).point1(1);
    dy = lines(k).point2(2) - lines(k).point1(2);
    if dx == 0; continue; end
    slope = dy/dx;
    if abs(slope) > 0.3
        if slope < 0 && lines(k).point1(1) < cols/2
            left_points = [left_points; lines(k).point1; lines(k).point2];
        elseif slope > 0 && lines(k).point1(1) > cols/2
            right_points = [right_points; lines(k).point1; lines(k).point2];
        end
    end
end

% Σχεδίαση
figure;
imshow(img); hold on;
title(filename);

y_bottom = rows;
y_top = round(0.63 * rows);

if ~isempty(left_points)
    p_left = polyfit(left_points(:,2), left_points(:,1), 1);
    x_left_bottom = polyval(p_left, y_bottom);
    x_left_top = polyval(p_left, y_top);
    line([x_left_bottom x_left_top], [y_bottom y_top], ...
        'Color', 'red', 'LineWidth', 4);
end

if ~isempty(right_points)
    p_right = polyfit(right_points(:,2), right_points(:,1), 1);
    x_right_bottom = polyval(p_right, y_bottom);
    x_right_top = polyval(p_right, y_top);
    line([x_right_bottom x_right_top], [y_bottom y_top], ...
        'Color', 'blue', 'LineWidth', 4);
end

if ~isempty(left_points) && ~isempty(right_points)
    lane_region = [x_left_bottom, y_bottom; x_left_top, y_top;
                   x_right_top, y_top; x_right_bottom, y_bottom];
    patch(lane_region(:,1), lane_region(:,2), 'green', ...
        'FaceAlpha', 0.3, 'EdgeColor', 'none');
end

end