files = textread('a20-all-tracks.txt', '%s\n');
artistsMap = java.util.TreeMap();
artists = {};
%Create an ID map for the songs
for ii = 1:length(files)
    f = strsplit(files{ii}, '/');
    if isempty(artistsMap.get(f{1}))
        artistsMap.put(f{1}, artistsMap.size() + 1);
        idx = artistsMap.size();
        artists{idx} = f{1};
    end
end 
    
for ii = 1:length(artists)
    clf;
    plotLandscapeDict(ii);
    print('-dpng', '-r100', sprintf('%s.png', artists{ii}));
    fprintf(1, '<hr><BR><BR><h1>%s</h1><BR><img src = %s.png><BR><BR>\n', artists{ii}, artists{ii});
end