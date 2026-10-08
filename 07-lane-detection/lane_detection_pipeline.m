%  ΜΕΡΟΣ Α: Προεπεξεργασία εικόνας

% Α.1: Φόρτωση εικόνας και μετατροπή σε grayscale 
img = imread('straight_lines1.jpg');
img_gray = rgb2gray(img);

figure('Name', 'Μέρος Α - Grayscale');
subplot(1,2,1); imshow(img);      title('Αρχική εικόνα');
subplot(1,2,2); imshow(img_gray); title('Grayscale');

% Α.2: Εξομάλυνση με δύο διαφορετικά φίλτρα 
img_gaussian = imgaussfilt(img_gray, 2);  % Gaussian, sigma = 2
img_mean     = imfilter(img_gray, fspecial('average', 5)); % Mean 5x5

figure('Name', 'Μέρος Α - Σύγκριση φίλτρων εξομάλυνσης');
subplot(1,3,1); imshow(img_gray);     title('Αρχική Grayscale');
subplot(1,3,2); imshow(img_gaussian); title('Gaussian (\sigma=2)');
subplot(1,3,3); imshow(img_mean);     title('Mean 5x5');

%  ΜΕΡΟΣ Β: Δημιουργία περιοχής ενδιαφέροντος (ROI)

[rows, cols] = size(img_gray);

% Β.1-Β.2: Ορισμός τραπεζοειδούς ROI 
% Κορυφές: κάτω-αριστερά, πάνω-αριστερά, πάνω-δεξιά, κάτω-δεξιά
vertices = [100, 720; 550, 420; 750, 420; 1200, 720];

% Β.3: Δημιουργία δυαδικής μάσκας ROI
mask = poly2mask(vertices(:,1), vertices(:,2), rows, cols);

% Β.4: Εφαρμογή μάσκας στην (εξομαλυμένη) εικόνα
img_roi = img_gaussian;
img_roi(~mask) = 0;

figure('Name', 'Μέρος Β - Περιοχή Ενδιαφέροντος');
subplot(1,3,1); imshow(img_gray); title('Αρχική Grayscale');
subplot(1,3,2); imshow(mask);     title('Μάσκα ROI');
subplot(1,3,3); imshow(img_roi);  title('Εικόνα με ROI');

%  ΜΕΡΟΣ Γ: Ανίχνευση ακμών

% Γ.1: Sobel 
edges_sobel = edge(img_roi, 'sobel');

% Γ.1, Γ.3: Canny με διαφορετικά ζεύγη κατωφλίων 
edges_canny1 = edge(img_roi, 'canny', [0.05 0.15]);
edges_canny2 = edge(img_roi, 'canny', [0.10 0.20]);  % επιλεγμένο ζεύγος
edges_canny3 = edge(img_roi, 'canny', [0.15 0.30]);

figure('Name', 'Μέρος Γ - Sobel vs Canny (διαφορετικά κατώφλια)');
subplot(2,2,1); imshow(edges_sobel);  title('Sobel');
subplot(2,2,2); imshow(edges_canny1); title('Canny [0.05, 0.15]');
subplot(2,2,3); imshow(edges_canny2); title('Canny [0.10, 0.20]');
subplot(2,2,4); imshow(edges_canny3); title('Canny [0.15, 0.30]');

% Γ.2: Ακμές πριν και μετά την εφαρμογή ROI 
edges_before_roi = edge(img_gaussian, 'canny', [0.10 0.20]);

figure('Name', 'Μέρος Γ - Ακμές πριν/μετά ROI');
subplot(1,2,1); imshow(edges_before_roi); title('Canny πριν ROI');
subplot(1,2,2); imshow(edges_canny2);     title('Canny μετά ROI');

edges_sobel_before = edge(img_gaussian, 'sobel');   % πριν ROI
% edges_sobel (μετά ROI) έχει υπολογιστεί ήδη παραπάνω

