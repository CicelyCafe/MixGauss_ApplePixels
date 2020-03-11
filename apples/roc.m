%ROC

load('posteriorApple');
load('curlmask');

[TPR FPR] = ROCvalue(posteriorApple,curImask);
plot(FPR,TPR);
title('ROC curve of the Test Apple Image');
xlabel('FPR');
ylabel('TPR');
Area=trapz(sort(FPR),sort(TPR));
fprintf('Area under the ROC = %1.4f',Area);