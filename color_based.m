
%Color based Segmentation

function [] = color_based(target)
    
    image = imread(target);
    
    lab_he = rgb2lab(image);
    
    ab = lab_he(:,:,2:3);
    ab = im2single(ab);
    nColors = 3;
    pixel_labels = imsegkmeans(ab, nColors, 'NumAttempts', 3);
    
    imshow(pixel_labels, []) 
    title([target '  color based segmentation']);
end

