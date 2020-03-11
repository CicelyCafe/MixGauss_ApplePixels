function like = MixGaussLike(data,mixGaussEst)

D = mixGaussEst.d;
like = 0;

for (i=1:mixGaussEst.k)
    m = mixGaussEst.mean(:,i); 
    dcov = det(mixGaussEst.cov(:,:,i));
    like = like+ 1/sqrt((2*pi)^D*dcov)*exp(-0.5*(data-m)'*inv(mixGaussEst.cov(:,:,i))*(data-m))*mixGaussEst.weight(i);
end