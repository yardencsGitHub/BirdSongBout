% set of scripts to clean an annotation file
MinPhraseDuration = 0.05;
maxdiff = 0.005;

DIR = '/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lbr3022';
annotation_file = 'lbr3022auto_annotation5_alexa.mat'; %'lrb85315auto_annotation5_fix.mat';
template_file = 'lbr3022_template.mat'; %'lrb85315template.mat';

cd(DIR);
load(annotation_file);
load(template_file);

syllables = [templates.wavs.segType];

for fnum = 1:numel(keys)
    syllables = unique([syllables unique(elements{fnum}.segType)']);
end

addpath(genpath('/Users/yardenc/Documents/GitHub/VideoAnalysisPipeline'),'-end');
%% 1. Find unlabeled segments
clc;
display('unlabeled:');
for fnum = 1:numel(keys)
    if ismember(-1,elements{fnum}.segType)
        display(keys{fnum})
    end
end

%% 2. Find short phrases
clc;
display(['Short phrases (MinPhraseDuration =  ' num2str(MinPhraseDuration) ')']);
display(['File name | phrase numbers ||| phrase types'])
for fnum = 1:numel(keys)
    phrases = return_phrase_times(elements{fnum});
    durations = phrases.phraseFileEndTimes - phrases.phraseFileStartTimes;
    if any(durations < MinPhraseDuration)
        display([keys{fnum} ' | ' num2str(find(durations < MinPhraseDuration)') ' ||| ' ...
            num2str(phrases.phraseType(durations < MinPhraseDuration)')]);
    end
end

%% 3. Find phrase breaks by potentially mislabelled syllables
clc;
display(['Enclaved:']);
for fnum = 1:numel(keys)
    phrases = return_phrase_times(elements{fnum});
    for phrasenum = 2:numel(phrases.phraseType)-1
        if (phrases.phraseType(phrasenum - 1) == phrases.phraseType(phrasenum + 1))
            display([keys{fnum} ' | ' num2str(phrasenum) ' ||| ' ...
                num2str(phrases.phraseType(phrasenum))]);
        end
    end
end

%% 4. Find isolated syllables.
display(['Isolated syllables:']);
display(['File name | segment numbers ||| syllable types']);
for fnum = 1:numel(keys)
    segseq = [-1000; elements{fnum}.segType; 1000];
    tmpnum = []; tmptype = [];
    for segnum = 2:numel(segseq)-1
        if ((segseq(segnum - 1) ~= segseq(segnum)) & ...
               segseq(segnum) ~= segseq(segnum + 1))
           tmpnum = [tmpnum  (segnum-1)]; tmptype = [tmptype segseq(segnum)];
           
%            display([keys{fnum} ' | ' num2str(phrasenum-1) ' ||| ' ...
%                 num2str(phrases.phraseType(phrasenum))]);
        end
    end
    if ~isempty(tmptype)
       display([keys{fnum} ' | ' num2str(tmpnum) ' ||| ' ...
                 num2str(tmptype)]); 
    end
end
%% 5. Find broken syllables
clc;
display(['Syllables with gaps < ' num2str(maxdiff) ':']);
for fnum = 1:numel(elements)
  phrases = return_phrase_times(elements{fnum});
  diffs = elements{fnum}.segFileStartTimes(2:end) - elements{fnum}.segFileEndTimes(1:end-1);  
  locs = find(diffs < maxdiff);
  if any(locs)
          display([keys{fnum} ' | syllable #s: ' num2str(elements{fnum}.segType(locs)')]);
  end
end