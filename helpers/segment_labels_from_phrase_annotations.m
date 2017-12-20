%%
addpath(genpath('/Users/yardenc/Documents/GitHub/pmtk3'),'-end');
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout/helpers'),'-end');
cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation');
basdir = pwd;
birds = {'bird_1' 'bird_2' 'bird_3' 'bird_4' 'bird_5' 'bird_6'};
for birdnum = 1:numel(birds)
    cd(fullfile(basedir,birds{birdnum},'mat'));
    FILES = dir(['bird' num2str(birdnum) '*.*']);
    for fnum = 1:numel(FILES)
        load(fullfile(basedir,birds{birdnum},'mat',FILES(fnum).name));
        tot = hmm_segment_syllables(s,labels,[5 100]);
        labels = labels.*tot;
        save(fullfile(basedir,birds{birdnum},'mat',FILES(fnum).name),'s','f','t','labels');
    end
end
    