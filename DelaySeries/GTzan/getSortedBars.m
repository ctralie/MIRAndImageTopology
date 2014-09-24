%Programmer: Chris Tralie
%Purpose: To return the sorted bar features for a persistence diagram

%Inputs:
%startbar: index of the bar to start in the sorted order
%endbar: index of the bar to end in the sorted order
%birthtimes: 0 if lifetime only, 1 if lifetime and birthtime
function [fTDA] = getSortedBars( J, startbar, endbar, birthtimes)
    if size(J, 1) < endbar
        J = [J; zeros(endbar - size(J, 1), 2)]; 
    end
    [~, idx] = sort(J(:, 2) - J(:, 1), 'descend');
    J = J(idx, :);
    J = J(startbar:endbar, :);
    
    if birthtimes == 1
        fTDA = [(J(:, 2) - J(:, 1))' J(:, 1)'];
    else
        fTDA = J(:, 2) - J(:, 1); 
    end
    fTDA = fTDA(:);
end