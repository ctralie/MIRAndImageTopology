function [ Video ] = getDerivativeVideo( filename, outname, avgfac )
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    thisFrame = single(read(obj, 1));
    dims = size(thisFrame);
    lowdim = round(dims/avgfac);
    Video = zeros(N, prod(dims));
    for ii = 1:N
        ii
        thisFrame = single(read(obj, ii));
        for kk = 1:3
            thisFrame(:, :, kk) = imresize(imresize(thisFrame(:, :, kk), lowdim(1:2)), dims(1:2));
        end
        Video(ii, :) = thisFrame(:);
    end
    Video = getSmoothedDerivative(Video);
    Video = abs(reshape(Video, [size(Video, 1) dims(:)']));
    Q = quantile(Video(:), 0.998)
    Video = Video/Q;
    Video(Video > 1) = 1;
    
    writerObj = VideoWriter(outname);
    open(writerObj);
    for ii = 1:size(Video, 1)
        ii
        writeVideo(writerObj, squeeze(Video(ii, :, :, :)));
    end
end

