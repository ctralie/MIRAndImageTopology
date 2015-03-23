list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';

files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');
N = length(files1);
K = 8;
beatDownsample = 2;

Ds = cell(N, 1);
for K = [4, 8, 16]
    for dim = [100, 200]
        for BeatsPerWin = [1, 2, 4, 8, 16]
            filename = sprintf('SongDicts_%i_%i_%i.mat', K, dim, BeatsPerWin);
            if exist(filename)
                continue;
            end
            fprintf(1, 'Training dictionary K = %i, dim = %i, BeatsPerWin = %i\n', K, dim, BeatsPerWin);
            parfor ii = 1:N
                fprintf(1, 'Doing %s\n', files1{ii});
                Ds{ii} = getDictionary(files1{ii}, K, dim, BeatsPerWin, beatDownsample);
            end
            save(filename, 'Ds');
        end
    end
    setpref('Internet', 'E_mail', 'labmailciemas3418@gmail.com');
    setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
    setpref('Internet', 'SMTP_Username', 'labmailciemas3418@gmail.com');
    setpref('Internet', 'SMTP_Password', 'r3yn0ldsL@b');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    sendmail('chris.tralie@gmail.com', sprintf('Finished %i', K));    
end