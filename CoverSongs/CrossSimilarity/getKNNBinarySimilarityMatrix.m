%R: Binary similarity matrix
%Rp: Binary similarity matrix median filtered along all diagonals
function [R, Rp, L] = getKNNBinarySimilarityMatrix( D, k, dw, DOPLOT )
    if nargin < 4
        DOPLOT = 0;
    end
    [~, idx] = sort(D);
    R = (idx <= k).*(idx' <= k);
    Rp = zeros(size(R, 1), size(R, 2), 2*dw+1);
    idx = 1;
    for w = -dw:dw
        xidx = 1:size(R, 1);
        xidx = xidx( (xidx + w >= 1) & (xidx + w <= length(xidx)) );
        yidx = 1:size(R, 1);
        yidx = yidx( (yidx + w >= 1) & (yidx + w <= length(yidx)) );
        if (w < 0)
            Rp(1:length(xidx), 1:length(yidx), idx) = R(xidx, yidx);
        else
            Rp(1+w:1+w+length(xidx)-1, 1+w:1+w+length(yidx)-1, idx) = R(xidx, yidx);
        end
        idx = idx + 1;
    end
    RpSum = sum(Rp, 3);
    Rp = mode(Rp, 3);
    
    %Compute graph laplacian
    A = Rp;
    A(1:size(A, 1)+1:end) = 1;
    Deg = A;
    DegDiag = (A > 0 | eye(size(A, 1))).*diag(sum(Deg, 1));
    %Uncomment for normalized
    DegSqrtInv = (A > 0 | eye(size(A, 1))).*diag(1./sqrt(sum(Deg, 1)));
    L = DegDiag - (DegSqrtInv)*A*(DegSqrtInv);
    %L = DegDiag - A;
    
    if DOPLOT
        subplot(2, 2, 1);
        imagesc(D);
        title('Dissimilarity Matrix');
        subplot(2, 2, 4);
        imagesc(RpSum);
        title('Recurrence Plot Sum Across Diagonals');
        subplot(2, 2, 3);
        imagesc(R);
        title(sprintf('Recurrence Plot (%i)', sum(R(:))));
        subplot(2, 2, 2);
        imagesc(Rp);
        title(sprintf('Diagonal Majority Vote Window Length %i (%i)', 2*dw+1, sum(Rp(:))));
    end
    
    
end

