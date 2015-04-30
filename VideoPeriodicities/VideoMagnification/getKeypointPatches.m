%Given face keypoints in a video with N frames and a set of K keypoints
%in "idx" with a patch half dimension "pdim", return an N x ((2*pdim+1)^2*K)
%array of pixel indices in time to embed
function [ PatchRegions ] = getKeypointPatches( Keypoints, IMSize, idx, pdim )
    K = length(idx);
    N = size(Keypoints, 1);
    PatchRegions = cell(1, K);
    for kk = 1:K
        PatchRegions{kk} = zeros(N, (2*pdim+1)^2);
        for ii = 1:N
            pos = int32(Keypoints(ii, idx(kk), :));
            pos = pos(2:-1:1); %X and Y are switched
            [I, J] = meshgrid(pos(1)-pdim:pos(1)+pdim, pos(2)-pdim:pos(2)+pdim);
            ind = sub2ind(IMSize, I(:), J(:));
            PatchRegions{kk}(ii, :) = ind(:);
        end
    end
end

