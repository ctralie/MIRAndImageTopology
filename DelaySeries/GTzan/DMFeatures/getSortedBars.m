%Programmer: Chris Tralie
%Purpose: To return the sorted bar features for a persistence diagram

%Inputs:
%startbar: index of the bar to start in the sorted order
%endbar: index of the bar to end in the sorted order
function [fTDA] = getSortedBars( J, startbar, endbar)
    if size(J, 1) < endbar
        J = [J; zeros(endbar - size(J, 1), 2)]; 
    end
    [~, idx] = sort(J(:, 2) - J(:, 1), 'descend');
    J = J(idx, :);
    J = J(startbar:endbar, :);
    %[Birth time, Lifetime]
    %fTDA = [J(:, 1)' (J(:, 2) - J(:, 1))'];
    fTDA = [(J(:, 2) - J(:, 1))' J(:, 1)'];
    fTDA = fTDA(:);
end