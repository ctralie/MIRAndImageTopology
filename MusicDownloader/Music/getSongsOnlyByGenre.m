function [songs] = getSongsOnlyByGenre( collectionFilename )
    songsIndex = load(collectionFilename);
    foundIndex = -1;
    songs = {};
    for ii = 1:size(songsIndex.genreStrings, 1)
        strlength = min(length(genreString), length(songsIndex.genreStrings(ii, :)));
        if strcmp(genreString(1:strlength), songsIndex.genreStrings(ii, 1:strlength)) == 1
            foundIndex = ii;
            break
        end
    end
    if foundIndex == -1
       disp('Error: Genre string not found');
       return;
    end
    for ii = 1:length(songsIndex.songsInfo)
       song = songsIndex.songsInfo{ii};
       if size(song.genres, 1) > 1
           continue;
       end
       if sum(song.genres == foundIndex) > 0
          songs{end+1} = song; 
       end
    end
    songs = songs';
end
