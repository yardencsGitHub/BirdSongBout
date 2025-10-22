function [DATA, syllables, file_numbers, file_day_indices, song_durations, file_date_times, song_start_offests, phrase_start_times, phrase_end_times] = bsb_convert_annotation_to_pst(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,include_zero,min_phrases,varargin)
% This script takes an annotation file and the required DATA structure to
% run Jeff Markowitz's PST
%
% Inputs:
%   path_to_annotation_file - Full or relative
%   ignore_dates - days of data to be ignored.
%   ignore_entries - A vector of label numbers to ignore completely. 
%   join_entries - A cell of vectors, each containing a >1 number of labels
%   to treat as belonging to the same state. The lists shouldn't overlap
%   (incl. with the ignored lables)
%   include_zero - should 0 be a label?
%
% Optional inputs (Name, Value pairs):
% onset_sym, offset_sym (one character string, e.g. '[') 
%  A character to add to the beginning and end of phrase sequences.
%  It should not be one of the Alphanumeric characters 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz'
%  Those are reserved for syllable types.
% orig_syls (vector of integers): tags of syllables to assign to the
% alphsnumeric labels. This is used if some syllable classes may be missing
% and we don't want to reassign characters to syllable types (e.g. in case
% of looking at subsets of the data.
% MaxSep, MaxSyllableSep (double) - time in sec to use for decision on
% separating songs or phrases because of a time gap larger than those values.
% edge_gap and wav_files_path (double and string) - Set 'edge_gap' to a
% value larger than 0 to discard songs that start or end too close to the
% edge of the recording file. 'wav_files_path' indicates the full path to
% the WAV files to get their durations.
%
% Output:
%   DATA - a cell array of strings
%   syllables - vector of all syllable numbers 
%   file_numbers - vector, indices in the annotation data of all entries in DATA    
%   file_day_indices - vector, indices of recording days for all entries in DATA 
%   song_durations - vector, durations (in seconds) of all entries in DATA  
%   file_date_times - vector, datetime variables for all entries in DATA     
%   song_start_offests - vector, the start time (in seconds) for all
%   entries in DATA relative to the recording file onset (not the song
%   onset since there can be more than one song per file)

onset_sym = '1';
offset_sym = '2';
orig_syls = [];
MaxSep = 0.5; % maximal inter-phrase separation within a bout (sec). 
% Larger inter-phrase separation will break the bout into different songs.
MaxSyllableSep = 0.5; % maximal inter-syllable separation within a phrase (sec) 
% Larger within-phrase inter-syllable separation will break the phrase into
% different phrases
edge_gap = 0; % minimal time gap (in sec) from the edge of file 
% (onset or offset) that is allowed for a song. Songs that are closer than
% this value will be discarded. Default is 0 which means no song
% discarding. If using this option then also set 'wav_files_path' to
% indicate where the WAV files are located to find the file durations.
wav_files_path = '';

nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
		case 'maxsep'
			MaxSep=varargin{i+1};
        case 'maxsyllablesep'
			MaxSyllableSep=varargin{i+1};
        case 'onset_sym'
            onset_sym = varargin{i+1};
        case 'offset_sym'
            offset_sym = varargin{i+1};
        case 'syllables'
            orig_syls = varargin{i+1};
        case 'edge_gap'
            edge_gap = varargin{i+1};
        case 'wav_files_path'
            wav_files_path = varargin{i+1};
    end
end

AlphaNumeric = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';

if ~exist(path_to_annotation_file)
    DATA = [];
    phrase_start_times = []; 
    phrase_end_times = [];
    file_numbers = [];
    display(['Could not open annotation file: ' path_to_annotation_file])
    return;
end

flag = 0;
join_entries = join_entries(:);
if ~isempty(join_entries)
    for i = 1:numel(join_entries)
        if ~isempty(intersect(join_entries{i},ignore_entries))
            flag = 1;
        end
        for j = i+1:numel(join_entries)
            if  ~isempty(intersect(join_entries{i},join_entries{j}))
                flag = 1;
            end
        end
    end
end
   
if flag == 1
    resmat = [];
    state_labels = [];
    disp(['join or ignore lists overlap'])
    return;
end
    
load(path_to_annotation_file);

