function r=practicalMixGaussC

%The goal of this practical is to generate some data from an n-Dimensional
%mixtures of Gaussians model, and subsequently to fit an
%n-dimensional mixtures of Gaussians model to it to recover the original
%parameters

%You should use this template for your code and fill in the missing 
%sections marked "TO DO"

%close all open plots
close all;

%define true parameters for mixture of k Gaussians
%we will represent the mixtures of Gaussians as a Matlab structure
%in d dimenisions, the mean field
%will be a dxk matrix and the cov field will be a dxdxk matrix.
mixGaussTrue.k = 3;
mixGaussTrue.d = 2;
mixGaussTrue.weight = [0.1309 0.3966 0.4725];
mixGaussTrue.mean(:,1) = [ 4.0491 ; 4.8597];
mixGaussTrue.mean(:,2) = [ 7.7578 ; 1.6335];
mixGaussTrue.mean(:,3) = [11.9945 ; 8.9206];
mixGaussTrue.cov(:,:,1) = [  4.2534    0.4791;  0.4791    0.3522];
mixGaussTrue.cov(:,:,2) = [  0.9729    0.8723;  0.8723    2.6317];
mixGaussTrue.cov(:,:,3) = [  0.9886   -1.2244; -1.2244    3.0187];

%define number of samples to generate
nData = 400;

%generate data from the mixture of Gaussians
%TO DO - fill in this routine (below)
data = mixGaussGen(mixGaussTrue,nData);

%draw data, true Gaussians
figure;
drawEMData2d(data,mixGaussTrue);
drawnow;

%define number of components to estimate
nGaussEst = 3;

%fit mixture of Gaussians
%TO DO fill in this routine (below)
figure;
mixGaussEst = fitMixGauss(data,nGaussEst);




%==========================================================================
%==========================================================================

%the goal of this function is to generate data from a k-dimensional
%mixtures of Gaussians structure.
function data = mixGaussGen(mixGauss,nData);

%create space for output data
data = zeros(mixGauss.d,nData);
%for each data point
for (cData =1:nData)
    %randomly choose Gaussian according to probability distributions
    h = sampleFromDiscrete(mixGauss.weight);
    %draw a sample from the appropriate Gaussian distribution
    %first sample from the covariance matrix (google how to do this - it
    %will involve the Matlab command 'chol').  Then add the mean vector
    %TO DO (f)- replace this
    %data(:,cData) = mvnrnd(mixGauss.mean(:,h),mixGauss.cov(:,:,h));
    L = chol(mixGauss.cov(:,:,h));
    data(:,cData) = L*randn(2,1)+mixGauss.mean(:,h);
end;
    
%==========================================================================
%==========================================================================

function mixGaussEst = fitMixGauss(data,k);
        
[nDim nData] = size(data);

%MAIN E-M ROUTINE 
%there are nData data points, and there is a hidden variable associated
%with each.  If the hidden variable is 0 this indicates that the data was
%generated by the first Gaussian.  If the hidden variable is 1 then this
%indicates that the hidden variable was generated by the second Gaussian
%etc.

postHidden = zeros(k, nData);

%in the E-M algorithm, we calculate a complete posterior distribution over
%the (nData) hidden variables in the E-Step.  In the M-Step, we
%update the parameters of the Gaussians (mean, cov, w).  

%we will initialize the values to random values
mixGaussEst.d = nDim;
mixGaussEst.k = k;
mixGaussEst.weight = (1/k)*ones(1,k);
mixGaussEst.mean = 2*randn(nDim,k);
for (cGauss =1:k)
    mixGaussEst.cov(:,:,cGauss) = (0.5+1.5*rand(1))*eye(nDim,nDim);
end;

%calculate current likelihood
%TO DO - fill in this routine
logLike = getMixGaussLogLike(data,mixGaussEst);
fprintf('Log Likelihood Iter 0 : %4.3f\n',logLike);

