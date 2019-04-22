
prompt = 'please choose a number denoted (1, 2 or 3): ';
x = input(prompt);
while x ~= 1 & x ~= 2 & x ~= 3
    x = input(prompt);
end


prompt = 'please choose a frame (1 to 10): ';
x2 = input(prompt);
while x2<1 | x2>10 | rem(x2, 1)~=0
    x2 = input(prompt);
end


target = [int2str(x) int2str(x2) '.jpg'];

%target = ['original/' int2str(x) '/' target];



%%%%%segmenting the image, getting the mask of gesture

mask = color_based(target);
mask(mask>1) = 3;

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
