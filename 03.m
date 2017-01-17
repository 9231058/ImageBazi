pkg load image

clear

function image = read_image (address)
	im = imread (address);
	im = imresize(im, 0.25);
	im = rgb2gray(im);
	image = im2double(im);
endfunction

training_set = 'training_set';

im_path = input ("Please enter source image path ", "s");
im_source = read_image (im_path);

# Assume each face image has m * n = M pixels
M  = size (im_source, 1) * size (im_source, 2);

# N = training set size
N = 2;

# S = training set
# S = [f_1, f_2, ..., f_N]
S = zeros (M, N);

for i = 1:N
	f = read_image (sprintf ('%s/%02d.jpg', training_set, i));
        S(:, i) = f(:);
endfor

S_bar = mean (S, 2);
A = S - S_bar;

# SVD
[u, s, v] = svd (A);

# Assume the rank of A is r <= N << M.
r = rank (A);

# It can be proved that {u_1, u_2, ... u_r} form an
# orthonormal basis for R(A), the range (column) subspace
# of matrix A.
# x = [u_1, u_2, ..., u_r]' * (f - f_bar)
xi = u(:, 1:r)' * A;

#
e0 = 10;

ei = zeros (1, N);

# Facial Recognition

# Coordinate vector x is used to find which of the training
# faces best describes the face f.

x = u(:, 1:r)' * (im_source(:) - S_bar);

for i = 1:N
	ei(i) = ((x - xi(:, i))' * (x - xi(:, i))) ^ 0.5;
endfor

display (ei);
	
if min (ei) < e0
	display ("We find you in our training set");
else
	display ("We can not find you in our training set");
endif
