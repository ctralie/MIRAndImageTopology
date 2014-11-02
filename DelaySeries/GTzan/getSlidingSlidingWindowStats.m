function [ stats ] = getSlidingSlidingWindowStats( Is, nbars )
    stats = zeros(size(Is, 1), 2*nbars+1);
    for ii = 1:size(Is, 1)
        I = Is{ii};
        if ~isempty(I)
            [Lifetimes, idx] = sort(I(:, 2) - I(:, 1), 'descend');
            Birthtimes = I(idx, 1);
            N = min(nbars, length(idx));
            stats(ii, 1:N) = Lifetimes(1:N);
            stats(ii, nbars + (1:N)) = Birthtimes(1:N);%Birth times;
            stats(ii, end) = size(I, 1);%Number of bars
        end
    end
    stats = [mean(stats) std(stats)];
end