function [ JOut, JGeneratorsOut ] = getContinuousGenerators( J, JGenerators, varargin )
   tol = 0;
   if nargin > 2
      tol = varargin{1}; 
   end
   JOut = [];
   JGeneratorsOut = {};
   for ii = 1:length(JGenerators)
       if length(JGenerators{ii}) == 0
           continue;
       end
       gen = sort(JGenerators{ii});
       diff = gen(end) - gen(1);
       if diff <= length(gen) - 1 + tol;
          JGeneratorsOut{length(JGeneratorsOut)+1} = JGenerators{ii};
          JOut = [JOut; J(ii, :)];
       end
   end
end