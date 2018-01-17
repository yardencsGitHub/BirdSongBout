function [resmat, state_labels] = create_second_order_transition_matrix(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,to_normalize,include_zero)
% This script takes an annotation file and returns a cube tensor of
% either normalized or non-normalized transitions
% Inputs:
%   path_to_annotation_file - Full or relative
%   ignore_dates - days of data to be ignored.
%   ignore_entries - A vector of label numbers to ignore completely. 
%   join_entries - A cell of vectors, each containing a >1 number of labels
%   to treat as belonging to the same state. The lists shouldn't overlap
%   (incl. with the ignored lables)
%   to_normalize - should the returned matrix be normalized?
%   include_zero - should 0 be a label?
%
% Output:
%   resmat(i,j,k) represents # or fraction (if normalized) transitions from i
%   to j to k.
%   state_count - # of times each label is encountered.
%   state_labels - the lables of the matrix
MaxSep = 0.5; % maximal phrase separation within a bout (sec)

if ~exist(path_to_annotation_file)
    resmat = [];
    state_labels = [];
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
    display(['join or ignore lists overlap'])
    return;
end
    
load(path_to_annotation_file);
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
syllables = [-1000 syllables 1000];
num_syllables = numel(syllables);
resmat = zeros(num_syllables,num_syllables,num_syllables);
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
        phrases = deal_with_time_gaps(phrases,MaxSep);
        for phrasenum = 1:numel(phrases.phraseType)-2 
            resmat(syllables == phrases.phraseType(phrasenum),...
            syllables == phrases.phraseType(phrasenum + 1),...
            syllables == phrases.phraseType(phrasenum + 2)) = ...
                resmat(syllables == phrases.phraseType(phrasenum),...
                syllables == phrases.phraseType(phrasenum + 1),...
                syllables == phrases.phraseType(phrasenum + 2)) + 1;      
        end
    catch em
        '8'
    end
end


switch to_normalize
    case 1
        resmat = resmat./(repmat(sum(resmat,3),1,1,num_syllables));
    case 2
        resmat = resmat/sum(resmat(:));
end
    
resmat(isnan(resmat)) = 0;
state_labels = syllables;
end

function res = return_date_num(filestr)
    tokens = regexp(filestr,'_','split');
    res = datenum(char(join(tokens(3:5),'_')));
end