figure('Name', 'Μέρος Γ - Sobel πριν/μετά ROI');
subplot(1,2,1); imshow(edges_sobel_before); title('Sobel πριν ROI');
subplot(1,2,2); imshow(edges_sobel);        title('Sobel μετά ROI');

% Επιλεγμένη εικόνα ακμών για τα επόμενα στάδια
edges_final = edges_canny2;

%  ΜΕΡΟΣ Δ: Ανίχνευση ευθειών με μετασχηματισμό Hough

% Δ.1-Δ.2: Hough Transform & Accumulator
[H, theta, rho] = hough(edges_final);

figure('Name', 'Μέρος Δ - Hough Accumulator');
imshow(imadjust(rescale(H)), 'XData', theta, 'YData', rho, ...
    'InitialMagnification', 'fit');
xlabel('\theta (degrees)');
ylabel('\rho (pixels)');
title('Hough Accumulator');
axis on; axis normal;
colormap(hot); colorbar;

% --- Δ.3-Δ.4: Εντοπισμός κορυφών και γραμμών ---
peaks = houghpeaks(H, 10, 'Threshold', 0.3 * max(H(:)));
lines = houghlines(edges_final, theta, rho, peaks, ...
    'FillGap', 40, 'MinLength', 30);

figure('Name', 'Μέρος Δ - Όλες οι ανιχνευμένες γραμμές Hough');
imshow(img); hold on;
for k = 1:length(lines)
    xy = [lines(k).point1; lines(k).point2];
    plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
end
title('Ανιχνευμένες γραμμές Hough (πριν φιλτράρισμα)');

% Δ.5: Απόρριψη γραμμών που δεν αντιστοιχούν σε λωρίδες
% Κριτήριο: απόρριψη σχεδόν οριζόντιων γραμμών (|κλίση| <= 0.3)
figure('Name', 'Μέρος Δ - Φιλτραρισμένες γραμμές');
imshow(img); hold on;
for k = 1:length(lines)
    dx = lines(k).point2(1) - lines(k).point1(1);
    dy = lines(k).point2(2) - lines(k).point1(2);
    if dx == 0
        continue;
    end
    slope = dy / dx;
    if abs(slope) > 0.3
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    end
end
title('Φιλτραρισμένες γραμμές (απόρριψη οριζόντιων)');

%  ΜΕΡΟΣ Ε: Εκτίμηση τελικών λωρίδων κυκλοφορίας

% Ε.1-Ε.2: Ομαδοποίηση γραμμών σε αριστερές/δεξιές με βάση την κλίση 
left_points  = [];
right_points = [];

for k = 1:length(lines)
    dx = lines(k).point2(1) - lines(k).point1(1);
    dy = lines(k).point2(2) - lines(k).point1(2);
    if dx == 0
        continue;
    end
    slope = dy / dx;

    if abs(slope) > 0.3  % αγνοούμε σχεδόν οριζόντιες
        if slope < 0 && lines(k).point1(1) < cols/2
            % Αρνητική κλίση, αριστερό μισό εικόνας --> αριστερή λωρίδα
            left_points = [left_points; lines(k).point1; lines(k).point2];
        elseif slope > 0 && lines(k).point1(1) > cols/2
            % Θετική κλίση, δεξιό μισό εικόνας --> δεξιά λωρίδα
            right_points = [right_points; lines(k).point1; lines(k).point2];
        end
    end
end

% --- Ε.3: Εκτίμηση τελικής ευθείας ανά ομάδα με γραμμική παλινδρόμηση ---
y_bottom = rows; % κάτω άκρο εικόνας
y_top    = 450; % πάνω άκρο ROI

p_left  = polyfit(left_points(:,2),  left_points(:,1),  1);
p_right = polyfit(right_points(:,2), right_points(:,1), 1);

x_left_bottom  = polyval(p_left,  y_bottom);
x_left_top     = polyval(p_left,  y_top);
x_right_bottom = polyval(p_right, y_bottom);
x_right_top    = polyval(p_right, y_top);

