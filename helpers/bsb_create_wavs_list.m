function wavs = bsb_create_wavs_list(DIR,first_file)
%% create the list of wav files to convert to matlab spectrograms
% Inputs:
%       DIR - the directory to work in
%       first_file  - the first file number
% Output:
%   wavs: the list of file names as struct.
cd(DIR);
FILES = dir('*.wav');
ord = [];
for i = 1:numel(FILES)
    tokens = regexp(FILES(i).name,'_','split');
    ord = [ord; str2num(tokens{2})];
end
[locs,indx] = sort(ord);
startloc = find(locs == first_file);
FILES = FILES(indx);
%%
wavs = {FILES(startloc:end).name};
