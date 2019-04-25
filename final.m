
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

target = [int2str(xxx) '.jpg'];


%%%%%A. Segmenting the image, getting the mask of gesture

hand = 0;
centerDot = 2;
background = 1;

mask = color_based(target);
mask(mask==mask(1,1)) = 225;
mask(mask~=225) = hand;
mask(mask==225) = background;
%imshow(mask, []);

%%%%%B. Finding the radius and centre of the hand region

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
xc = round(xc / n);
yc = round(yc / n);


inverseMask = ~mask;
chMask = bwconvhull(inverseMask);
chMask = ~chMask;
%imshow(chMask, []);

distChMask = bwdist(chMask);
radius = distChMask(xc, yc);


%dotMask = dot(chMask, [xc, yc], radius);
%figure, imshow(dotMask, []);

%%%%%C.  Convex Hull 


X = [];
Y = [];

for i = 1:size(mask, 1)
    for j = 1:size(mask, 2)
        if mask(i, j) == hand
            X = [X i];
            Y = [Y j];
        end
    end
end
X = X';
Y = Y';

k = convhull(X, Y);
%figure, plot(xc, yc, 'r', X(k), Y(k), 'b*')


%%%%%D.  Getting the tips 

tips = [k(1)];
for i = 2:size(k, 1)
    last = k(i-1);
    xl = X(last);
    yl = Y(last);
    xcur = X(k(i));
    ycur = Y(k(i));
    d = sqrt((xl-xcur)^2 + (yl-ycur)^2);
    if d > 100
        tips = [tips k(i)];
    end
end


if sqrt((X(tips(1)) - X(tips(end)))^2 + (Y(tips(1)) - Y(tips(end)))^2)
    tips(end) = [];
end


lengths = [];
for i = 1:size(tips, 2)
   t = tips(i);
   d = sqrt((X(t) - xc)^2 + (Y(t) - yc)^2);
   lengths = [lengths d];
end

figure, plot(X(tips), Y(tips), 'b*', xc, yc, 'r*');
%getting rid of the bottom line
%{
longestInd = find(lengths == max(lengths));
longest = tips(longestInd);

temp = [];
for i = 1:size(tips, 2)
    d = distance(X(longest), Y(longest), X(i), Y(i));
    temp = [temp, d];
end
bottomInd = find(temp == max(temp));
tips(bottomInd) = [];
lengths(bottomInd)=[];
figure, plot(X(tips), Y(tips), 'b*')
%disp(radius);
%disp(lengths);
%}






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
function [output] = dot(mask, dot, radius)
    output = mask;
    x = dot(1);
    y = dot(2);
    for m = 1:size(mask, 1)
        for n = 1:size(mask, 2)
            d = sqrt((x-m)^2 + (y-n)^2);
            if d(1,1) < radius
                output(m, n) = 2;%centerDot;
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
            if mask(m, n) == 0%%%hand
                x = [x; m];
                y = [y; n];
            end
        end
    end 
    set = convhull(x, y);
end

%GFeeting distance
function [d] = distance(x1, y1, x2, y2)
    d = sqrt((x1-x2)^2 + (y1-y2)^2);
    
end


%%%%%%Trash Can%%%%%%%%%
%{
distMask = bwdist(mask);
maxi = max(distMask(:));
[xc, yc] = find(distMask == maxi);
%center = [xc, yc];
dotMask = mask;
dotMask(xc, yc) = 2;
imshow(dotMask, []);
%}

