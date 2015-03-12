%Given a dissimilarity matrix D, do a sliding window of all patchdim x
%patchdim patches, and append two dimensions weighted with "posWeight" for
%their position in the dissimilarity matrix
%TODO: Include 1D distance from diagonal
function [ X ] = embedDissimilarityPatches( D, patchdim, posWeight )
    if nargin < 3
        posWeight = 0;%By default don't include position from diagonal
    end
    %Set up position images
    dim = size(D, 1);
    X = im2col(D, [patchdim patchdim], 'sliding');
    X = X';
    if (posWeight > 0)
        XPos = 1:size(X, 1);
        XPosv = floor((XPos-1)/(dim-patchdim+1))+1;
        XPosu = XPos - (XPosv-1)*(dim-patchdim+1);
        XPosu = XPosu/dim;
        XPosv = XPosv/dim;
        XPos = posWeight*[XPosu(:) XPosv(:)];
        X = [X XPos];
        %Account for the symmetry across the diagonal and delete the points
        %that are redundant
        X = X(XPosu >= XPosv, :);
    end
end