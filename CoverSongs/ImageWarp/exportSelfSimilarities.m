list1 = '../covers80/covers32k/list1.list';
list2 = '../covers80/covers32k/list2.list';
files1 = textread(list1, '%s\n');
files2 = textread(list2, '%s\n');

%load('AllDissimilarities8.mat');

for ii = 1:length(files1)
    D = Ms{ii, ii};
    songfilename1 = ['../covers80/covers32k/', files1{ii}, '22k.mp3'];
    songfilename2 = ['../covers80/covers32k/', files2{ii}, '22k.mp3'];
    Fs = 22050;
    beats1 = load(['../covers80/BeatsAndOggs/', files1{ii}, '.mat']);
    beats2 = load(['../covers80/BeatsAndOggs/', files2{ii}, '.mat']);
    SampleDelays1 = beats1.bts(1:2:end);
    SampleDelays2 = beats2.bts(1:2:end);
    strs = strsplit(files1{ii}, '/');
    s = strs{1};
    N = min(20, length(s));
    filename = ['CurvL2_8/', s(1:N), '.mat']
    save(filename, 'D', 'Fs', 'SampleDelays1', 'SampleDelays2', 'songfilename1', 'songfilename2');
end
