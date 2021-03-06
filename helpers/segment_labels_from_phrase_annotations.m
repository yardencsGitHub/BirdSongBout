%%
addpath(genpath('/Users/yardenc/Documents/GitHub/pmtk3'),'-end');
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout/helpers'),'-end');
cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation');
basedir = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation';
birds = {'bird_1' 'bird_2' 'bird_3' 'bird_4' 'bird_5' 'bird_6'};
for birdnum = 1:numel(birds)
    if (birdnum == 1)
        startfrom = 1;
    else
        startfrom = 1;
    end
    cd(fullfile(basedir,birds{birdnum},'mat'));
    FILES = dir(['bird' num2str(birdnum) '*.*']);
    for fnum = 1:numel(FILES)
        load(fullfile(basedir,birds{birdnum},'mat',FILES(fnum).name));
        try
            tot = hmm_segment_syllables(s,labels,[5 100]);
            labels = labels.*tot;
            save(fullfile(basedir,birds{birdnum},'mat',FILES(fnum).name),'s','f','t','labels');
            display(FILES(fnum).name)
        catch em
            display(['Error in: ' FILES(fnum).name]);
        end
    end
end
    