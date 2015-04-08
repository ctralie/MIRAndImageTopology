%Implement point to point fractional RMSD ICP from P1 to P2, as described in 
%"Outlier Robust ICP for Minimizing Fractional RMSD" (2007): Phillips, Liu, Tomasi
function [ TFinal, P, iters, fs ] = FICP( P1, P2, lambda, MaxIter, DOPLOT )
    if nargin < 5
        DOPLOT = 0;
    end
    dim = size(P1, 2);
    
    %P1, P2 have points evenly spaced by arc length after this
    [~, ~, P1] = addSamplesByArcLength(P1, 2*size(P1, 1));
    [~, ~, P2] = addSamplesByArcLength(P2, 2*size(P2, 1));
    N1 = size(P1, 1);
    N2 = size(P2, 1);
    s1 = linspace(0, 1, N1);
    s2 = linspace(0, 1, N2);
    %Make initial correspondences based on relative arc lengths
    corresp = zeros(N1, 1);
    idx = 1;
    for ii = 1:N1
        while s2(idx+1) < s1(ii)
            idx = idx + 1;
        end
        if abs(s1(ii) - s2(idx)) < abs(s1(ii) - s2(idx+1))
            corresp(ii) = idx;
        else
            corresp(ii) = idx+1;
        end
    end
    
    if DOPLOT
        Colors = colormap(sprintf('jet(%i)', N2));
    end
    
    %Use a KD Tree to speed up nearest neighbor queries
    KDTree2 = KDTreeSearcher(P2);
    
    AllP = [P1; P2];
    xmin = min(AllP(:, 1)) - 0.5;
    xmax = max(AllP(:, 1)) + 0.5;
    ymin = min(AllP(:, 2)) - 0.5;
    ymax = max(AllP(:, 2)) + 0.5;
    iters = zeros(1, MaxIter);
    fs = zeros(1, MaxIter);
    fcoeffs = (N1./(1:N1)').^lambda;
    
    %Find the initial optimal fraction
    [dists, P1f] = sort(sum((P1 - P2(corresp, :)).^2, 2));
    RMSD = sqrt(cumsum(dists)./(1:N1)');
    [~, f] = min(RMSD.*fcoeffs);
    
    %Initial transformation is the identity
    TFinal = eye(dim+1);
    T = eye(dim+1);
    
    for iter = 1:MaxIter
        TFinal = TFinal*T;
        fs(iter) = f/N1;
        %Compute P1f, the subset of size f*N1 of P1 minimizing RMSD(P1f, P2, corresp)
        P1f = P1f(1:f);
        
        if DOPLOT
            clf;
            P = [P1 ones(N1, 1)];
            P = (T*P')';
            scatter(P(:, 1), P(:, 2), 20, Colors(corresp, :), 'fill');
            hold on;
            %scatter(P2(:, 1), P2(:, 2), 20, Colors, 'fill');
            plot(P2(:, 1), P2(:, 2), 'k.');
            xlim([xmin, xmax]);
            ylim([ymin, ymax]);
            title(sprintf('Iteration %i', iter));
            thisidx = 1:N1;
            thisidx(P1f) = 0;
            thisidx = thisidx(thisidx > 0);
            plot(P(thisidx, 1), P(thisidx, 2), 'x');
            for ff = 1:f
                plot([P(P1f(ff), 1), P2(corresp(P1f(ff)), 1)], [P(P1f(ff), 2), P2(corresp(P1f(ff)), 2)], 'g');
            end
            print('-dpng', '-r100', sprintf('%i.png', iter));
        end 
        
        %Compute the optimal transformation of this set of points with
        %their correspondences
        T = getRigidTransformation(P1(P1f, :), P2(corresp(P1f), :));
        
        %Compute the new correspondences given this transformation
        lastcorresp = corresp;
        P = [P1 ones(N1, 1)];
        P = (T*P')';
        %Transform the points to their updated locations and find the
        %new correspondences
        P1 = P(:, 1:dim);
        [corresp, dists] = KDTree2.knnsearch(P1, 'K', 1);
        if sum(corresp == lastcorresp) == N1
            %If it's converged
            break;
        end        
        
        %Compute the optimal fraction f given the correspondences
        [dists, P1f] = sort(dists.^2);
        RMSD = sqrt(cumsum(dists)./(1:N1)');
        [minval, f] = min(RMSD.*fcoeffs);        
        iters(iter) = minval;   
    end
    iters = iters(1:iter);
    P = P(:, 1:dim);
end

