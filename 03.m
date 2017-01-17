pkg load image

clear

function image = read_image (address):
	im = imread(address);
	im = imresize(im, 0.25);
	im = rgb2gray(im);
	im = im2double(im);
endfunction

dataset = 'dataset';

im_path = input ("Please enter source image path", "s");
im_source = read_image (im_path);

M  = size(inImage(), 1) * size(inImage(), 2);
N = 240;
A = zeros(M, N);

dataset_pics = [4 5 6 7 11 13];
dataset_pics_len = size(dataset_pics, 2);

for i = 1:(N/numOfPics)
    for j = Pics;
        f = read_image(sprintf('%s/%d-%02d.jpg', dataset, i, j));
        A(:, i) = f(:);
    end
end

%% 2. Normalize
meanOfA = mean(A, 2);
A = A - meanOfA(:, ones(1, N));

%% 3. SVD
[u, s, v] = svd(A);
R = size(s, 2);

%% 4. Coordinate x_i
xi = u(:, 1:(N/numOfPics))' * A;

%% 5. Choose threshold
e0 = 180;
e1 = 9;

%% 6. Projection
numOfTest = 50;
ef = zeros(1, numOfTest);
ei = zeros(N/(numOfPics), numOfTest);
class = -1 * ones(1, numOfTest);
for i = 1:numOfTest
    f = ReadImage(sprintf('Dataset/%d-12.jpg', i));
    f = f(:) - meanOfA;
    x = u(:, 1:(N/numOfPics))' * f;

    tmp = f - u(:, 1:(N/numOfPics)) * x;
    ef(i) = (tmp' * tmp) ^ .5;

    %% 7. Classify
    if ef(i) < e1
        for j = 1:N
            tmp = xi(:, j) - x;
            ei(j, i) = tmp' * tmp;
        end

        if min(ei(:, i)) < e0
            [m, class(i)] = min(ei(:, i));
        end
    end
end
plot(ef, '-o')

%% Summary of result
itsnc = sum(class(1:(N/numOfPics)) == -1);
itstc = sum(class(1:(N/numOfPics)) == 1:(N/numOfPics));
itsfc = sum(not(class(1:(N/numOfPics)) == 1:(N/numOfPics))) - itsnc;
itsa = (itstc) / (itsnc + itstc + itsfc) * 100;
otsnc = sum(class((N/numOfPics + 1):(numOfTest)) == -1);
otsfc = sum(not(class((N/numOfPics + 1):(numOfTest)) == -1));
otsa = (otsnc) / (otsnc + otsfc) * 100;

tp = itstc;
fp = itsfc + otsfc;
fn = itsnc;
tn = otsnc;
precision = tp / (tp + fp);
recall = tp / (tp + fn);
f1 = 2 * precision * recall / (precision + recall);

display('Result:')
display(sprintf('\tPictures from people in training set:'))
display(sprintf('\t\tNot Classified: %d', itsnc))
display(sprintf('\t\tTrue Classified: %d', itstc))
display(sprintf('\t\tFalse Classified: %d', itsfc))
display(sprintf('\t\tAccuracy: %2.1f%%', itsa))
display(sprintf('\tPictures from people not in training set:'))
display(sprintf('\t\tNot Classified: %d', otsnc))
display(sprintf('\t\tFalse Classified: %d', otsfc))
display(sprintf('\t\tAccuracy: %2.1f%%', otsa))
display(sprintf('\tPrecision: %2.1f%%', precision * 100))
display(sprintf('\tRecall: %2.1f%%', recall * 100))
display(sprintf('\tF1 Score: %2.1f%%', f1 * 100))
