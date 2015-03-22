function [] = auralizeCurvature( MFCC, SampleDelays, outname )
    Fs = 44100;
    Delta = 5;
    Curv = getSongApproxCurvature(MFCC, Delta);
    %X = 2*(rand(1, round(Fs*max(SampleDelays))) - 0.5);
    X = sin(2*pi*440*(1:round(Fs*max(SampleDelays)))/Fs);
    Curv = (Curv - 1);
    Curv = Curv/0.08;
    Curv = min(Curv, 1);
    Curv = Curv.*(Curv > 0.1);
    for ii = 1:length(Curv)
        i1 = round(SampleDelays(ii+1)*Fs);
        i2 = round(SampleDelays(ii+2)*Fs);
        X(i1:i2) = X(i1:i2)*Curv(ii);
    end
    audiowrite(outname, X, Fs);
    plot(SampleDelays(1:length(Curv)), Curv);
end