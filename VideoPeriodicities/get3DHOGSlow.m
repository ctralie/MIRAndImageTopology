function [ hogs ] = get3DHOGSlow( filename, W, H, L )
    if nargin < 2
        W = 12;
    end
    if nargin < 3
        H = 12;
    end
    if nargin < 4
        L = 6;
    end
    addpath('../TDAMex');
    
    %Setup the video reader object and figure out the dimensions of the
    %downsampled image
    obj = VideoReader(filename);
    N = obj.NumberOfFrames;
    hogs = [];
    fprintf(1, 'Doing 3DHOG on %i frames...\n', N);
    Frames = double(rgb2gray(read(obj, 1)));
    FrameWidth = size(Frames, 2);
    FrameHeight = size(Frames, 1);
    frameDx = W/6;
    frameDy = H/6;
    frameDz = L/6;
    FrameWidth = round(FrameWidth/frameDx);
    FrameHeight = round(FrameHeight/frameDy);
    Frames = {imresize(Frames, [FrameHeight, FrameWidth])};
    
    %Icosahedron face bins (I used dodecahedron vertices outputted by G-RFLCT)
    P = [   0 0.269672 0.706011
            0 -0.269672 0.706011
            0 0.269672 -0.706011
            0 -0.269672 -0.706011
            0.269672 0.706011 0
            -0.269672 0.706011 0
            0.269672 -0.706011 0
            -0.269672 -0.706011 0
            -0.706011 0 -0.269672
            -0.706011 0 0.269672
            0.706011 0 -0.269672
            0.706011 0 0.269672
            -0.436339 0.436339 0.436339
            -0.436339 -0.436339 0.436339
            0.436339 0.436339 0.436339
            0.436339 -0.436339 0.436339
            -0.436339 0.436339 -0.436339
            -0.436339 -0.436339 -0.436339
            0.436339 0.436339 -0.436339
            0.436339 -0.436339 -0.436339 ];
    P = P./repmat(sqrt(sum(P.*P, 2)), [1 3]);
    PDot = P*P(1, :)';
    thresh = max(PDot(2:end));%Threshold of nearest neighboring bin center
    
    for n = 2:N
        thisFrame = double(rgb2gray(read(obj, n)));
        Frames{end+1} = imresize(thisFrame, [FrameHeight, FrameWidth]);
        if length(Frames) < L
            continue; %Haven't gotten through enough frames yet
        end
        FramesMat = zeros(FrameHeight, FrameWidth, 6);
        %Down sample along z
        disp('Resampling z...');
        tic
        for z = 1:frameDz:L
           FramesChunk = reshape(cell2mat(Frames(z:z+frameDz-1)), [FrameHeight, FrameWidth, frameDz]);
           FramesMat(:, :, 1+(z-1)/frameDz) =  mean(FramesChunk, 3);
        end
        toc
        tic
        disp('Getting HOG Histograms...');
        this3Dhog = [];
        %Loop through the 2D offsets in the thickened slice
        for x = 1:6:FrameWidth-6
           for y = 1:6:FrameHeight-6
               hist = zeros(size(P, 1), 1);
               %Now compute gradients in 3x3x3 subsegments and bin each one
               for ii = [1, 3, 5]
                  thisx = x + ii;
                  for jj = [1, 3, 5]
                     thisy = y + jj;
                     for kk = [1, 3, 5]
                         hist = hist + getHOG3DHistogram(thisy, thisx, kk, FramesMat, P, thresh);
                     end
                  end
               end
               this3Dhog = [this3Dhog hist];
           end
        end
      	toc
        hogs(n, :) = this3Dhog(:);
        fprintf(1, '.');
        if mod(n, 50) == 0
           fprintf(1, '\n'); 
        end
        Frames = Frames(2:end);%Get rid of the oldest frame
    end
end

