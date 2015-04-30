function [ V ] = convertVideo( filein, fileout )
    obj = VideoReader(filein);
    N = obj.NumberOfFrames;
    
    writerObj = VideoWriter(fileout);
    open(writerObj);
        
    for ii = 1:N
        ii
        writeVideo(writerObj, read(obj, ii));
    end
end

