%Add N points to P evenly sampled by arc length via linear interpolation
%This is a helper function to fake point to line in ICP
function [P2, t2, PArc] = addSamplesByArcLength( P, N )
    d = [0; sqrt(sum( (P(2:end, :) - P(1:end-1, :)).^2, 2) )];
    d = cumsum(d);
    d = d/d(end);
    t = linspace(0, 1, N+2);
    t = t(2:end-1);

    PArc = zeros(N, size(P, 2));
    idx = 1;
    for ii = 1:N
        while d(idx+1) < t(ii)
            idx = idx + 1;
        end
        t1 = d(idx);
        t2 = d(idx+1);
        PArc(ii, :) = ((t2 - t(ii))*P(idx, :) + (t(ii) - t1)*P(idx+1, :))/(t2-t1);
    end
    P2 = [P; PArc];
    t2 = [d(:); t(:)];
    [t2, idx] = sort(t2);
    P2 = P2(idx, :);
end