function [ emd, F ] = histStatsEMD( W1, P1, W2, P2 )
% HISTSTATSEMD Computes Earth Movers' Distance on statistics
% W1: (n_1 x 1) vector of weights for n_1 points
% P1: (n_1 x d) matrix of positions for n_1 points in R^d
% W2: (n_2 x 1) vector of weights for n_2 points
% P2: (n_2 x d) matrix of positions for n_2 points in R^d
% emd: EMD objective function value
% F: (n_1 x n_2) pairwise EMD flow matrix
% @author Roger Zou
% @date 10/22/14

% compute pairwise distance matrix
D = pdist2(P1, P2);

% get sizes
[m,n] = size(D);

% EARTH MOVERS DISTANCE LP
% MIN WORK(P,Q,F) = sum_i sum_j d_{ij} f_{ij}
% subject to constraints:
% f{ij} \ge 0 forall i, j
% sum_j f_{ij} \le w_{pi} forall i
% sum_i f_{ij} \le w_{qj} forall j
% sum_i sum_j f_{ij} = min(sum_i w_{pi}, sum_j w_{qj})

% Generic LP: {min c^Tx | Ax \le B, x \ge 0}

% get c vector
c = D(:);
% clear D;

% get b vector
b = [W1; W2];

% get A (inequality) matrix
A1 = repmat(speye(m), 1,n);
A2 = false(n, m*n);
for j=1:n
    Jindices = false(m,n);
    Jindices(:,j) = 1;
    A2(j,:) = Jindices(:);
end
A = [A1; A2];
clear Jindices A1 A2;

% get all equality constraints (just one)
Aeq = ones(1, m*n);
beq = min(sum(W1(:)), sum(W2(:)));
lb = zeros(m*n, 1);
ub = [];

% compute LP
options = optimset('Display','none');
f = linprog(c, A, b, Aeq, beq, lb, ub, 0, options);

% output variables
F = reshape(f, m, n);
emd = F.*D;
emd = sum(emd(:));
