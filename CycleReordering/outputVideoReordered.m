function [] = outputVideoReordered( getFrameFn, idx, outname )
    writerObj = VideoWriter(outname);
    open(writerObj);
    for ii = 1:length(idx)
        fprintf(1, 'Outputting frame %i of %i\n', ii, length(idx));
        frame = getFrameFn(idx(ii));
    	writeVideo(writerObj, frame); 
    end
    close(writerObj);
end