% Ε.4: Σχεδίαση τελικών λωρίδων στην αρχική εικόνα 
figure('Name', 'Μέρος Ε - Τελικές λωρίδες κυκλοφορίας');
imshow(img); hold on;

line([x_left_bottom  x_left_top],  [y_bottom y_top], ...
    'Color', 'red',  'LineWidth', 4);
line([x_right_bottom x_right_top], [y_bottom y_top], ...
    'Color', 'blue', 'LineWidth', 4);

% Ε.5 (προαιρετικό): Σκίαση εκτιμώμενης περιοχής οδήγησης 
lane_region = [x_left_bottom,  y_bottom;
               x_left_top,     y_top;
               x_right_top,    y_top;
               x_right_bottom, y_bottom];

patch(lane_region(:,1), lane_region(:,2), 'green', ...
    'FaceAlpha', 0.3, 'EdgeColor', 'none');

title('Τελικές λωρίδες κυκλοφορίας');
legend('Αριστερή λωρίδα', 'Δεξιά λωρίδα', 'Location', 'best');

%  ΜΕΡΟΣ ΣΤ: Αξιολόγηση σε υποβαθμισμένες εικόνες (θόρυβος)

%  ΣΤ.1: Προσθήκη θορύβου 
img_gaussian_noise = imnoise(img_gray, 'gaussian', 0, 0.01);
img_salt_pepper    = imnoise(img_gray, 'salt & pepper', 0.05);

figure('Name', 'Μέρος ΣΤ - Υποβαθμισμένες εικόνες');
subplot(1,3,1); imshow(img_gray);           title('Αρχική');
subplot(1,3,2); imshow(img_gaussian_noise); title('Gaussian θόρυβος');
subplot(1,3,3); imshow(img_salt_pepper);    title('Salt & Pepper');

% ΣΤ.2 (πριν αποθορυβοποίηση): εφαρμογή αλγορίθμου στις θορυβώδεις εικόνες 
img_noise_roi_gauss = img_gaussian_noise; img_noise_roi_gauss(~mask) = 0;
img_noise_roi_sp    = img_salt_pepper;    img_noise_roi_sp(~mask)    = 0;

edges_noisy_gauss = edge(img_noise_roi_gauss, 'canny', [0.10 0.20]);
edges_noisy_sp    = edge(img_noise_roi_sp,    'canny', [0.10 0.20]);

figure('Name', 'Μέρος ΣΤ - Ακμές σε θορυβώδεις εικόνες (πριν αποθορυβοποίηση)');
subplot(1,2,1); imshow(edges_noisy_gauss); title('Ακμές - Gaussian θόρυβος (χωρίς φιλτράρισμα)');
subplot(1,2,2); imshow(edges_noisy_sp);    title('Ακμές - Salt & Pepper (χωρίς φιλτράρισμα)');

% ΣΤ.3: Αποθορυβοποίηση πριν την ανίχνευση ακμών 
img_gauss_filtered  = imgaussfilt(img_gaussian_noise, 2);   % για Gaussian θόρυβο
img_median_filtered = medfilt2(img_salt_pepper, [3 3]);     % για Salt & Pepper

figure('Name', 'Μέρος ΣΤ - Αποθορυβοποίηση');
subplot(2,2,1); imshow(img_gaussian_noise);  title('Gaussian θόρυβος');
subplot(2,2,2); imshow(img_gauss_filtered);  title('Μετά Gaussian filter');
subplot(2,2,3); imshow(img_salt_pepper);     title('Salt & Pepper');
subplot(2,2,4); imshow(img_median_filtered); title('Μετά Median filter');

% ΣΤ.4: Σύγκριση πριν/μετά αποθορυβοποίηση (στάδιο ακμών) 
img_gauss_roi  = img_gauss_filtered;  img_gauss_roi(~mask)  = 0;
img_median_roi = img_median_filtered; img_median_roi(~mask) = 0;

