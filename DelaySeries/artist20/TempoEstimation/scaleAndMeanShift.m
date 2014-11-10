function [Z] = scaleAndMeanShift( X )
    Y = bsxfun(@minus, mean(X), X);
    %Do what's done in the Sw1pers paper; normalize to sphere
    Norm = 1./(sqrt(sum(Y.*Y, 2)));
    Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
    
    Z = Y;
    
    %Uncomment below to do mean shift (buggy)
%     %And do mean shift
%     Z = zeros(size(Y));
%     Dots = Y*Y';
%     thresheps = cos(pi/32);
%     for kk = 1:size(Z, 1)
%         idx = Dots(kk, :) < thresheps;
%         Z(kk, :) = mean(Y(idx, :));
%     end
%     Norm = 1./(sqrt(sum(Z.*Z, 2)));    
%     Z = Z.*(repmat(Norm, [1 size(Z, 2)]));
%     
%     [~, pcaY] = pca(Y);
%     plot3(pcaY(:, 1), pcaY(:, 2), pcaY(:, 3), '.');
%     title('Before mean shift');
%     figure;
%     [~, pcaZ] = pca(Z);
%     plot3(pcaZ(:, 1), pcaZ(:, 2), pcaZ(:, 3), '.');
%     title('After mean shift');        
end

