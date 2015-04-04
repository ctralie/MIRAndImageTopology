%Given face keypoints in a video with N frames and a set of K keypoints
%in "idx" with a patch half dimension "pdim", return an N x ((2*pdim+1)^2*K)
%array of pixel indices in time to embed
function [ AllIND ] = getKeypointPatches( Keypoints, IMSize, idx, pdim )
    K = length(idx);
    N = size(Keypoints, 1);
    AllIND = zeros(N, (2*pdim+1)*(2*pdim+1)*K);
    for ii = 1:N
        ind = [];
        for kk = 1:K
            pos = int32(Keypoints(ii, idx(kk), :));
            pos = pos(2:-1:1); %X and Y are switched
            [I, J] = meshgrid(pos(1)-pdim:pos(1)+pdim, pos(2)-pdim:pos(2)+pdim);
            ind = [ind; sub2ind(IMSize, I(:), J(:))];
        end
        AllIND(ii, :) = ind;
    end
end

