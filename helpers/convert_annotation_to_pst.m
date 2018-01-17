function [DATA, syllables] = convert_annotation_to_pst(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,include_zero,min_phrases)
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


MaxSep = 0.5; % maximal phrase separation within a bout (sec)

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
    resmat = [];
    state_labels = [];
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

temp = [];
for fnum = 1:numel(keys)
    if ismember(return_date_num(keys{fnum}),datenum(ignore_dates))
        '4';
        continue;
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
        
        currDATA = AlphaNumeric(syllables == phrases.phraseType(1));
        for phrasenum = 1:numel(phrases.phraseType)-1
            if (phrases.phraseFileStartTimes(phrasenum + 1) -  phrases.phraseFileEndTimes(phrasenum) <= MaxSep)
                currDATA = [currDATA AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1))];
            else
                if (numel(currDATA) > min_phrases)
                    DATA = {DATA{:} currDATA};
                end
                currDATA = AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1));
           
            end
            if (numel(currDATA) > min_phrases)
                DATA = {DATA{:} currDATA};
            end
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
