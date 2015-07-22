function [ VOut ] = amplifyPCs( V, VOut, I, PCs, alphas, DelayWindow )
    N = length(V);
    NI = size(I, 1);
    %Add back principal components with weights
    IProj = I*PCs;
    IProj = bsxfun(@times, alphas(:)', IProj);
    I = IProj*PCs';
    I = reshape(I', [DelayWindow, size(V{1}), size(I, 1)]);
    I = shiftdim(I, 1);
    
    newSize = size(VOut{1});
    %Each frame is the mean of the frame in all of the delay windows
    %that include it
    disp('Outputting amplified video...');
    for ii = 1:N
        ii
        F = zeros(size(V{1}));
        if ii - DelayWindow < 0
            %Not enough windows at beginning
            idxs = 1:ii;
            frameloc = ii:-1:1;
        elseif ii > NI
            %Not enough windows at end
            idxs = (ii-DelayWindow+1):NI;
            break;
            %TODO: Finish this
        else
            %Normal case: there are "DelayWindow" windows containing this frame
            idxs = (ii-DelayWindow+1):ii;
            frameloc = DelayWindow:-1:1;
        end
        for kk = 1:length(idxs)
            if length(size(F)) == 3
                F = F + I(:, :, :, idxs(kk), frameloc(kk));
            else
                F = F + I(:, :, idxs(kk), frameloc(kk));
            end
        end
        %Resize to larger image if it was downsized
        F = imresize(F/length(idxs), newSize(1:2));
        VOut{ii} = VOut{ii} + F;
    end
end

