if( ~exist('moreApples', 'dir') )
    display('Please change current directory to the parent folder of both apples/ and testApples/');
end

Imoreapples = cell(2,1);
Imoreapples{1} = 'moreApples/orchard3.jpg';
Imoreapples{2} = 'moreApples/__800x800_54eea3fff3d49.jpg';

ImoreapplesMasks = cell(2,1);
ImoreapplesMasks{1} = 'moreApples/orchard3.png';
ImoreapplesMasks{2} = 'moreApples/__800x800_54eea3fff3d49.png';


priorApple = 0.5319;
priorNonApple = 0.4681;%by step1 mixGaussianEstData

load('AppleMoG');
load('NonAppleMoG');

TeCells=cell(2,1);
for i=1:2
   TeCells{i}=figure;
end
TestCells=cell(2,1);
for i = 2
    curI = double(imread(  Imoreapples{i}   )) / 255;
    TestCells{i}=curI;
    
    curImask = imread(  ImoreapplesMasks{i}   );
    curImask = curImask(:,:,2) > 128;  % Picked 
    
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
    
    %ROC
    %[TPR FPR] = ROCvalue(posteriorApple,curImask);
    %plot(FPR,TPR);
    %title('ROC curve of the Test Apple Image');
    %xlabel('FPR');
    %ylabel('TPR');
    %Area=trapz(sort(FPR),sort(TPR));
    %fprintf('Area under the ROC = %1.4f',Area);

end



