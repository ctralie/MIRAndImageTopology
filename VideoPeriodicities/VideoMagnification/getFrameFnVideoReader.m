%A wrapper around Matlab's video reader that allows a frame to be flipped
%in the Y direction (since I accidentally hold my ipod the wrong way
%sometimes)
function [ thisFrame ] = getFrameFnVideoReader( obj, ii, FlipY )
    if nargin < 3
        FlipY = 0;
    end
    if ii == -1
        thisFrame = obj.NumberOfFrames;
    else
        thisFrame = read(obj, ii);
        if FlipY
            dims = size(thisFrame);
            if length(dims) > 2
                for kk = 1:dims(3)
                    thisFrame(:, :, kk) = flipud(thisFrame(:, :, kk));
                end
            else
                thisFrame = flipud(thisFrame);
            end
        end
    end
end

