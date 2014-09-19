function [I] = get0DPersistence( D )
    dim = size(D, 1);
    [X, Y] = meshgrid(1:dim, 1:dim);
    D = D(:);
    X = X(:);
    Y = Y(:);
    classes = zeros(1, dim);
    [~, order] = sort(D);%Add points/edges in ascending order
    classBirths = {};
    classDeaths = {};
    for idx = 1:length(order)
        i = order(idx);
        if X(i) == Y(i)%This is a point
            if classes(X(i)) == 0
                %If the point hasn't been added yet
                %fprintf(1, 'Adding point %i\n', X(i));
                classBirths{length(classBirths)+1} = D(i);
                classDeaths{length(classBirths)+1} = -1;
                classes(X(i)) = length(classBirths);
            end
        else
            if (X(i) < Y(i))
                continue
            end
            if classes(X(i)) == 0
                %If the point hasn't been added yet
                %fprintf(1, 'Adding point %i\n', X(i));
                classBirths{length(classBirths)+1} = D(i);
                classDeaths{length(classBirths)+1} = -1;
                classes(X(i)) = length(classBirths);                
            end
            if classes(Y(i)) == 0
                %If the point hasn't been added yet
                %fprintf(1, 'Adding point %i\n', Y(i));
                classBirths{length(classBirths)+1} = D(i);
                classDeaths{length(classBirths)+1} = -1;
                classes(Y(i)) = length(classBirths);                
            end            
            %fprintf(1, 'Edge between %i and %i\n', X(i), Y(i));
            %Kill the most recently added class
            classToKill = max(classes(X(i)), classes(Y(i)));
            classToKeep = min(classes(X(i)), classes(Y(i)));
            classDeaths{classToKill} = D(i);
            classes(X(i)) = classToKeep;
            classes(Y(i)) = classToKeep;
        end
    end
    I = zeros(length(classBirths), 2);
    for i = 1:size(I, 1)
       I(i, 1) = classBirths{i};
       I(i, 2) = classDeaths{i};
    end
end

