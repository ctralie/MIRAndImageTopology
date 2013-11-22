%http://stackoverflow.com/questions/6952315/how-to-load-arff-format-file-to-matlab
function [attributeNames, attributeTypes, nominalValues, data] = loadArffFile( filename )
    WEKA_HOME = 'C:\Program Files\Weka-3-6';
    javaaddpath([WEKA_HOME '\weka.jar']);
    import api.*;
    tda = Tda();
    %## read file
    loader = weka.core.converters.ArffLoader();
    loader.setFile( java.io.File(filename) );
    D = loader.getDataSet();
    D.setClassIndex( D.numAttributes()-1 );

    %## dataset
    relationName = char(D.relationName);
    numAttr = D.numAttributes;
    numInst = D.numInstances;

    %## attributes
    %# attribute names
    attributeNames = arrayfun(@(k) char(D.attribute(k).name), 0:numAttr-1, 'Uni',false);

    %# attribute types
    types = {'numeric' 'nominal' 'string' 'date' 'relational'};
    attributeTypes = arrayfun(@(k) D.attribute(k-1).type, 1:numAttr);
    attributeTypes = types(attributeTypes+1);

    %# nominal attribute values
    nominalValues = cell(numAttr,1);
    for i=1:numAttr
        if strcmpi(attributeTypes{i},'nominal')
            nominalValues{i} = arrayfun(@(k) char(D.attribute(i-1).value(k-1)), 1:D.attribute(i-1).numValues, 'Uni',false);
        end
    end
 
    %## instances
    data = zeros(numInst,numAttr);
    for i=1:numAttr
        data(:,i) = D.attributeToDoubleArray(i-1);
    end
end