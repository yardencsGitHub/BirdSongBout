function [DATA, syllables, file_numbers] = convert_annotation_to_pst(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,include_zero,min_phrases,varargin)
% This script takes an annotation file and the required DATA structure to
% run Jeff Markowitz's PST
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
onset_sym = '1';
offset_sym = '2';

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
syllables = [];
DATA = {};
file_numbers = [];
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
edge_syms = [];
if ~isempty(onset_sym) 
    edge_syms = [-1000];
end
if ~isempty(offset_sym) 
    edge_syms = [edge_syms 1000];
end

syllables = [edge_syms syllables];
AlphaNumeric = [onset_sym offset_sym AlphaNumeric];

temp = [];
actual_syllables = [];
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
        phrases = return_phrase_times(element);
        
        currDATA = [onset_sym AlphaNumeric(syllables == phrases.phraseType(1))];
        currsyls = [-1000 phrases.phraseType(1)];
        for phrasenum = 1:numel(phrases.phraseType)-1
            if (phrases.phraseFileStartTimes(phrasenum + 1) -  phrases.phraseFileEndTimes(phrasenum) <= MaxSep)
                currDATA = [currDATA AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1))];
                currsyls = [currsyls phrases.phraseType(phrasenum + 1)];
            else
                if (numel(currDATA) >= min_phrases)
                    DATA = {DATA{:} [currDATA offset_sym]};
                    file_numbers = [file_numbers fnum];
                    actual_syllables = unique(union(actual_syllables,unique([currsyls 1000])));
                end
                currDATA = [onset_sym AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1))];
                currsyls = [-1000 phrases.phraseType(phrasenum + 1)];
            end  
        end
        if (numel(currDATA) >= min_phrases)
            DATA = {DATA{:} [currDATA offset_sym]};
            file_numbers = [file_numbers fnum];
            actual_syllables = unique(union(actual_syllables,unique([currsyls 1000])));
        end
    catch em
        '8';
    end
end
actual_syllables = unique(actual_syllables);
no_show_syllables = setdiff(syllables,actual_syllables);
syllables(ismember(syllables,no_show_syllables)) = [];

end
function res = return_date_num(filestr)
    tokens = regexp(filestr,'_','split');
    res = datenum(char(join(tokens(3:5),'_')));
end
