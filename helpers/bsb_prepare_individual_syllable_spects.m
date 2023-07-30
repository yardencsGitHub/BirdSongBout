function bsb_prepare_individual_syllable_spects(path_to_annotation,path_to_audio,path_to_target)
% This script prepares spectrogram snippets of all syllables and creates
% files for those syllable classes.
%   Prepare_individual_syllable_spects(path_to_annotation,path_to_audio)
%   Inputs are the paths
%
%%
ignore_syllables = -1;
TargetDir = path_to_target;

%% organize and find syllable classes
cd(path_to_audio);
load(path_to_annotation);
ords = [];
dates = [];
syl_classes = [];
for fnum = 1:numel(keys)
    tokens = regexp(keys{fnum},'_','split');
    ords(fnum) = str2num(tokens{2});
    dates = [dates; datenum(char(join(tokens(3:5),'_')))];
    syl_classes = unique(union(syl_classes,setdiff(unique(elements{fnum}.segType),ignore_syllables)));
end
[locs,indx] = sort(ords);
elements = elements(indx);
keys = keys(indx);
dates = dates(indx,:);
%% count syllables
n_syl = numel(syl_classes);
flag = 1;
syl_counts = zeros(n_syl,1);
hf = waitbar(0,'counting syllables');
for fnum = 1:numel(keys)
    tokens = regexp(keys{fnum},'_','split');
    for segnum = 1:numel(elements{fnum}.segType)
        if ismember(elements{fnum}.segType(segnum),syl_classes)
            syloc = find(syl_classes == elements{fnum}.segType(segnum));
            syl_counts(syloc) = syl_counts(syloc) + 1; 
        end
    end
    waitbar(fnum/numel(keys),hf);
end
close(hf);

%%

for syltype = 1:n_syl
    clear syllable_spects;
    sylnum = syl_classes(syltype);
    
    syllable_spects.syl_num = sylnum;
    syllable_spects.samples = cell(syl_counts(syltype),1);
    syllable_spects.idx = zeros(syl_counts(syltype),2);
    syl_cnt = 1;
    flag = 1;
    clc;
    hf = waitbar(0,['Creating file ' num2str(syltype) ' / ' num2str(n_syl)]);
    for filenum = 1:numel(elements)
        waitbar(filenum/numel(keys),hf);
        fname = keys{filenum};
        loc = filenum;
        %phrases = return_phrase_times(elements{loc});
        if ~ismember(sylnum,elements{filenum}.segType)
            continue;
        end
        [y,fs] = audioread([fname(1:end-3) 'wav']);
        [S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),440,440-88,1024,fs); %440,440-88
        
        for segnum = 1:numel(elements{loc}.segType)
            if (elements{loc}.segType(segnum) == sylnum)
                tidx = find(T >= elements{loc}.segFileStartTimes(segnum) & T <= elements{loc}.segFileEndTimes(segnum));
                syloc = find(syl_classes == elements{loc}.segType(segnum));
                syllable_spects.samples{syl_cnt} = single(log(1+abs(S(:,tidx))));
                syllable_spects.idx(syl_cnt,:) = [filenum segnum];
                syl_cnt = syl_cnt + 1;
%                 if syl_cnt > 2000
%                     flag = 0;
%                 end
            end
        end
        %clc;
        %disp([filenum numel(elements)]);
    end
    outfile = fullfile(TargetDir,['syllable_spects_' num2str(sylnum) '.mat']);
    save(outfile,'syllable_spects','-v7.3');
    close(hf);
end