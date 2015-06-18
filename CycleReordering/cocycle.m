add%Wrapper around Dionysus code
%http://www.mrzv.org/software/dionysus/examples/cohomology.html
function [ output_args ] = cocycle( X, cutoff )
    dlmwrite('pointstemp.txt', X);
    command = sprintf('./rips-pairwise-cohomology pointstemp.txt -m %g -b pointstemp.bdry -c pointstemp -v pointstemp.vrt -d pointstemp.dgm', cutoff);
    fprintf(1, '%s\n', command);
    system(command);
    command = 'python cocycle.py pointstemp.bdry pointstemp-0.ccl pointstemp.vrt';
    system(command);
    %system('rm pointstemp*');
end

