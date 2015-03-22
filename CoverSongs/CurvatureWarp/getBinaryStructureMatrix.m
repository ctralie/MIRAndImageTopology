function [ DOut ] = getBinaryStructureMatrix( D, NNeighbs )
    [~, idx] = sort(D);
    DOut = (idx < NNeighbs).*(idx' < NNeighbs);
end