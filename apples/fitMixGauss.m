function mixGaussEst = fitMixGauss(data,k)
        
[nDim nData] = size(data);

postHidden = zeros(k, nData);

%initialisation
mixGaussEst.d = nDim;
mixGaussEst.k = k;
mixGaussEst.weight = (1/k)*ones(1,k);
mixGaussEst.mean = 2*randn(nDim,k);
for (cGauss =1:k)
    mixGaussEst.cov(:,:,cGauss) = (0.5+1.5*rand(1))*eye(nDim,nDim);
end;


nIter = 20;
for (cIter = 1:nIter)
    fprintf('Processing iteration %d\n',cIter);  
   %Expectation step
    l=zeros(nData,k);
    for (cData = 1:nData)
        thisData = data(:,cData);
        D=size(data,1);
        for (i=1:k)
            m=mixGaussEst.mean(:,i); 
            dcov=det(mixGaussEst.cov(:,:,i));
            l(cData,i)=1/sqrt((2*pi)^D*dcov)*exp(-0.5*(thisData-m)'*inv(mixGaussEst.cov(:,:,i))*(thisData-m))*mixGaussEst.weight(i);
        end
        postHidden(:,cData)= l(cData,:)'/sum(l(cData,:));
   end;
   
   %Maximization Step
   
   %for each constituent Gaussian
   for (cGauss = 1:k) 
        mixGaussEst.weight(cGauss) = sum(postHidden(cGauss,:))/sum(postHidden(:)); 
   
        mixGaussEst.mean(:,cGauss) = data*postHidden(cGauss,:)'/sum(postHidden(cGauss,:));
        
        C= postHidden(cGauss,:).*(data-mixGaussEst.mean(:,cGauss))*(data-mixGaussEst.mean(:,cGauss))';
        mixGaussEst.cov(:,:,cGauss) = C/sum(postHidden(cGauss,:));
   end;
   
end;


