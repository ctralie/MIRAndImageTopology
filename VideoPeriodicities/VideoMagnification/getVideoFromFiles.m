function [ V ] = getVideoFromFiles( foldername )
    files = dir([foldername, filesep, '*.png']);
    N = length(files);
    V = cell(1, N);
    for ii = 1:N
        V{ii} = single(imread(sprintf('%s/%i.png', foldername, ii)))/255.0;
    end
end

