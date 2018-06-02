addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/GitHub/zftftb'));
cd('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav');
load lrb85315template.mat;
fs=48000;
for i = 1:numel(templates.wavs)
    segT = templates.wavs(i).segType;
    [IMAGE,F,T]=zftftb_pretty_sonogram(templates.wavs(i).wav,fs,'len', 16, 'overlap', 14, 'zeropad', 3, 'norm_amp', 1,'clipping',[-2 2]); %16.7
    figure; 
    imagesc(T,F,IMAGE);
    colormap hot;
end