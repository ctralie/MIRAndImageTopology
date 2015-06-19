function [ V ] = convertVideo( filein, fileout, scale )
    if nargin < 3
        scale = 1;
    end
    obj = VideoReader(filein);
    N = obj.NumberOfFrames;
    
    I = read(obj, 1);
    dims = size(I);
    dims(1:2) = round(dims(1:2)/scale);
    
    writerObj = VideoWriter(fileout);
    open(writerObj);
        
    for ii = 1:N
        ii
        I = read(obj, ii);
        I = imresize(I, dims(1:2));
        writeVideo(writerObj,I);
    end
end

