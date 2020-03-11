function t= threshold(img, T)
Z = 255.*img;
X = size(img,1);
Y = size(img,2);
t = zeros(X,Y);
for i = 1:X
    for j = 1:Y
        t(i,j) = (Z(i,j)>=T);
    end
end