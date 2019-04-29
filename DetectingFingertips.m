
function [] = DetectingFingertips()

    prompt = 'please choose a number denoted (1 to 5), then a frame number (1 to 2): ';
    xxx = input(prompt);
    target = [int2str(xxx) '.jpg'];


    %%%%%A. Segmenting the image, getting the mask of gesture

    hand = 0;
    centerDot = 2;
    background = 1;

    mask = color_based(target); 
    back = mode([mask(1, 1), mask(1, size(mask,2)), mask(size(mask, 1), 1), mask(size(mask, 1), size(mask, 2))]);

    mask(mask~=back) = hand;
    mask(mask~=hand) = background;

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

    chMask = bwconvhull(~mask);
    chMask = ~chMask;

    distChMask = bwdist(chMask);
    radius = distChMask(xc, yc);


    %%%%%C.  Convex Hull 

    [X, Y] = find(~mask);


    X = X';
    Y = Y';

    k = convhull(X, Y);



    %%%%%D.  Getting the vertice 

    threshold = min(size(mask, 1), size(mask, 2))/7;%the minimizing distance to differentiate clusters

    vertice = [k(1)];
    count = [1];
    howFar = distance(X(k(1)), Y(k(1)), xc, yc);
    for i = 2:size(k, 1)
        last = k(i-1);
        xl = X(last);
        yl = Y(last);
        xcur = X(k(i));
        ycur = Y(k(i));
        d = distance(xl, yl, xcur, ycur);
        if d > threshold
            vertice = [vertice k(i)];
            count = [count 1];
            howFar = distance(xcur, ycur, xc, yc);
        else
            if distance(xcur, ycur, xc, yc) > howFar
                howfar = distance(xcur, ycur, xc, yc);
                vertice(end) = k(i);
            end
            e = count(end);
            e = e + 1;
            count(end) = e;
        end
    end 

    if X(vertice(end)) == size(mask, 1) | Y(vertice(end)) == size(mask, 2) | X(vertice(end)) == 1 | Y(vertice(end)) == 1
        vertice(end) = [];
        count(1) = count(1) + count(end);
        count(end)=[];
    end

    if distance(X(vertice(1)), Y(vertice(1)), X(vertice(end)), Y(vertice(end))) < threshold
        if distance(X(vertice(1)), Y(vertice(1)), xc, yc) > distance(X(vertice(end)), Y(vertice(end)), xc,  yc)
            vertice(end) = [];
            count(1) = count(1) + count(end);
            count(end) = [];
        else
            vertice(1) = [];
            count(end) = count(1) + count(end);
            count(1) = [];
        end
    end

    %getting rid of the wist vertex
    wistInd = find(count == max(count));
    wist = vertice(wistInd);

    vertice(wistInd) = [];
    count(wistInd) = [];


    lengths = [];
    for i = 1:size(vertice, 2)
       t = vertice(i);
       d = sqrt((X(t) - xc)^2 + (Y(t) - yc)^2);
       lengths = [lengths d];
    end


    %%%%Indentifying finger tips
    numofTips = 0;

    maxLengths = max(lengths);

    maxInd = find(lengths == max(lengths));
    maxPoint = vertice(maxInd);

    fingerLeft = 5;
    filter = 1/1.7; %filter out contour contex by lengths
    tips = [];

    for i = 1:size(vertice, 2)
        if lengths(i) > filter*maxLengths & fingerLeft > 0 & angle(X(vertice(i)), Y(vertice(i)), X(maxPoint), Y(maxPoint), xc, yc) < 120%filter out contour contex by lengths and angles with index
            tips = [tips vertice(i)];
            fingerLeft = fingerLeft - 1;
            
        end
    end

    numofTips = size(tips, 2);


    dotMask = imread(target);
    for i = 1:size(tips, 2)
        dotMask = dot(dotMask, [X(tips(i)) Y(tips(i))], size(mask, 1)/100);
    end
    %dotMask = dot(dotMask, [xc, yc], size(mask, 1)/100);

    figure, imshow(dotMask, []);


    disp(['The number of fingertips is: ', num2str(numofTips)])





    %%%%%%%%%Helpers%%%%%%%
    %Color based Segmentation

    function [pixel_labels] = color_based(target)

        image = imread(target);

        lab_he = rgb2lab(image);

        ab = lab_he(:,:,2:3);
        ab = im2single(ab);
        nColors = 2;
        pixel_labels = imsegkmeans(ab, nColors, 'NumAttempts', 3);

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

    %Geting distance
    function [d] = distance(x1, y1, x2, y2)
        d = sqrt((x1-x2)^2 + (y1-y2)^2);

    end

    %getting the angle of two points and the center
    function output = angle(x1, y1, x2, y2, xc, yc)
        c = distance(x1, y1, x2, y2);
        a = distance(x1, y1, xc, yc);
        b = distance(x2, y2, xc, yc);

        cos = (a^2+b^2-c^2)/(2*a*b);
        output = acos(cos)*180/pi;
    end
end