edges_gauss_clean  = edge(img_gauss_roi,  'canny', [0.10 0.20]);
edges_median_clean = edge(img_median_roi, 'canny', [0.10 0.20]);

figure('Name', 'Μέρος ΣΤ - Ακμές μετά αποθορυβοποίηση');
subplot(1,2,1); imshow(edges_gauss_clean);  title('Ακμές - μετά Gaussian filter');
subplot(1,2,2); imshow(edges_median_clean); title('Ακμές - μετά Median filter');

% Εφαρμογή πλήρους αλγορίθμου (Hough + τελικές λωρίδες) στις
% αποθορυβοποιημένες εικόνες, για πληρέστερη αξιολόγηση 
figure('Name', 'Μέρος ΣΤ - Τελική ανίχνευση μετά αποθορυβοποίηση');

% Gaussian θόρυβος μετά αποθορυβοποίηση 
[H1, theta1, rho1] = hough(edges_gauss_clean);
peaks1 = houghpeaks(H1, 10, 'Threshold', 0.3 * max(H1(:)));
lines1 = houghlines(edges_gauss_clean, theta1, rho1, peaks1, ...
    'FillGap', 40, 'MinLength', 30);

subplot(1,2,1); imshow(img); hold on;
for k = 1:length(lines1)
    dx = lines1(k).point2(1) - lines1(k).point1(1);
    dy = lines1(k).point2(2) - lines1(k).point1(2);
    if dx == 0, continue; end
    slope = dy / dx;
    if abs(slope) > 0.3
        xy = [lines1(k).point1; lines1(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    end
end
title('Μετά Gaussian filter (αρχικά: Gaussian θόρυβος)');

% Salt & Pepper θόρυβος μετά αποθορυβοποίηση 
[H2, theta2, rho2] = hough(edges_median_clean);
peaks2 = houghpeaks(H2, 10, 'Threshold', 0.3 * max(H2(:)));
lines2 = houghlines(edges_median_clean, theta2, rho2, peaks2, ...
    'FillGap', 40, 'MinLength', 30);

subplot(1,2,2); imshow(img); hold on;
for k = 1:length(lines2)
    dx = lines2(k).point2(1) - lines2(k).point1(1);
    dy = lines2(k).point2(2) - lines2(k).point1(2);
    if dx == 0, continue; end
    slope = dy / dx;
    if abs(slope) > 0.3
        xy = [lines2(k).point1; lines2(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'green');
    end
end
title('Μετά Median filter (αρχικά: Salt & Pepper θόρυβος)');

%  ΜΕΡΟΣ Ζ: Αξιολόγηση σε διαφορετικές οδικές συνθήκες

% Χρησιμοποιείται η γενικευμένη συνάρτηση detect_lanes.m (ξεχωριστό
% αρχείο) σε επιλεγμένες εικόνες που αντιστοιχούν στις 8 περιπτώσεις
% του ζητούμενου.

test_images = {
    'straight_lines1.jpg',    'Ευθύς δρόμος με καθαρές λωρίδες';
    'solidWhiteCurve.jpg',    'Δρόμος με καμπύλη';
    'um_000065.png',          'Φθαρμένες / αχνές διαγραμμίσεις';
    'whiteCarLaneSwitch.jpg', 'Παρουσία άλλων οχημάτων';
    'um_000061.png',          'Έντονες σκιές';
    'um_000027.png',          'Διαφορετικός φωτισμός';
    'straight_lines2.jpg',    'Πολλαπλές λωρίδες';
    'solidYellowLeft.jpg',    'Λευκές και κίτρινες διαγραμμίσεις'
};

for i = 1:size(test_images, 1)
    fname = test_images{i,1};
    label = test_images{i,2};
    fprintf('Περίπτωση %d: %s (%s)\n', i, label, fname);
    detect_lanes(fname);   % ανοίγει ένα figure ανά εικόνα
end

