function [ VOut, IProj ] = amplifyPCs( V, VOut, I, PCs, alphas, DelayWindow, pixelloc )
    N = length(V);
    NI = size(I, 1);
    %Add back principal components with weights
    IProj = I*PCs;
    IProj = bsxfun(@times, alphas(:)', IProj);
    IProj = IProj*PCs';
    if nargin < 7
        %If using the entire video
        IProj = reshape(IProj', [DelayWindow, size(V{1}), size(IProj, 1)]);
        IProj = shiftdim(IProj, 1);
    else
        %If using a pixel subset (assume RGB)
        IProj = reshape(IProj', [DelayWindow, length(pixelloc), 3, size(I, 1)]);
        IProj = shiftdim(IProj, 1);
    end
    
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
            if nargin < 7
                %If using the entire video
                if length(size(F)) == 3
                    F = F + IProj(:, :, :, idxs(kk), frameloc(kk));
                else
                    F = F + IProj(:, :, idxs(kk), frameloc(kk));
                end
            else
                %If using a pixel subset (assume RGB)
                thisF = zeros(size(F, 1)*size(F, 2), 3);
                thisF(pixelloc, :) = IProj(:, :, idxs(kk), frameloc(kk));
                F = F + reshape(thisF, size(F));
            end
        end
        %Resize to larger image if it was downsized
        F = imresize(F/length(idxs), newSize(1:2));
        VOut{ii} = VOut{ii} + F;
    end
end

