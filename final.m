
prompt = 'please choose a number denoted (1 to 5): ';
xxx = input(prompt);
while xxx ~= 1 & xxx ~= 2 & xxx ~= 3 & xxx ~= 4 & xxx ~= 5
    xxx = input(prompt);
end

%{
prompt = 'please choose a frame (1 to 10): ';
xxx2 = input(prompt);
while xxx2<1 | xxx2>10 | rem(xxx2, 1)~=0
    xxx2 = input(prompt);
end


target = [int2str(xxx) int2str(xxx2) '.jpg'];
%}
%target = ['original/' int2str(x) '/' target];

target = [int2str(xxx) '.jpg'];

%%%%%A. Segmenting the image, getting the mask of gesture

mask = color_based(target);
background = mask(1,1);
mask(mask==background) = 225;
mask(mask~=225) = 3;
mask(mask==225) = 1;
%imshow(mask, []);

%%%%%B. Finding the radius and centre of the hand region

n = size(mask(mask == 3), 1); %pixels in hand region

xc = 0;
yc = 0;

for i = 1:size(mask, 1)
    for j = 1:size(mask, 2)
        if mask(i, j) == 3
            xc = xc + i;
            yc = yc + j;
        end
    end
end
xc = xc / n;
yc = yc / n;

center = round([xc yc]);%the center of hand region


for m = 1:size(mask, 1)
    for n = 1:size(mask, 2)
        d = dist([m n], center);
        d = d(1,1);
        if d(1,1) < 5
            mask(m, n) = 2;
        end
    end
end 


imshow(mask, []);















%Color based Segmentation

function [pixel_labels] = color_based(target)
    
    image = imread(target);
    
    lab_he = rgb2lab(image);
    
    ab = lab_he(:,:,2:3);
    ab = im2single(ab);
    nColors = 3;
    pixel_labels = imsegkmeans(ab, nColors, 'NumAttempts', 3);
    
    %imshow(pixel_labels, []) 
    %title([target '  color based segmentation']);
end
