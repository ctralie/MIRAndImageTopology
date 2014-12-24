A = zeros(5, 13);
for ii = 1:5
    A(ii, :) = mod(1+(ii-1)*3:7:1+(ii-1)*3+7*12, 12);
end
A(A == 0) = 12;

C = [];
for ii = 1:4
    for jj = 1:12
        minor = zeros(1, 12);
        major = zeros(1, 12);
        minor([A(ii, jj), A(ii+1, jj), A(ii, jj+1)]) = 1;
        major([A(ii+1, jj), A(ii+1, jj+1), A(ii, jj+1)]) = 1;
        C = [C; minor; major];
    end
end

%C = C + randn(size(C))*0.1;
%D = squareform(pdist(C));

%Hamming distance
D = zeros(size(C, 1), size(C, 1));
for ii = 1:size(D, 1)
    for jj = 1:size(D, 2)
        D(ii, jj) = sum(abs(C(ii, :) - C(jj, :)));
    end
end
D = D/2;

init;
I = rca1dm(D, 1e9);
subplot(2, 2, 1);
plotpersistencediagram(I);

[~, Y, latent] = pca(C);
subplot(2, 2, 2);
plot3(Y(:, 1), Y(:, 2), Y(:, 3), '.');

subplot(2, 2, 3);
imagesc(D);