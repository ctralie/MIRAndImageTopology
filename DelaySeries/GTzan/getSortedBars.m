%Programmer: Chris Tralie
%Purpose: To return the sorted bars

%Inputs:
%startbar: index of the bar to start in the sorted order
%endbar: index of the bar to end in the sorted order
function [fTDA] = getSortedBars( AllPDs, startbar, endbar )
    NBars = endbar - startbar + 1;
    N = length(AllPDs)*length(AllPDs{1});
    fTDA = zeros(N, 3*2*NBars);
    %fTDA = zeros(N, 3*NBars);
    index = 1;
    for ii = 1:length(AllPDs)
        for jj = 1:length(AllPDs{ii})
           for kk = 1:3
              J = AllPDs{ii}{jj}{kk};
              if size(J, 1) < endbar
                 J = [J; zeros(endbar - size(J, 1), 2)]; 
              end
              [~, idx] = sort(J(:, 2) - J(:, 1), 'descend');
              J = J(idx, :);
              J = J(startbar:endbar, :);
              %[Birth time, Lifetime]
              fTDA(index, (1:NBars*2) + (kk-1)*NBars*2) = ...
                  [J(:, 1)' (J(:, 2) - J(:, 1))'];
              %Lifetime only
              %fTDA(index, (1:NBars) + (kk-1)*NBars) = [J(:, 2) - J(:, 1)];
           end
           index = index + 1;
        end
    end
end