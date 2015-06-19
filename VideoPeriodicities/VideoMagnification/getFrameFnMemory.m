function [thisFrame] = getFrameFnMemory(V, N, ii)
    if ii == -1
        thisFrame = N;
    else
    	if iscell(V)
    		thisFrame = V{ii};
    	else
    		thisFrame = squeeze(V(ii, :, :, :));
    	end
    end
end