nIter = 20;
for (cIter = 1:nIter)
   %Expectation step
   l=zeros(nData,k);
   for (cData = 1:nData)
        %TO DO (g): fill in column of 'hidden' - calculate posterior probability that
        %this data point came from each of the Gaussians
        %replace this:
        %postHidden(:,cData) = 1/k;
        thisData = data(:,cData);
        D=size(data,1);
        for (i=1:k)
            m=mixGaussEst.mean(:,i); 
            dcov=det(mixGaussEst.cov(:,:,i));
            l(cData,i)=mixGaussEst.weight(i)*1/sqrt((2*pi)^D*dcov)*...
                exp(-0.5*(thisData-m)'*inv(mixGaussEst.cov(:,:,i))*(thisData-m));
        end
        postHidden(:,cData)= l(cData,:)' / sum(l(cData,:));
        
        %pd = 0;
        %for (i = 1:k)
        %    pd = pd+calcGaussianProb(data(:,cData),mixGaussEst.mean(:,i),mixGaussEst.cov(:,:,i))*mixGaussEst.weight(i);
        %end
        %for (i = 1:k)
        %   pn = calcGaussianProb(data(:,cData),mixGaussEst.mean(:,i),mixGaussEst.cov(:,:,i))*mixGaussEst.weight(i);
        %    postHidden(i,cData) = pn/pd;
        %end
   end;
   
   %Maximization Step
   
   %for each constituent Gaussian
   for (cGauss = 1:k) 
        %TO DO (h):  Update weighting parameters mixGauss.weight based on the total
        %posterior probability associated with each Gaussian. Replace this:
        mixGaussEst.weight(cGauss) = sum(postHidden(cGauss,:))/sum(postHidden(:)); 
   
        %TO DO (i):  Update mean parameters mixGauss.mean by weighted average
        %where weights are given by posterior probability associated with
        %Gaussian.  Replace this:
        mixGaussEst.mean(:,cGauss) = data*postHidden(cGauss,:)'/sum(postHidden(cGauss,:));
        
        %TO DO (j):  Update covarance parameter based on weighted average of
        %square distance from update mean, where weights are given by
        %posterior probability associated with Gaussian
        %C = zeros(2);
        %for (i = 1:nData)
        %    C = C+ postHidden(cGauss,i)*(data(:,i)-mixGaussEst.mean(:,cGauss))*(data(:,i)-mixGaussEst.mean(:,cGauss))';
        %end
        C= postHidden(cGauss,:).*(data-mixGaussEst.mean(:,cGauss))*(data-mixGaussEst.mean(:,cGauss))';
        mixGaussEst.cov(:,:,cGauss) = C/sum(postHidden(cGauss,:));
   end;
   
   %draw the new solution
   drawEMData2d(data,mixGaussEst);drawnow;

   %calculate the log likelihood
   logLike = getMixGaussLogLike(data,mixGaussEst);
   fprintf('Log Likelihood Iter %d : %4.3f\n',cIter,logLike);

end;


%==========================================================================
%==========================================================================
function like = calcGaussianProb(data,gaussMean,gaussCov)
%multivariate normal distribution
like = 1/(sqrt((2*pi)^length(data)*det(gaussCov)))*...
    exp(-1/2*(data-gaussMean)'*inv(gaussCov)*(data-gaussMean)); 

%the goal of this routine is to calculate the log likelihood for the whole
%data set under a mixture of Gaussians model. We calculate the log as the
%likelihood will probably be a very small number that Matlab may not be
%able to represent.
function logLike = getMixGaussLogLike(data,mixGaussEst)

%find total number of data items
nData = size(data,2);

%initialize log likelihoods
logLike = 0;

%run through each data item
for (cData = 1:nData)
    thisData = data(:,cData);    
    %TO DO - calculate likelihood of this data point under mixture of
    %Gaussians model. Replace this
    like = 0;
    for (i=1:mixGaussEst.k)
        like = like+ calcGaussianProb(thisData,mixGaussEst.mean(:,i),mixGaussEst.cov(:,:,i))*mixGaussEst.weight(i);
    end
    
    %add to total log like
    logLike = logLike+log(like);  
end;




%==========================================================================
%==========================================================================

%The goal fo this routine is to draw the data in histogram form and plot
%the mixtures of Gaussian model on top of it.
function r = drawEMData2d(data,mixGauss)


set(gcf,'Color',[1 1 1]);
plot(data(1,:),data(2,:),'k.');

for (cGauss = 1:mixGauss.k)
    drawGaussianOutline(mixGauss.mean(:,cGauss),mixGauss.cov(:,:,cGauss),mixGauss.weight(cGauss));
    hold on;
end;
plot(data(1,:),data(2,:),'k.');
axis square;axis equal;
axis off;
hold off;drawnow;

   


%=================================================================== 
%===================================================================

%draw 2DGaussian
function r= drawGaussianOutline(m,s,w)

hold on;
angleInc = 0.1;

c = [0.9*(1-w) 0.9*(1-w) 0.9*(1-w)];


for (cAngle = 0:angleInc:2*pi)
    angle1 = cAngle;
    angle2 = cAngle+angleInc;
    [x1 y1] = getGaussian2SD(m,s,angle1);
    [x2 y2] = getGaussian2SD(m,s,angle2);
    plot([x1 x2],[y1 y2],'k-','LineWidth',2,'Color',c);
end

%===================================================================
%===================================================================

%find position of in xy co-ordinates at 2SD out for a certain angle
function [x,y]= getGaussian2SD(m,s,angle1)

if (size(s,2)==1)
    s = diag(s);
end;

vec = [cos(angle1) sin(angle1)];
factor = 4/(vec*inv(s)*vec');

x = cos(angle1) *sqrt(factor);
y = sin(angle1) *sqrt(factor);

x = x+m(1);
y = y+m(2);

%==========================================================================
%==========================================================================

%draws a random sample from a discrete probability distribution using a
%rejection sampling method
function r = sampleFromDiscrete(probDist);

nIndex = length(probDist);
while(1)
    %choose random index
    r=ceil(rand(1)*nIndex);
    %choose random height
    randHeight = rand(1);
    %if height is less than probability value at this point in the
    %histogram then select
    if (randHeight<probDist(r))
        break;
    end;
end;

