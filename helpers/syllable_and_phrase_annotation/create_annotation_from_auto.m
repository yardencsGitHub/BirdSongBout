MinSylDuration = 0.008; % minimal syllable duration = 8 mSec
params = load('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav/lrb85315annotation.mat');
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
load('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav/annotated/test_results_06_13_2017.mat');
load('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav/annotated/newidx');
tokeep = setdiff(1:numel(keys),locs(newidx == 0));
keys = keys(tokeep);
filenums = filenums(tokeep);
estimates = estimates(tokeep);
num_files = numel(keys);
elements = {};
tempkeys = {};
dt = 1/3.692307692307692e+02;
% specific for this bird
syllables = [0:9,100,101,200:209 300:309 400:405];
trill_syllables = [0:2 4 5 8 9 200 203 208 209 300:306 308 309];
cnt = 1;
for fnum = 1:num_files   
    x = estimates{fnum};
    x = [0 x 0];
    syl_onset = find(x(1:end-1) == 0 & x(2:end) ~=0);
    syl_offset = find(x(1:end-1) ~= 0 & x(2:end) ==0);
    if numel(syl_onset) > 0 % if we have any syllables at all
        elements{cnt} = base_struct;
        temp = regexp(keys{fnum},'_','split');
        elements{cnt}.filenum = temp{2};
        time = getFileTime(keys{cnt});
        syl_durations = (syl_offset - syl_onset) * dt;
        % remove too short syllables <10mSec
        syl_onset(syl_durations < MinSylDuration) = [];
        syl_offset(syl_durations < MinSylDuration) = [];
        y = zeros(numel(syl_onset),1);
        for sylnum = 1:numel(y)
            y(sylnum) = mode(estimates{fnum}(syl_onset(sylnum):syl_offset(sylnum)-1));
        end
        temp_segType = syllables(y); 
        flags = zeros(size(temp_segType));
        % Deal with lonely syllables # 4,5,.. that are never alone
        for loc = 1:numel(syl_onset)
            if ismember(temp_segType(loc),trill_syllables) & (numel(syl_onset) > 1)
                if (loc == 1)
                    if temp_segType(2) ~= temp_segType(1)
                        flags(loc) = 1;
                    end
                elseif (loc == numel(syl_onset))
                    if temp_segType(end) ~= temp_segType(end-1)
                        flags(loc) = 1;
                    end
                else
                    if (temp_segType(loc) ~= temp_segType(loc-1)) & (temp_segType(loc) ~= temp_segType(loc+1))
                        flags(loc) = 1;
                    end
                end
            end
        end                            
        elements{cnt}.segFileStartTimes = (syl_onset - 1) * dt;
        elements{cnt}.segAbsStartTimes = time + elements{cnt}.segFileStartTimes/(24*60*60);
        elements{cnt}.segFileEndTimes = (syl_offset - 1) * dt;
       
        elements{cnt}.segType = syllables(y);
        elements{cnt}.segType(flags == 1) = -1;
        tempkeys{cnt} = [keys{fnum}(1:end-3) 'wav'];
        cnt = cnt + 1;
    end
    
end
    
    
    