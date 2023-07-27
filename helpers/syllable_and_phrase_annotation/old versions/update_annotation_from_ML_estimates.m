function [elements, keys] = update_annotation_from_ML_estimates(path_annotation,path_templates,path_estimates,varargin)
% This script was used in the early stages of developing TweetyNet
% It received the network estimates and updated the annotation structure to
% include annotated segments. 
% The script also applied the post-processing steps of short segment
% rejection and majority voting.

MinSylDuration = 0.005; % minimal syllable duration = 5 mSec
%addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/TimOs'));
params = load(path_annotation);
expr = params.elements{1}.exper;
base_struct = struct('exper',expr, ...
                     'filenum',0, ...
                     'segAbsStartTimes',[], ...
                     'segFileStartTimes',[], ...
                     'segFileEndTimes',[], ...
                     'segType',[], ...
                     'fs',48000, ...
                     'drugstatus', 'No Drug', ...
                     'directstatus', 'Undirected');

if isstr(path_estimates)
    load(path_estimates);
    %keys = params.keys; %uncomment if 'keys' is not part of the estimates
    %file
else
    estimates = path_estimates;
    keys = params.keys;
end
if isstr(path_templates)
    load(path_templates);
    syllables = [templates.wavs.segType];
else
    syllables = path_templates;
end
num_files = numel(estimates);
elements = {};
tempkeys = {};
dt = 1/3.692307692307692e+02;
trill_syllables = [];
max_zero_bins_to_ignore = 1; %was 2
is_new = 1;


nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
		case 'minsylduration'
			MinSylDuration = varargin{i+1};
        case 'dt'
            dt = varargin{i+1};
        case 'trill_syllables'
            trill_syllables = varargin{i+1};
        case 'max_zero_bins_to_ignore'
            max_zero_bins_to_ignore = varargin{i+1};
        case 'is_new'
            is_new = varargin{i+1};
    end
end
if is_new == 0
    elements = params.elements;
end

cnt = 1;
for fnum = 1:num_files  
    temp = regexp(keys{fnum},'_','split');
    if is_new == 0
        cnt = find(strcmp(params.keys,[keys{fnum}(1:end-3) 'wav']));
        if isempty(cnt)
            disp(['not finding ' keys{fnum}]);
            continue;
        end
    end
    x = estimates{fnum}; x = reshape(x,1,numel(x));
    % fix abberant zero segments
    xzeros = 1*(x==0);
    dxzeros = diff([0 xzeros 0]); locs_on = find(dxzeros == 1); locs_off = find(dxzeros == -1);
    locs = find(locs_off - locs_on <= max_zero_bins_to_ignore);
    for locnum = 1:numel(locs)
        xon = max(locs_on(locs(locnum))-1,1); xoff = min(locs_off(locs(locnum)),numel(x));
        x(locs_on(locs(locnum)):locs_off(locs(locnum))-1) = max(setdiff(x(xon:xoff),0));
    end
    % removed short sequences of zeros (set by max_zero_bins_to_ignore)
    x = [0 x 0];
    syl_onset = find(x(1:end-1) == 0 & x(2:end) ~=0);
    syl_offset = find(x(1:end-1) ~= 0 & x(2:end) ==0);
    if numel(syl_onset) > 1 % if we have any syllables at all
       
        time = getFileTime(keys{fnum});
        
        syl_durations = (syl_offset - syl_onset) * dt;
        % remove too short syllables <10mSec
        syl_onset(syl_durations < MinSylDuration) = [];
        syl_offset(syl_durations < MinSylDuration) = [];
        y = zeros(numel(syl_onset),1);
        for sylnum = 1:numel(y) % in case we encompassed some zeros
            tempseq = estimates{fnum}(syl_onset(sylnum):syl_offset(sylnum)-1);
            tempseq(tempseq == 0) = [];
            y(sylnum) = mode(tempseq);
        end
        
        elements{cnt} = base_struct;
        elements{cnt}.filenum = temp{2};
        elements{cnt}.segFileStartTimes = (syl_onset - 1) * dt;
        elements{cnt}.segAbsStartTimes = time + elements{cnt}.segFileStartTimes/(24*60*60);
        elements{cnt}.segFileEndTimes = (syl_offset - 1) * dt;
        try
            elements{cnt}.segType = syllables(y)';
        catch em
            '-';
        end
        % fix trill-only syllables 
        if ~isempty(trill_syllables)
            tempsegtype = syllables(y)';
            for tsylnum = 1:numel(trill_syllables)
                locs = find(tempsegtype == trill_syllables(tsylnum));
                for locnum = 1:numel(locs)
                    if locs(locnum) == 1            
                       if tempsegtype(locs(locnum)) ~= tempsegtype(locs(locnum) + 1)
                            tempsegtype(locs(locnum)) = tempsegtype(locs(locnum) + 1);
                       end
                    end
                    if locs(locnum) == numel(y)
                        if tempsegtype(locs(locnum)) ~= tempsegtype(locs(locnum) - 1)
                            tempsegtype(locs(locnum)) = tempsegtype(locs(locnum) - 1);
                        end
                    end
                    if (locs(locnum) < numel(y) && locs(locnum) > 1)
                        if tempsegtype(locs(locnum)) ~= tempsegtype(locs(locnum) - 1) && tempsegtype(locs(locnum)) ~= tempsegtype(locs(locnum) + 1)
                            tempsegtype(locs(locnum)) = tempsegtype(locs(locnum) - 1);
                        end
                    end
                end
            end
            elements{cnt}.segType = tempsegtype;
        end
        if is_new ~= 0
            tempkeys{cnt} = [keys{fnum}(1:end-3) 'wav'];
            cnt = cnt + 1;  
        end
        
    else
        elements{cnt} = base_struct;
        elements{cnt}.filenum = temp{2};
        elements{cnt}.segFileStartTimes = [];
        elements{cnt}.segAbsStartTimes = [];
        elements{cnt}.segFileEndTimes = [];
        elements{cnt}.segType = [];
     
        tempkeys{cnt} = [keys{fnum}(1:end-3) 'wav'];
        cnt = cnt + 1;
    end
    
end
if is_new ~= 0
    keys = tempkeys;
else 
    keys = params.keys;
end
end

function time = getFileTime(filename)
    if strcmp(filename(end-2:end),'mat')
        filename = filename(1:end-4);
    end
    strparts = regexp(filename,'_', 'split');

    y1 = str2double(strparts{3});
    m = str2double(strparts{4});
    d = str2double(strparts{5});
    th = str2double(strparts{6});
    tm = str2double(strparts{7});
    try
        ts = strparts{8};
        ts =  str2double(ts); %(1:end-4)
    catch em
        ts = 0;
    end

    time = datenum(y1,m,d,th,tm,ts);

end
    
    
    