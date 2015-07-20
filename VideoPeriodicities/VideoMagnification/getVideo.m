function [ V ] = getVideo( filename, newdims )
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    V = cell(1, N);
    for ii = 1:N
        V{ii} = single(read(obj, ii))/255.0;
        if nargin > 1
            V{ii} = imresize(V{ii}, newdims);
        end
    end
end

