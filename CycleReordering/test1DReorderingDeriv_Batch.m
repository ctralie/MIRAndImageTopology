AUTOMATED = 1;

windowLens = [3, 5, 9, 11];
SamplesPerPeriods = [5, 10, 20];
NPeriodss = [20, 50];
Sines = {};
%Sines{end+1} = [1 1 0.5];
Sines{end+1} = [1 1 0.5; 0.5 1.5 0.3];
%Sines{end+1} = [1 1 0.5; 0.5 1.5 0.3; 0.8 2 0];

[i1, i2, i3, i4] = ndgrid(1:length(windowLens), 1:length(SamplesPerPeriods), 1:length(NPeriodss), 1:length(Sines));
I = [i1(:), i2(:), i3(:), i4(:)];

fout = fopen('1DReorderingDeriv/index.html', 'w');
fprintf(fout, '<html><body><BR>\n');
NSinesLast = size(Sines{1}, 1);
fprintf(fout, '<h1>%i Sines</h1><BR>\n', NSinesLast);
for batch = 1:size(I, 1)
    mfp = Sines{I(batch, 4)};
    windowLen = windowLens(I(batch, 1));
    SamplesPerPeriod = SamplesPerPeriods(I(batch, 2));
    NPeriods = NPeriodss(I(batch, 3));
    filename = sprintf('%iSines%iTaps%iSamples%iPeriods.png', ...
        size(mfp, 1), windowLen, SamplesPerPeriod, NPeriods);
    set(gcf,'PaperUnits','inches','PaperPosition',[0 0 8 3]);
    test1DReorderingDeriv;
    print('-dpng', sprintf('1DReorderingDeriv/%s', filename));
    fprintf(fout, '<BR><img src = "%s">\n', filename);
    NSines = size(mfp, 1);
    if NSinesLast ~= NSines
        fprintf(fout, '<BR><BR><HR>%i<BR><BR>\n', NSines);
    end
    NSinesLast = NSines;
end
fprintf(fout, '</body></html>');
fclose(fout);