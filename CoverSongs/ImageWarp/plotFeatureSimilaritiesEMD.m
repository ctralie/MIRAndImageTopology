function [D] = plotFeatureSimilaritiesEMD( s1prefix, s2prefix, outname )
    addpath('../../');
    addpath('../EMD');
    feats1 = load(sprintf('ftrsgeom/%s_2.mat', s1prefix));
    feats2 = load(sprintf('ftrsgeom/%s_2.mat', s2prefix));

    %Point center and sphere-normalize point clouds
    for ii = 1:length(feats1.PointClouds)
        Y = feats1.PointClouds{ii};
        Y = bsxfun(@minus, mean(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        feats1.D{ii} = imresize(squareform(pdist(Y)), [20, 20]);
        feats1.D{ii} = feats1.D{ii}/sum(feats1.D{ii}(:));%Normalize for earth mover's
    end
    for ii = 1:length(feats2.PointClouds)
        Y = feats2.PointClouds{ii};
        Y = bsxfun(@minus, mean(Y), Y);
        Norm = 1./(sqrt(sum(Y.*Y, 2)));
        Y = Y.*(repmat(Norm, [1 size(Y, 2)]));
        feats2.D{ii} = imresize(squareform(pdist(Y)), [20, 20]);
        feats2.D{ii} = feats2.D{ii}/sum(feats2.D{ii}(:));
    end
 
    n = length(feats1.D);
    m = length(feats2.D);
    D = zeros(n, m);
    
    tic;
    parfor ii = 1:n
        disp(ii);
        row = zeros(1, m);
        for jj = 1:m
            row(jj) = getEarthMovers(feats1.D{ii}, feats2.D{jj});
        end
        D(ii, :) = row;
    end
    
    setpref('Internet', 'E_mail', 'labmailciemas3418@gmail.com');
    setpref('Internet', 'SMTP_Server', 'smtp.gmail.com');
    setpref('Internet', 'SMTP_Username', 'labmailciemas3418@gmail.com');
    setpref('Internet', 'SMTP_Password', 'r3yn0ldsL@b');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    sendmail('chris.tralie@gmail.com', sprintf('Finished EMD for %s, time %g sec', s1prefix, toc));    
    
    save(outname, 'D');
end