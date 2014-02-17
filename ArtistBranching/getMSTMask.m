function [DOut] = getMSTMask( D )
    N = size(D, 1);
    DOut = graphminspantree(sparse(D));
    DOut = full(DOut);
    DOut = DOut + DOut';%Make it symmetric just in case
    DOut(DOut > 0) = 1;
    DOut(eye(N) == 1) = 1;
end