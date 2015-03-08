addpath('../SequenceAlignment');
OUTPUTIMAGES = 0;
OUTPUTIMAGESBINARY = 1;
load('AllDissimilarities8');
fhandle1 = fopen('CrossSimilarities/index.html', 'w');
fhandle2 = fopen('CrossSimilarities/indexbinary.html', 'w');
fprintf(fhandle1, '<html>\n<body>\n<table border = "1" cellpadding = "5">\n');
fprintf(fhandle2, '<html>\n<body>\n<table border = "1" cellpadding = "5">\n');

thresh = 0.02;
hist = load('BinarySimilarityHistL2.mat');
cdf = cumsum(hist.hist);
cutoff = hist.bins(find(cdf > thresh, 1));

fprintf(fhandle1, '<table border = "1">');
fprintf(fhandle2, '<table border = "1">');
for ii = 1:80
    fprintf(fhandle1, '<tr>');
    fprintf(fhandle2, '<tr>');
    for jj = 1:80
        fprintf(fhandle1, '<td><a href = "#%i_%i">(%i_%i)</a></td>', ii, jj, ii, jj);
        fprintf(fhandle2, '<td><a href = "#%i_%i">(%i_%i)</a></td>', ii, jj, ii, jj);
    end
    fprintf(fhandle1, '</tr>\n');
    fprintf(fhandle2, '</tr>\n');
end
fprintf(fhandle1, '</table><BR><BR>');
fprintf(fhandle2, '</table><BR><BR>');

fprintf(fhandle1, '<table border = "1">');
fprintf(fhandle2, '<table border = "1">');
for ii = 1:80
    fprintf(fhandle1, '<tr>');
    fprintf(fhandle2, '<tr>');
    for jj = 1:80
        if (ii == jj)
            fprintf(fhandle1, '<td bgcolor = "red">');
            fprintf(fhandle2, '<td bgcolor = "red">');
        else
            fprintf(fhandle1, '<td>');
            fprintf(fhandle2, '<td>');
        end
        fprintf(fhandle1, '<img src = "%i_%i.png"><a name = "%i_%i"></a></td>', ii, jj, ii, jj); 
        if OUTPUTIMAGES
            imagesc(Ms{ii, jj});
            axis equal;
            print('-dpng', '-r100', sprintf('CrossSimilarities/%i_%i.png', ii, jj));
        end
        if OUTPUTIMAGESBINARY
            M = double(Ms{ii, jj} < cutoff);      
            imagesc(M);
            axis equal;
            print('-dpng', '-r100', sprintf('CrossSimilarities/%i_%ib.png', ii, jj));
            [score, SAlign] = swalignimp(M);
            imagesc(SAlign(2:end, 2:end));
            axis equal;
            print('-dpng', '-r100', sprintf('CrossSimilarities/%i_%isw.png', ii, jj));
            fprintf(fhandle2, '<h2>%i</h2><img src = "%i_%ib.png"><BR><img src = "%i_%isw.png"><a name = "%i_%i"></a></td></td>', score, ii, jj, ii, jj, ii, jj); 
        end
    end
    fprintf(fhandle1, '</tr>\n');
    fprintf(fhandle2, '</tr>\n');
end
fclose(fhandle1);
fclose(fhandle2);