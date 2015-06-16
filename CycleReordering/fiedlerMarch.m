%Inputs: Point Cloud (Y), K nearest neighbors, DEBUG (whether or not to
%show the marching as it's happening)
%Outputs: fiedler vector, extracted path, sparse adjacency matrix
function [ fiedler, path, A ] = fiedlerMarch( Y, K, DEBUG )
    %Step 1: Build mutual nearest neighbor graph and make laplacian
    DMetric = squareform(pdist(Y));
    [~, ~, A] = getKNN(DMetric, K);
    %A = A.*DMetric;
    D = sum(A, 2);
    L = spdiags(D, 0, speye(size(A, 1)))-A;

    [E, ~] = eigs(L, 2, 'sm');
    fiedler = E(:, end-1); %Fiedler vector

    %Step 2: Use fiedler vector to traverse the graph
    visited = zeros(1, length(fiedler));
    path = ones(1, length(fiedler));
    path(1) = 1;
    visited(1) = 1;
    if DEBUG
        [~, Z] = pca(Y);
        Z = Z(:, 1:3);
        C = colormap(sprintf('jet(%i)', size(Z, 1)));
        scatter3(Z(path, 1), Z(path, 2), Z(path, 3), 20, C, 'fill');
        [~, fidx] = sort(fiedler);
    end
    for ii = 2:length(fiedler)
        if DEBUG
            clf;
            scatter(Z(fidx, 1), Z(fidx, 2), 20, C, 'fill');
            hold on;
            scatter(Z(path(1:ii-1), 1), Z(path(1:ii-1), 2), 60, 'k', 'x');
            scatter(Z(path(ii-1), 1), Z(path(ii-1), 2), 80, 'k', 'fill');
            %Plot neighbor lines
            for jj = find(A(path(ii-1), :))
                P = [Z(path(ii-1), :); Z(jj, :)];
                plot(P(:, 1), P(:, 2), 'r', 'LineWidth', 2);
                scatter(Z(jj, 1), Z(jj, 2), 70, 'k', 'o');
            end
            %Plot path lines
            for kk = 1:ii-2
                for jj = find(A(path(kk), :))
                    P = [Z(path(kk), :); Z(jj, :)];
                    plot(P(:, 1), P(:, 2), 'b');
                end
            end
    %Uncomment to zoom
    %         z = Z(path(ii-1), :);
    %         xlim([min(z(:, 1)) - 0.4, max(z(:, 1)) + 0.4]);
    %         ylim([min(z(:, 2)) - 0.4, max(z(:, 2)) + 0.4]);
        end

        neighbs = find(A(path(ii-1), :));
        neighbs = neighbs(visited(neighbs) == 0);
        if isempty(neighbs)
            fprintf(1, 'Stopped at %i\n', ii);
            break;
        end
        dists = abs(fiedler(neighbs) - fiedler(ii-1));
        [~, minidx] = min(dists);
        path(ii) = neighbs(minidx);
        visited(neighbs(minidx)) = 1;

        if DEBUG
            scatter(Z(path(ii), 1), Z(path(ii), 2), 70, 'b', 'fill');
            print('-dpng', '-r100', sprintf('%i.png', ii));
        end
    end
end

