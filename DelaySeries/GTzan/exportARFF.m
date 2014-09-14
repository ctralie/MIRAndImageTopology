function [] = exportARFF( filename, outfile, NPrC )
    if nargin < 3
        NPrC = 0;
    end
    dataset = load(filename);
    FeatureNames = {'MEAN43_Centroid';'MEAN43_Roloff';'MEAN43_Flux';'MEAN43_ZeroCrossings';'MEAN43_MFCC1';'MEAN43_MFCC2';'MEAN43_MFCC3';'MEAN43_MFCC4';'MEAN43_MFCC5';'MEAN43_MFCC6';'MEAN43_MFCC7';'MEAN43_MFCC8';'MEAN43_MFCC9';'MEAN43_MFCC10';'MEAN43_MFCC11';'MEAN43_MFCC12';'MEAN43_MFCC13';'MEAN43_Chroma_A';'MEAN43_Chroma_A#';'MEAN43_Chroma_B';'MEAN43_Chroma_C';'MEAN43_Chroma_C#';'MEAN43_Chroma_D';'MEAN43_Chroma_D#';'MEAN43_Chroma_E';'MEAN43_Chroma_F';'MEAN43_Chroma_F#';'MEAN43_Chroma_G';'MEAN43_Chroma_G#';'STD43_Centroid';'STD43_Roloff';'STD43_Flux';'STD43_ZeroCrossings';'STD43_MFCC1';'STD43_MFCC2';'STD43_MFCC3';'STD43_MFCC4';'STD43_MFCC5';'STD43_MFCC6';'STD43_MFCC7';'STD43_MFCC8';'STD43_MFCC9';'STD43_MFCC10';'STD43_MFCC11';'STD43_MFCC12';'STD43_MFCC13';'STD43_Chroma_A';'STD43_Chroma_A#';'STD43_Chroma_B';'STD43_Chroma_C';'STD43_Chroma_C#';'STD43_Chroma_D';'STD43_Chroma_D#';'STD43_Chroma_E';'STD43_Chroma_F';'STD43_Chroma_F#';'STD43_Chroma_G';'STD43_Chroma_G#';'ZeroEnergy'};
    fTDA = getSortedBars(dataset.AllPDs1, 1, 100, NPrC);
    fOrig = cell2mat(dataset.featuresOrig');
    fout = fopen(outfile, 'w');
    fprintf(fout, '@relation out.arff\n');
    for ii = 1:length(FeatureNames)
       fprintf(fout,  '@attribute Mean_%s real\n', FeatureNames{ii});
    end
    for ii = 1:length(FeatureNames)
       fprintf(fout,  '@attribute STD_%s real\n', FeatureNames{ii});
    end
    TDATypes = {'Timbral', 'MFCC', 'Chroma'};
    kTDA = size(fTDA, 2)/3;
    if NPrC == 0
        for kk = 1:3
            for ii = (1:kTDA/2) + (kk-1)*kTDA
               fprintf(fout, '@attribute DGM1_%s_Birth%i real\n', TDATypes{kk}, ii); 
            end
            for ii = (1:kTDA/2) + (kk-1)*kTDA + kTDA/2
               fprintf(fout, '@attribute DGM1_%s_Lifetime%i real\n', TDATypes{kk}, ii); 
            end
        end
    else
        for kk = 1:3
           for ii = (1:kTDA) + (kk-1)*kTDA
               fprintf(fout, '@attribute DGM1_%s_PCA%i real\n', TDATypes{kk}, ii);
           end
        end
    end
    genres = {'blues', 'classical', 'country', 'disco', 'hiphop', 'jazz', 'metal', 'pop', 'reggae', 'rock'};
    fprintf(fout, '@attribute genre{');
    for ii = 1:length(genres)
        fprintf(fout, '"%s"', genres{ii});
        if ii < length(genres)
            fprintf(fout, ',');
        end
    end
    fprintf(fout, '}\n\n\n');
    fprintf(fout, '@data\n');
    genreNum = 1;
    for ii = 1:size(fOrig, 1)
        for jj = 1:size(fOrig, 2)
           fprintf(fout, '%g,', fOrig(ii, jj)); 
        end
        for jj = 1:size(fTDA, 2)
           fprintf(fout, '%g,', fTDA(ii, jj)); 
        end
        fprintf(fout, '"%s"\n', genres{genreNum});
        if mod(ii, 100) == 0;
            genreNum = genreNum + 1;
        end
    end
    fclose(fout);
end