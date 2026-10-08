clear all; close all;

% Φόρτωση εικόνας
img = double(imread('new_york.png')) / 255;
if size(img, 3) == 3
    img = rgb2gray(img);
end
[M, N] = size(img);

% Εφαρμογή PSF
Y = psf(img);

% Εύρεση κρουστικής απόκρισης με impulse
impulse = zeros(M, N);
impulse(1, 1) = 1;
h = psf(impulse);

% Έλεγχος
disp(['Size h: ' num2str(size(h))]);
disp(['Sum h: ' num2str(sum(h(:)))]);
disp(['Min h: ' num2str(min(h(:)))]);
disp(['Max h: ' num2str(max(h(:)))]);

% Εμφάνιση κρουστικής απόκρισης
figure;
subplot(1,2,1); imshow(img, []); title('Αρχική');
subplot(1,2,2); imshow(Y, []); title('Μετά PSF');

figure;
imshow(h, []); title('Κρουστική απόκριση h');

% Zoom στην πάνω αριστερά γωνία της h
figure;
imshow(h(1:50, 1:50), []); 
title('Κρουστική απόκριση h (zoom)');

% Αντίστροφο φίλτρο
H = fft2(h);
Y_freq = fft2(Y);

threshold = 0.5;

H_inv = zeros(size(H));
mask = abs(H) > threshold * max(abs(H(:)));
H_inv(mask) = 1 ./ H(mask);

F_restored = H_inv .* Y_freq;
img_restored = real(ifft2(F_restored));

% Εμφάνιση
figure;
subplot(1,3,1); imshow(img); title('Αρχική');
subplot(1,3,2); imshow(Y, []); title('Μετά PSF');
subplot(1,3,3); imshow(img_restored, []); title(['Αντίστροφο (thresh=' num2str(threshold) ')']);

% MSE για διάφορες τιμές threshold
thresholds = [0.001, 0.01, 0.05, 0.1, 0.2, 0.3, 0.5, 0.7, 0.8, 0.9];
mse_values = zeros(size(thresholds));

H = fft2(h);
Y_freq = fft2(Y);

for i = 1:length(thresholds)
    t = thresholds(i);
    H_inv = zeros(size(H));
    mask = abs(H) > t * max(abs(H(:)));
    H_inv(mask) = 1 ./ H(mask);
    
    img_restored = real(ifft2(H_inv .* Y_freq));
    mse_values(i) = mean((img(:) - img_restored(:)).^2);
end

% Σχεδιασμός καμπύλης
figure;
plot(thresholds, mse_values, 'b-o', 'LineWidth', 2);
xlabel('Threshold');
ylabel('MSE');
title('MSE ως προς Threshold');
grid on;

% Χωρίς κατώφλι
H_inv_no_thresh = 1 ./ H;
F_restored_no = H_inv_no_thresh .* Y_freq;
img_no_thresh = real(ifft2(F_restored_no));

figure;
subplot(1,2,1); imshow(img); title('Αρχική');
subplot(1,2,2); imshow(img_no_thresh, []); title('Αντίστροφο χωρίς κατώφλι');