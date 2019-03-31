function [DATA, syllables] = convert_annotation_to_songs(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,include_zero,min_phrases,varargin)
% This script takes an annotation file and creates DATA - the list of songs
% as alphanumeric strings of syllable types
% Inputs:
%   path_to_annotation_file - Full or relative
%   ignore_dates - days of data to be ignored.
%   ignore_entries - A vector of label numbers to ignore completely. 
%   join_entries - A cell of vectors, each containing a >1 number of labels
%   to treat as belonging to the same state. The lists shouldn't overlap
%   (incl. with the ignored lables)
%   include_zero - should 0 be a label?
%
% Output:
%   DATA - a cell array of strings
AlphaNumeric = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
Numbercode = 1*AlphaNumeric;
onset_sym = '';
offset_sym = '';

MaxSep = 0.5; % maximal phrase separation within a bout (sec)

nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
		case 'maxsep'
			MaxSep=varargin{i+1};
        case 'onset_sym'
            onset_sym = varargin{i+1};
        case 'offset_sym'
            offset_sym = varargin{i+1};
    end
end

if ~exist(path_to_annotation_file)
    DATA = [];
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
    disp(['join or ignore lists overlap'])
    return;
end
    
load(path_to_annotation_file);
syllables = [];
DATA = {};
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
syllables = [syllables];

for fnum = 1:numel(keys)
    if ~isempty(ignore_dates)
        if ismember(return_date_num(keys{fnum}),datenum(ignore_dates))
            '4';
            continue;
        end
    end
    element = elements{fnum};
    locs = find(ismember(element.segType,ignore_entries));
    element.segAbsStartTimes(locs) = [];
    element.segFileStartTimes(locs) = [];
    element.segFileEndTimes(locs) = [];
    element.segType(locs) = [];  
    for i = 1:numel(join_entries)
        locs = find(ismember(element.segType,join_entries{i}));
        element.segType(locs) = join_entries{i}(1);
    end
    
    try
        num_phrases = 1;
        phrases = return_phrase_times(element);
        syl_locs = numel(find(elements{fnum}.segFileEndTimes >= phrases.phraseFileStartTimes(1) & ...
            elements{fnum}.segFileStartTimes <= phrases.phraseFileEndTimes(1)));
        currDATA = [onset_sym char(ones(1,syl_locs)*Numbercode(syllables == phrases.phraseType(1)))];
        for phrasenum = 1:numel(phrases.phraseType)-1
            if (phrases.phraseFileStartTimes(phrasenum + 1) -  phrases.phraseFileEndTimes(phrasenum) <= MaxSep)
                syl_locs = numel(find(elements{fnum}.segFileEndTimes >= phrases.phraseFileStartTimes(phrasenum+1) & ...
                    elements{fnum}.segFileStartTimes <= phrases.phraseFileEndTimes(phrasenum+1)));
                currDATA = [currDATA char(ones(1,syl_locs)*Numbercode(syllables == phrases.phraseType(phrasenum+1)))];
                %currDATA = [currDATA AlphaNumeric(syllables == elements{fnum}.segType(syl_locs)')];
                num_phrases = num_phrases + 1;
            else
                if (num_phrases > min_phrases)
                    DATA = {DATA{:} [currDATA offset_sym]};
                end
                syl_locs = numel(find(elements{fnum}.segFileEndTimes >= phrases.phraseFileStartTimes(phrasenum+1) & ...
                    elements{fnum}.segFileStartTimes <= phrases.phraseFileEndTimes(phrasenum+1)));
                currDATA = [onset_sym char(ones(1,syl_locs)*Numbercode(syllables == phrases.phraseType(phrasenum+1)))];
                %currDATA = [onset_sym AlphaNumeric(syllables == elements{fnum}.segType(syl_locs)')];
                num_phrases = 1;
          
           
            end  
        end
        if (num_phrases > min_phrases)
            DATA = {DATA{:} [currDATA offset_sym]};
            num_phrases = 1;
        end
    catch em
        '8'
    end
end
end
function res = return_date_num(filestr)
    tokens = regexp(filestr,'_','split');
    res = datenum(char(join(tokens(3:5),'_')));
end
