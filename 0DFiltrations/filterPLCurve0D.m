%Do a filtration of a piecewise linear curve whose points are along the 
%rows of X and whose columns represent dimensions
%Do the filtration along direction U starting at the first point that
%is touched  by the corresponding swept hyperplane
function [I] = filterPLCurve0D( X, U )
    N = size(X, 1);
    filtDist = X*U;
    %Start at the first point touched by the swept hyperplane
    filtDist = filtDist - min(filtDist(:));
    V1 = [(1:N)'; (1:N-1)'];
    V2 = [(1:N)'; (2:N)'];
    D = max(filtDist(V1), filtDist(V2));
    [~, order] = sort(D);
    classes = zeros(1, N);
    classBirths = {};
    classDeaths = {};
    %Do the filtration
    for idx = 1:length(order)
        i = order(idx);
        if V1(i) == V2(i)%This is a point
            if classes(V1(i)) == 0
                %If the point hasn't been added yet
                %fprintf(1, 'Adding point %i\n', X(i));
                classBirths{end+1} = D(i);
                classDeaths{end+1} = -1;
                classes(V1(i)) = length(classBirths);
            end
        else
            if classes(V1(i)) == 0
                %If the point hasn't been added yet
                %fprintf(1, 'Adding point %i\n', X(i));
                classBirths{end+1} = D(i);
                classDeaths{end+1} = -1;
                classes(V1(i)) = length(classBirths);                
            end
            if classes(V2(i)) == 0
                %If the point hasn't been added yet
                %fprintf(1, 'Adding point %i\n', Y(i));
                classBirths{end+1} = D(i);
                classDeaths{end+1} = -1;
                classes(V2(i)) = length(classBirths);                
            end            
            %fprintf(1, 'Edge between %i and %i\n', X(i), Y(i));
            %Kill the most recently added class
            classToKill = max(classes(V1(i)), classes(V2(i)));
            classToKeep = min(classes(V1(i)), classes(V2(i)));
            classDeaths{classToKill} = D(i);
            classes(V1(i)) = classToKeep;
            classes(V2(i)) = classToKeep;
        end
    end
    I = zeros(length(classBirths), 2);
    for i = 1:size(I, 1)
       I(i, 1) = classBirths{i};
       I(i, 2) = classDeaths{i};
    end
    %Get rid of points that die instantly
    idx = I(:, 1) ~= I(:, 2);
    I = I(idx, :);
end