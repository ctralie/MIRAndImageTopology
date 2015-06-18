%http://www.mathworks.com/help/optim/ug/travelling-salesman-problem.html?refresh=true
function [ order ] = doTSP( D, DEBUG )
    if nargin < 2
        DEBUG = 0;
    end
    %Step 1: Setup linear progrm
    N = size(D, 1);
    idxs = nchoosek(1:N, 2);
    dist = D(sub2ind([N, N], idxs(:, 1), idxs(:, 2)));
    lendist = length(dist);
    %There need to be N total "stops"
    Aeq = spones(1:length(idxs));
    beq = N;
    %There need to be two "trips" atached to each "stop"
    Aeq = [Aeq; spalloc(N, length(idxs), N*(N-1))];
    for ii = 1:N
        whichIdxs = (idxs == ii);
        whichIdxs = sparse(sum(whichIdxs, 2));
        Aeq(ii+1, :) = whichIdxs';
    end
    beq = [beq; 2*ones(N, 1)];
    intcon = 1:lendist;
    lb = zeros(lendist, 1);
    ub = ones(lendist, 1);
    opts = optimoptions('intlinprog','Display','off');
    
    %Step 2: Solve linear program, adding inequality constraints until
    %subtours are eliminated from found solution
    tic;
    [edges,costopt,exitflag,output] = intlinprog(dist,intcon,[],[],Aeq,beq,lb,ub,opts);
    toc;
    
    tours = detectSubtours(edges, idxs);
    A = spalloc(0, lendist, 0);
    b = [];
    while length(tours) > 1
        fprintf(1, '%i subtours\n', length(tours));
        b = [b; zeros(length(tours), 1)];
        A = [A; spalloc(length(tours), lendist, N)];
        for ii = 1:length(tours)
            rowIdx = size(A, 1)+1;
            variations = nchoosek(1:length(tours{ii}), 2);
            for jj = 1:length(variations)
                whichVar = (sum(idxs==tours{ii}(variations(jj,1)), 2)) & ...
                           (sum(idxs==tours{ii}(variations(jj,2)), 2));
                A(rowIdx, whichVar) = 1;
            end
            b(rowIdx) = length(tours{ii})-1;
        end
        tic;
        [edges,costopt,exitflag,output] = intlinprog(dist,intcon,A,b,Aeq,beq,lb,ub,opts);
        tours = detectSubtours(edges, idxs);
        toc;
    end
    order = tours{1};
    
    if DEBUG
        figure(2);
        Y = cmdscale(D);
        scatter3(Y(:, 1), Y(:, 2), Y(:, 3), 20, 'b', 'fill');
        hold on;
        Y = Y([order(:); order(1)], :);
        plot3(Y(:, 1), Y(:, 2), Y(:, 3), 'r');
    end
end