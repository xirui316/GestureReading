%This is the project 3 test function, please click run to see the results. 

prompt = 'please choose a video (1, 2 or 3): ';
x = input(prompt);
while x ~= 1 & x ~= 2 & x ~= 3
    x = input(prompt);
end


prompt = 'please choose a frame (1 to 10): ';
x2 = input(prompt);
while x2<1 | x2>10 | rem(x2, 1)~=0
    x2 = input(prompt);
end


target = [int2str(x) '-' int2str(x2) '.png'];

target = ['original/' int2str(x) '/' target];


semanticSegmentation(target);