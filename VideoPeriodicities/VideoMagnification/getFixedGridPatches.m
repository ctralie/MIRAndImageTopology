function [PatchRegions] = getFixedGridPatches(getFrameFn, W, H)
    N = getFrameFn(-1);
    dims = size(getFrameFn(1));
    [X, Y] = meshgrid(1:W:dims(2), 1:H:dims(1));
    coords = [X(:) Y(:)];
    NPatches = size(coords, 1);
    PatchRegions = cell(1, NPatches);
    for ii = 1:NPatches
        range1 = coords(ii, 1):1:min(coords(ii, 1)+W-1, dims(2));
        range2 = coords(ii, 2):1:min(coords(ii, 2)+H-1, dims(1));
        [x, y] = meshgrid(range1, range2);
        ind = sub2ind(dims(1:2), y(:), x(:));
        PatchRegions{ii} = repmat(ind(:), [N, 1]);
    end
end