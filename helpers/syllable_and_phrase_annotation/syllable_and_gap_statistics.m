%%
bird_name = 'lrb85315';
bird_folder_name = 'lrb853_15';
template_file = 'lrb85315template';
annotation_file = 'lrb85315auto_annotation5_fix';
laptop_wav_folder = ['/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/' bird_folder_name '/movs/wav'];
load(fullfile(laptop_wav_folder,annotation_file));
load(fullfile(laptop_wav_folder,template_file));
syllables = [[templates.wavs.segType] -1 102 103];
n_syllables = numel(syllables);
%%
ord = [];
dates = [];
for i = 1:numel(keys)
    tokens = regexp(keys{i},'_','split');
    ord = [ord; str2num(tokens{2})];
    dates = [dates; char(join(tokens(3:5),'_'))];
end
[locs,indx] = sort(ord);
elements = elements(indx);
keys = keys(indx);
dates = dates(indx,:);
%%
syl_durations = cell(n_syllables,1);
gap_durations = cell(n_syllables,1);
elements = elements(2611:2710);
for cnt = 1:numel(elements)
    durations = elements{cnt}.segFileEndTimes - elements{cnt}.segFileStartTimes;
    gaps = elements{cnt}.segFileStartTimes(2:end) - elements{cnt}.segFileEndTimes(1:end-1);
    phrases = return_phrase_times(elements{cnt});
    for phrasecnt = 1:numel(phrases.phraseType)
        syl_locs = find(elements{cnt}.segFileEndTimes >= phrases.phraseFileStartTimes(phrasecnt) & ...
            elements{cnt}.segFileStartTimes <= phrases.phraseFileEndTimes(phrasecnt));
        syl_durations{find(syllables == phrases.phraseType(phrasecnt))} = [syl_durations{find(syllables == phrases.phraseType(phrasecnt))} ...
            durations(syl_locs)];
        if numel(syl_locs) > 1
            gap_durations{find(syllables == phrases.phraseType(phrasecnt))} = [gap_durations{find(syllables == phrases.phraseType(phrasecnt))} ...
            gaps(syl_locs(1:end-1))];
        end
    end
end
%%
m_syls = [];
m_gaps = [];
for sylcnt = 1:numel(syllables)
    m_syls = [m_syls nanmedian(syl_durations{sylcnt})];
    m_gaps = [m_gaps nanmedian(gap_durations{sylcnt})];
end
        
        