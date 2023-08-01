%% 
cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/llb3');
load('llb3_annotation_alexa_ordered.mat');
cnt = 0;

syllables = [];
for fnum = 1:numel(elements)
    if ~isempty(elements{fnum}.segType)
        cnt = cnt+1;
        syllables = [syllables; unique(elements{fnum}.segType)];
    end
end
syllables = unique(syllables);
%%
new_syllables = 1:numel(syllables);
%%
for fnum = 1:numel(elements)
    if ~isempty(elements{fnum}.segType)
        for segnum = 1:numel(elements{fnum}.segType)
            elements{fnum}.segType(segnum) = new_syllables(syllables == elements{fnum}.segType(segnum));
        end
    end
end
%%
clc;
load('llb3_templates_alexa.mat');
newwavs = [];
for wavnum = 1:numel(templates.wavs)
    if ismember(templates.wavs(wavnum).segType,syllables)
        currwav = templates.wavs(wavnum);
        currwav.segType = new_syllables(syllables == templates.wavs(wavnum).segType);
        newwavs = [newwavs currwav];
    end
end
%%
cnt = 0;

syls = [];
for fnum = 1:numel(elements)
    if ~isempty(elements{fnum}.segType)
        cnt = cnt+1;
        syls = [syls; unique(elements{fnum}.segType)];
    end
end
syls = unique(syls);

%%
add_annotation_to_mat(pwd,'llb3_annotation_alexa_ordered.mat','llb3_templates_alexa_ordered.mat');
%%
% save 'keys' in 'file_list.mat' in the folder for the training data
% After running the segmentation algorithm retreive the estimates file,
% save it in the folder that contains the annotation file and run
