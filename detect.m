function detect(RGBImage);

%Take in and make grayscale
rgb = imread(RGBImage);
I = rgb2gray(rgb);
%imshow(I)
%title('Step 1: Grayscale Image');

% HERE!!!
%Use gradient magnitude for segmentation function
hy = fspecial('sobel');
hx = hy';
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
gradmag = sqrt(Ix.^2 + Iy.^2);
%figure
%imshow(gradmag,[]), title('Step 2: Gradient Magnitude')

% HERE!!!
% Mark foreground objects
se = strel('disk', 20);
Io = imopen(I, se);
%figure
%imshow(Io), title('Opening (Io)')

% HERE!!!
% Use erosion and reconstruct to...
Ie = imerode(I, se);
Iobr = imreconstruct(Ie, I);
%figure
%imshow(Iobr), title('Opening-by-reconstruction (Iobr)')

% HERE!!!
Ioc = imclose(Io, se);
%figure
%imshow(Ioc), title('Opening-closing (Ioc)')

% HERE!!!
Iobrd = imdilate(Iobr, se);
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
Iobrcbr = imadjust(Iobrcbr);
%figure
%imshow(Iobrcbr), title('Opening-closing by reconstruction (Iobrcbr)')

% HERE!!!
fgm = imregionalmax(Iobrcbr);
%figure
%imshow(fgm), title('Regional maxima of opening-closing by reconstruction (fgm)')

% HERE!!!
I2 = I;
I2(fgm) = 255;
%figure
%imshow(I2), title('Regional maxima superimposed on original image (I2)')

% HERE!!!
se2 = strel(ones(5,5));
fgm2 = imclose(fgm, se2);
fgm3 = imerode(fgm2, se2);

% HERE!!!
fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;
%figure
%imshow(I3)
%title('Modified regional maxima superimposed on original image (fgm4)')

% HERE!!!
bw = imbinarize(Iobrcbr);
%figure
%imshow(bw), title('Thresholded opening-closing by reconstruction (bw)')

%{
D = bwdist(bw);
DL = watershed(D);
bgm = DL == 0;
figure
imshow(bgm), title('Watershed ridge lines (bgm)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);
L = watershed(gradmag2);
I4 = I;
I4(imdilate(L == 0, ones(3, 3)) | bgm | fgm4) = 255;
figure
imshow(I4)
title('Markers and object boundaries superimposed on original image (I4)')

gradmag2 = imimposemin(gradmag, bgm | fgm4);
Lrgb = label2rgb(L, 'jet', 'w', 'shuffle');
figure
imshow(Lrgb)
title('Colored watershed label matrix (Lrgb)')
%}

% HERE!!!
wb = imcomplement(bw);
wb = imdilate(wb, strel('disk',10));
wb = imclose(wb,strel('disk', 100));
%bw = imdilate(wb,se);

%DECLARE FINAL IMAGE TO MARK
bw = wb;

%START OF PROCESSING
[B,L] = bwboundaries(bw,'noholes');

%Display label matrix and draw each boundary
imshow(label2rgb(L, @jet, [.5 .5 .5]))

hold on
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2),boundary(:,1), 'w', 'LineWidth', 2)
end

stats = regionprops(L, 'Area', 'Centroid');

%{
Fairly low threshold for now,
elements over this are marked 
%}
threshold = 0.8;

% Loop over boundaries
for k = 1:length(B)
    % Obtain (X,Y) boundary coords corresponding to label 'k'
    boundary = B{k};
    
    %Compute estimate of object's perimeter
    delta_sq = diff(boundary).^2;
    perimeter = sum(sqrt(sum(delta_sq, 2)));
    
    %obtain area calculation corresponding to label 'k'
    area = stats(k).Area;
    
    %Computer roundness metric [KEY]
    metric = 4*pi*area/perimeter^2;
    
    %Display results (
    metric_string = sprintf('%2.2f/1', metric);
    
    %Mark objects above threshold with black circle
    if metric > threshold
        centroid = stats(k).Centroid;
        % Plot settings (ro = red)
        plot(centroid(1),centroid(2),'ro', 'markers', 120, 'LineWidth', 3);
    end
    sprintf(metric_string);
    text(boundary(1,2)-35,boundary(1,1)+13,metric_string, 'Color', 'k','FontSize', 14, 'FontWeight', 'bold');
    
end

%Final Window Title
title(['Metrics closer to 1 indicate that', ...
    ' the object is round']);