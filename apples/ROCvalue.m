function [TPR FPR]=ROCvalue(img,gt)
X = size(img,1);
Y = size(img,2);

TP = zeros(256,1);
TN = zeros(256,1);
FP = zeros(256,1);
FN = zeros(256,1);

for T = 0:255
    fprintf('Processing threshold value %d\n',T);  
    t = threshold(img,T);
    for i = 1:X
        for j = 1:Y
            if (gt(i,j)==1 && t(i,j)==1)
                TP(T+1) = TP(T+1)+1;
            elseif (gt(i,j)==0 && t(i,j)==0)
                TN(T+1) = TN(T+1)+1;
            elseif (gt(i,j)==0 && t(i,j)==1)
                FP(T+1) = FP(T+1)+1;
            elseif (gt(i,j)==1 && t(i,j)==0)
                FN(T+1) = FN(T+1)+1;
            end
        end
    end
end
P = TP + FN;
N = TN + FP;
TPR = TP./P;
FPR = FP./N;
