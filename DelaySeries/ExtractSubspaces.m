load('SubspaceClustering.mat');
filename = 'WangChung';
S = 0;
for ii = 1:8
    idx = idx00(group' == ii);
    [X, Fs] = getMusicParts( sprintf('%s.wma', filename), idx, 1024, 1, 1);
    if S == 0
       S = X;
    else
       S = S + X;
    end
    %audiowrite(sprintf('%s%i.ogg', filename, ii), X, Fs);
    %plot(X);
end