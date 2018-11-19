function Find_minus_ones(path_to_annotation)

load(path_to_annotation);
disp('Looking for -1s');
flag = 0;
for fnum = 1:numel(keys)
    tokens = regexp(keys{fnum},'_','split');
    if ismember(-1,elements{fnum}.segType)
        if (flag == 0)
            disp('Found -1 in:')
            flag = 1;
        end
        disp(keys{fnum});
        disp(['syllable locations: ' num2str(find(elements{fnum}.segType == -1))]);
    end
end