load('index.mat');
for ii = 1:length(allArtists)
    artist = allArtists{ii};
    for jj = 1:length(artist)
       song = artist{jj};
       if exist(song.filepath) == 0
          fprintf(1, '%s does not exist\n', song.filepath); 
       end
    end
end