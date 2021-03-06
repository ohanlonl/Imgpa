function detect(RGBImage);

%Take in and make grayscale
rgb = imread(RGBImage);
I = rgb2gray(rgb);
%imshow(I)
%title('Step 1: Grayscale Image');


%{
Step 2: Use gradient magnitude for segmentation function
%}
% Define 2D Sobel filter
hy = fspecial('sobel'); 
% Define hx as hy CTransposed (Reflected diagonally)
hx = hy';
% Define filters for nD image, using 2D sobel filter with
% replicate boundary option
Iy = imfilter(double(I), hy, 'replicate');
Ix = imfilter(double(I), hx, 'replicate');
% Gradient magnitude defines strength of edges
gradmag = sqrt(Ix.^2 + Iy.^2);

%{
 Step 3: Mark foreground objects
%}
% Create structuring element
se = strel('disk', 20);
% Open latest version of processed image and apply structuring element
Io = imopen(I, se);

%{
 Step 4: Erode small objects then dilate remaining bigger elements
%}
% Erode image 
Ie = imerode(I, se);
%Perform 
Iobr = imreconstruct(Ie, I);

%{
 Step 5: Closing-by-reconstruction
         Remove dark spots and marks
%}
Ioc = imclose(Io, se);

%{
 Step 6: Dilate and Reconstruct image and invert colours
%}
% Dilate
Iobrd = imdilate(Iobr, se);
% Reconstruct dilated image with an inverted dilated image
Iobrcbr = imreconstruct(imcomplement(Iobrd), imcomplement(Iobr));
% Invert colours
Iobrcbr = imcomplement(Iobrcbr);
% Adjust image intensity values
Iobrcbr = imadjust(Iobrcbr);

%{
 Step 7: Find regional maxima
%}
fgm = imregionalmax(Iobrcbr);

%{
 Step 8: Define original image with foreground markers superimposed
%}
I2 = I;
I2(fgm) = 255;

%{
 Step 9: Clean edges and then shrink
%}
se2 = strel(ones(5,5));
% Clean edges
fgm2 = imclose(fgm, se2);
% Use erode to shrink edges 
fgm3 = imerode(fgm2, se2);

%{
 Step 10: Remove small anomalies remaining from previous step
%}
% Remove smaller than 20px
fgm4 = bwareaopen(fgm3, 20);
I3 = I;
I3(fgm4) = 255;

% Binarise image
bw = imbinarize(Iobrcbr);

% Invert image colours
wb = imcomplement(bw);
% Shrink and then clean edges
wb = imdilate(wb, strel('disk',10));
wb = imclose(wb,strel('disk', 100));

% DECLARE FINAL IMAGE TO MARK
bw = wb;

%{
 Step 11: START OF PROCESSING
%}
% Matrices containing Boundaries and Labels
[B,L] = bwboundaries(bw,'noholes');

%Display label matrix and draw each boundary
imshow(label2rgb(L, @jet, [.5 .5 .5]))
hold on
for k = 1:length(B)
    boundary = B{k};
    plot(boundary(:,2),boundary(:,1), 'w', 'LineWidth', 2)
end

% Estimate of the area for all objects. 
stats = regionprops(L, 'Area', 'Centroid');

%{
Fairly low threshold for now,
elements greater than this are marked 
%}
threshold = 0.8;

% Loop over boundaries
for k = 1:length(B)
    % Obtain (X,Y) boundary coords corresponding to label 'k'
    boundary = B{k};
    
    % Compute estimate of object's perimeter
    delta_sq = diff(boundary).^2;
    perimeter = sum(sqrt(sum(delta_sq, 2)));
    
    % Obtain area calculation corresponding to label 'k'
    area = stats(k).Area;
    
    % Computer roundness metric [KEY]
    metric = 4*pi*area/perimeter^2;
    
    % Display results (
    metric_string = sprintf('%2.2f/1', metric);
    
    % Mark objects above threshold with black circle
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