
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

hand = 1;
centerDot = hand /2;
background = 0;

mask = color_based(target);
mask(mask==mask(1,1)) = 225;
mask(mask~=225) = hand;
mask(mask==225) = background;
%imshow(mask, []);

%%%%%B. Finding the radius and centre of the hand region

%{
n = size(mask(mask == hand), 1); %pixels in hand region

xc = 0;
yc = 0;

for i = 1:size(mask, 1)
    for j = 1:size(mask, 2)
        if mask(i, j) == hand
            xc = xc + i;
            yc = yc + j;
        end
    end
end
xc = xc / n;
yc = yc / n;

center = round([xc yc]);%the center of hand region


maskCenter = dot(mask, center)
%}

%imshow(maskCenter, []);


%%%%%C.  Convex Hull 
ch = bwconvhull(mask);
imshow(ch);

%convSet = convex(mask);












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

%Drawing Dots
function [output] = dot(mask, dot)
    output = mask;
    for m = 1:size(mask, 1)
        for n = 1:size(mask, 2)
            d = dist([m n], dot);
            d = d(1,1);
            if d(1,1) < 5
                output(m, n) = 0%background;
            end
        end
    end 
end

%Getting convice
function [set] = convex(mask)
    x = [];
    y = [];
    for m = 1:size(mask, 1)
        for n = 1:size(mask, 2)
            if mask(m, n) == 1%%%hand
                x = [x; m];
                y = [y; n];
            end
        end
    end 
    set = convhull(x, y);
end