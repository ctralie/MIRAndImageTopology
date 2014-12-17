%Inputs:
%f: A 1xN cell array of frequencies
%TLs: A 1x(2N-1) vector of time length, where the odd indices k hold the
%length to hold at frequencies f{k} and even frequencies are times in
%between
%dt: Sampling interval
%T: Window Size
%doPhase: Include real/imaginary (2x length of magnitude)

%Outputs:
%x: The time series
%Y: The window embedding
function [x, Y] = getTransientSpecEmbedding( fs, TLs, dt, T, doPhase )
    if nargin < 5
        doPhase = 0;
    end
    x = [];
    t = 0;%Keeps track of where the sequence is in time
    for ii = 1:length(fs)
        TL1 = TLs(ii*2-1);
        L1 = round(TL1/dt);
        f0 = fs{ii};
        
        %Beginning
        f0 = repmat(f0(:), [1 L1]);
        t0 = t:dt:t+TL1-dt;
        t0 = repmat(t0(:)', [size(f0, 1), 1]);
        x0 = sum(cos(2*pi*t0.*f0), 1);
        t = t + TL1;
        
        if ii < length(fs)
            %Transient
            TLTrans = TLs(ii*2);
            tt = t:dt:t+TLTrans-dt;
            
            LTrans = round(TLTrans/dt);
            f1 = fs{ii+1};
            f0 = repmat(f0(:, 1), [1, LTrans]);
            f1 = repmat(f1(:), [1, LTrans]);
            
            tt = repmat(tt(:)', [size(f0, 1), 1]);
            transFac = (0:LTrans-1)/LTrans;
            transFac = repmat(transFac(:)', [size(f0, 1), 1]);

            %Old frequencies
            xtrans = sum(cos(2*pi*tt.*f0).*(1-transFac), 1);%Linear blend
            %New frequencies
            tt = repmat(tt(1, :), [size(f1, 1), 1]);
            transFac = repmat(transFac(1, :), [size(f1, 1), 1]);
            xtrans = xtrans + sum(cos(2*pi*tt.*f1).*transFac, 1);
            x = [x x0 xtrans];
            t = t + TLTrans;
        else
            x = [x x0];
        end
    end
    W = round(T/dt);%How many samples per window
    N = length(x) - W + 1;
    Y = zeros(N, W*2);
    if doPhase == 0
        Y = zeros(N, W);
    end
    for ii = 1:N
        winfft = fft(x(ii:ii+W-1));
        if doPhase
            Y(ii, 1:W) = real(winfft);
            Y(ii, W+1:end) = imag(winfft);
        else
            Y(ii, :) = abs(winfft);
        end
    end
end