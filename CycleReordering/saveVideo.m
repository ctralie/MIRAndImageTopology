function [] = saveVideo( V, filename )
    writerObj = VideoWriter(filename);
    open(writerObj);
    for ii = 1:length(V)
        V{ii} = min(V{ii}, 1);
        V{ii} = max(V{ii}, 0);
        writeVideo(writerObj, V{ii});
    end
    close(writerObj);
end

