load('Landscapes1.mat');
load('CaseAgeGender.mat');

fout = fopen('out.arff', 'w');
fprintf(fout, '@relation out.arff\n');
L = Landscapes1{1};
for ii = 1:length(L(:))
    [y, x] = ind2sub(size(L), ii);
    fprintf(fout, '@attribute %i_%i real\n', x, y);
end
fprintf(fout, '@attribute gender {Male, Female}\n');
fprintf(fout, '\n@data\n');

for ii = 1:length(Landscapes1)
    fprintf(1, 'Writing %i\n', ii);
    L = Landscapes1{ii};
    L = L(:);
    for jj = 1:length(L)
        fprintf(fout, '%g, ', L(jj));
    end
    if Genders{ii} == 1
        fprintf(fout, 'Male\n');
    else
        fprintf(fout, 'Female\n');
    end
end

fclose(fout);