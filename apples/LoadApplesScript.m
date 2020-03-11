% LoadApplesScript.m
% This optional script may help you get started with loading of photos and masks.
%
% Note that there are more elegant ways to organize your (photo, mask)
% pairs, and for sorting through many files in a directory. We don't use
% them here because we only have a small number of files, but consider
% useful functions like fileparts(). For simplicity, this example code just
% makes a few cell-arrays to hold the hard-coded filenames.
if( ~exist('apples', 'dir') || ~exist('testApples', 'dir') )
    display('Please change current directory to the parent folder of both apples/ and testApples/');
end



% Note that cells are accessed using curly-brackets {} instead of parentheses ().
Itestapples = cell(3,1);
Itestapples{1} = 'testApples/Bbr98ad4z0A-ctgXo3gdwu8-original.jpg';
Itestapples{2} = 'testApples/Apples_by_MSR_MikeRyan_flickr.jpg';
Itestapples{3} = 'testApples/audioworm-QKUJj2wmxuI-original.jpg';

ItestapplesMasks = cell(1,1);
ItestapplesMasks{1} = 'testApples/Bbr98ad4z0A-ctgXo3gdwu8-original.png';

priorApple = 0.5319;
priorNonApple = 0.4681;%by step1 mixGaussianEstData

load('AppleMoG');
load('NonAppleMoG');

teapples=cell(3,1);
for i=1:3
   teapples{i}=figure;
end
TestCells=cell(3,1);
for i = 1:3
    curI = double(imread(  Itestapples{i}   )) / 255;
    TestCells{i}=curI;
    [imY imX imZ] = size(TestCells{i});
    posteriorApple = zeros(imY,imX);
    for cY = 1:imY 
        fprintf('Processing Row %d\n',cY);
        for cX = 1:imX          
            %extract this pixel data
            thisPixelData = squeeze(double(TestCells{i}(cY,cX,:)));
            %calculate likelihood of this data given skin model
            likeApple = MixGaussLike(thisPixelData,AppleMoG);
            likeNonApple = MixGaussLike(thisPixelData,NonAppleMoG);
            posteriorApple(cY,cX) = likeApple*priorApple/(likeApple*priorApple+likeNonApple*priorNonApple);
        end
    end;

    %draw skin posterior
    clims = [0, 1];
    imagesc(posteriorApple, clims); colormap(gray); axis off; axis image;
    drawnow;
end