DATA = {};
file_numbers = [];
phrase_start_times = {}; 
phrase_end_times = {};
if isempty(orig_syls)
    syllables = [];
    for fnum = 1:numel(keys)  
        syllables = unique([syllables unique(elements{fnum}.segType)']);
    end
    syllables = setdiff(syllables,ignore_entries);
    if (include_zero == 0)
        syllables = setdiff(syllables,0);
    end
    for i = 1:numel(join_entries)
        syllables = setdiff(syllables,join_entries{i}(2:end));
    end
else
    syllables = orig_syls;
end
edge_syms = [];
if ~isempty(onset_sym) 
    edge_syms = [-1000];
end
if ~isempty(offset_sym) 
    edge_syms = [edge_syms 1000];
end

syllables = [edge_syms syllables];
AlphaNumeric = [onset_sym offset_sym AlphaNumeric];

actual_syllables = [];
file_date_nums = [];
song_durations = [];
file_date_times = [];
song_start_offests = [];
for fnum = 1:numel(keys)
    curr_date_num = return_date_num(keys{fnum});
    if ~isempty(ignore_dates)
        if ismember(return_date_num(keys{fnum}),datenum(ignore_dates))
            '4';
            continue;
        end
    end
    element = elements{fnum};
    locs = find(ismember(element.segType,ignore_entries));
    try 
        element.segAbsStartTimes(locs) = [];
    catch em
        'This field may not exist in some annotation files';
    end
    element.segFileStartTimes(locs) = [];
    element.segFileEndTimes(locs) = [];
    element.segType(locs) = [];  
    for i = 1:numel(join_entries)
        locs = find(ismember(element.segType,join_entries{i}));
        element.segType(locs) = join_entries{i}(1);
    end
    
    try
        phrases = bsb_return_phrase_times(element,'max_separation',MaxSyllableSep);

        if edge_gap > 0.001
            file_duration = audioinfo(fullfile(wav_files_path,keys{fnum})).Duration;
        else
            file_duration = 1000;
        end
        
        currDATA = [AlphaNumeric(syllables == phrases.phraseType(1))];
        curr_phrase_start_times = [phrases.phraseFileStartTimes(1)]; 
        curr_phrase_end_times = [phrases.phraseFileEndTimes(1)];
        currsyls = [-1000 phrases.phraseType(1)];
        curr_song_onset = phrases.phraseFileStartTimes(1);
        curr_song_datetime = get_date_from_file_name(keys{fnum});
        for phrasenum = 1:numel(phrases.phraseType)-1
            if (phrases.phraseFileStartTimes(phrasenum + 1) -  phrases.phraseFileEndTimes(phrasenum) <= MaxSep)
                currDATA = [currDATA AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1))];
                curr_phrase_start_times = [curr_phrase_start_times phrases.phraseFileStartTimes(phrasenum + 1)]; 
                curr_phrase_end_times = [curr_phrase_end_times phrases.phraseFileEndTimes(phrasenum + 1)];
                currsyls = [currsyls phrases.phraseType(phrasenum + 1)];
            else
                if (numel(currDATA) >= min_phrases) && ...
                        (edge_gap < 0.001 || (curr_song_onset > edge_gap && curr_phrase_end_times(end) < (file_duration - edge_gap)))
                    DATA = {DATA{:} [onset_sym currDATA offset_sym]};
                    phrase_start_times = {phrase_start_times{:} curr_phrase_start_times}; 
                    phrase_end_times = {phrase_end_times{:} curr_phrase_end_times};
                    file_numbers = [file_numbers fnum];
                    file_date_nums = [file_date_nums; curr_date_num];
                    actual_syllables = unique(union(actual_syllables,unique([currsyls 1000])));
                    song_durations = [song_durations phrases.phraseFileEndTimes(phrasenum) - curr_song_onset];
                    file_date_times = [file_date_times curr_song_datetime];
                    song_start_offests = [song_start_offests curr_song_onset];
                end
                currDATA = [AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1))];
                curr_phrase_start_times = [phrases.phraseFileStartTimes(phrasenum + 1)]; 
                curr_phrase_end_times = [phrases.phraseFileEndTimes(phrasenum + 1)];
                currsyls = [-1000 phrases.phraseType(phrasenum + 1)];
                curr_song_onset = phrases.phraseFileStartTimes(phrasenum + 1);
            end  
        end
        if (numel(currDATA) >= min_phrases) && ...
                        (edge_gap < 0.001 || (curr_song_onset > edge_gap && curr_phrase_end_times(end) < (file_duration - edge_gap)))
            DATA = {DATA{:} [onset_sym currDATA offset_sym]};
            phrase_start_times = {phrase_start_times{:} curr_phrase_start_times}; 
            phrase_end_times = {phrase_end_times{:} curr_phrase_end_times};
            file_numbers = [file_numbers fnum];
            file_date_nums = [file_date_nums; curr_date_num];
            actual_syllables = unique(union(actual_syllables,unique([currsyls 1000])));
            song_durations = [song_durations phrases.phraseFileEndTimes(end) - curr_song_onset];
            file_date_times = [file_date_times curr_song_datetime];
            song_start_offests = [song_start_offests curr_song_onset];
        end
    catch em
        '8';
    end
end
actual_syllables = unique(actual_syllables);
no_show_syllables = setdiff(syllables,actual_syllables);
syllables(ismember(syllables,no_show_syllables)) = [];
unique_file_date_nums = unique(file_date_nums);
file_day_indices = [];
for fnum = 1:numel(file_date_nums)
    file_day_indices = [file_day_indices; find(unique_file_date_nums == file_date_nums(fnum))];
end
end
function res = return_date_num(filestr)
    tokens = regexp(filestr,'_','split');
    res = datenum(char(join(tokens(3:5),'_')));
end

function d = get_date_from_file_name(filename,varargin)
    d='';
    sep = '_';
    date_idx = 3:8;
    return_datetime = 1;
    nparams = numel(varargin);
    for i=1:2:nparams
        switch lower(varargin{i})
            case 'sep'
			    sep=varargin{i+1};
            case 'date_idx'
			    date_idx=varargin{i+1};
            case 'return_datetime'
			    return_datetime=varargin{i+1};
        end
    end
    tokens = split(filename,sep);
    last_string = split(tokens{date_idx(6)},'.');
    last_string = last_string{1};
    if return_datetime == 1
        switch length(date_idx)
            case 6
                d = datetime(str2num(tokens{date_idx(1)}),...
                    str2num(tokens{date_idx(2)}),...
                    str2num(tokens{date_idx(3)}),...
                    str2num(tokens{date_idx(4)}),...
                    str2num(tokens{date_idx(5)}),...
                    str2num(last_string));
            case 5
                d = datetime(str2num(tokens{date_idx(1)}),...
                    str2num(tokens{date_idx(2)}),...
                    str2num(tokens{date_idx(3)}),...
                    str2num(tokens{date_idx(4)}),...
                    str2num(last_string),...
                    str2num(00));
            otherwise
                disp('Error in date format');
                d = 0;
        end
    else
        d = char(join(tokens(date_idx),'_'));
    end

end
