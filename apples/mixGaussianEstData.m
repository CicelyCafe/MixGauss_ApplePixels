% LoadApplesScript.m
% This optional script may help you get started with loading of photos and masks.
%
% Note that there are more elegant ways to organize your (photo, mask)
% pairs, and for sorting through many files in a directory. We don't use
% them here because we only have a small number of files, but consider
% useful functions like fileparts(). For simplicity, this example code just
% makes a few cell-arrays to hold the hard-coded filenames.
clear all

if( ~exist('apples', 'dir') || ~exist('testApples', 'dir') )
    display('Please change current directory to the parent folder of both apples/ and testApples/');
end

% Note that cells are accessed using curly-brackets {} instead of parentheses ().
Iapples = cell(3,1);
Iapples{1} = 'apples/Apples_by_kightp_Pat_Knight_flickr.jpg';
Iapples{2} = 'apples/ApplesAndPears_by_srqpix_ClydeRobinson.jpg';
Iapples{3} = 'apples/bobbing-for-apples.jpg';

IapplesMasks = cell(3,1);
IapplesMasks{1} = 'apples/Apples_by_kightp_Pat_Knight_flickr.png';
IapplesMasks{2} = 'apples/ApplesAndPears_by_srqpix_ClydeRobinson.png';
IapplesMasks{3} = 'apples/bobbing-for-apples.png';


nDim = 3;
k = 2;
Apple = zeros(nDim,1);
NonApple = zeros(nDim,1);
nApple = 0;
nNonApple = 0;

%iImage = 1; % Could use this index to loop.
for im = 1:3 
    curI = double(imread(  Iapples{im}   )) / 255;
    %curI is now a double-precision 3D matrix of size (width x height x 3). 
    %Each of the 3 color channels is now in the range [0.0, 1.0].
    %figure;
    %imagesc(curI)
    curImask = imread(  IapplesMasks{im}   );
    % These mask-images are often 3-channel, and contain grayscale values. We
    % would prefer 1-channel and just binary:
    curImask = curImask(:,:,2) > 128;  % Picked green-channel arbitrarily.
    %figure;
    %imshow(curImask)
    X = size(curImask,1);
    Y = size(curImask,2);
    for i = 1:X
        for j = 1:Y
            if (curImask(i,j)==1)
                Apple(1:3,nApple+1)=curI(i,j,1:3);
                nApple = nApple+1;
            elseif (curImask(i,j)==0)
                NonApple(1:3,nNonApple+1)=curI(i,j,1:3);
                nNonApple = nNonApple+1;
            end
        end
    end 
end

sumpixel = nApple+nNonApple;
priorApple = nApple/sumpixel;
priorNonApple = nNonApple/sumpixel;

AppleMoG = fitMixGauss(Apple,k);
NonAppleMoG = fitMixGauss(NonApple,k);
