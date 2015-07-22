%Output principal components
function [] = outputPCs( V, PCs, foldername, NPCs, DelayWindow, imsize )
    %Scale to range [0, 1] so they can be written as video
    PCs = PCs - min(PCs(:));
    PCs = PCs / max(PCs(:));
    mkdir(sprintf('%s/PCs', foldername));
    fout = fopen(sprintf('%s/PCs/index.html', foldername), 'w');
    fprintf(fout, '<html>\n<body>\n');
    for ii = 1:NPCs
        writerObj = VideoWriter(sprintf('%s/PCs/%i.avi', foldername, ii));
        open(writerObj);
        fprintf(fout, '<h1>PC %i</h1><BR><table><tr>', ii);
        for kk = 1:DelayWindow
            if length(size(V{1})) == 3
                frame = squeeze(PCs(:, :, :, ii, kk));
            else
                frame = squeeze(PCs(:, :, ii, kk));
            end
            if nargin > 5
                frame = imresize(frame, imsize);
            end
            writeVideo(writerObj, frame);
            imwrite(frame, sprintf('%s/PCs/%i_%i.png', foldername, ii, kk));
            fprintf(fout, '<td><img src = "%i_%i.png"></td>', ii, kk);
        end
        fprintf(fout, '</td></tr></table><BR><BR>\n\n');
        close(writerObj);
        system(sprintf(sprintf('avconv -i %s/PCs/%i.avi -b 30000k %s/PCs/%i.ogg ', ...
            foldername, ii, foldername, ii)));
        fprintf(fout, ['<video controls>'...
        sprintf('<source src="%i.ogg" type="video/ogg">', foldername, ii), ...
        'Your browser does not support the video tag.</video>']);
    end
    fclose(fout);
end

