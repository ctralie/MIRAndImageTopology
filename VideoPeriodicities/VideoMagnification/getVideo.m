function [ V ] = getVideo( filename )
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    V = cell(1, N);
    for ii = 1:N
        V{ii} = single(read(obj, ii));
    end
end

