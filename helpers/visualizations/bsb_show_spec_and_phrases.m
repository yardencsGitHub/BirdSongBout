% This is a test script that loaded already existing spectrogram files
% (including the time and frequency vectors) and visualized them with the
% phrases annotated on top 
%%
addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/GitHub/zftftb'));
addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/GitHub/VideoAnalysisPipeline'));
addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/GitHub/small-utils'));
% targetdir = '/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav/annotated/images';
if ~exist(targetdir,'dir')
    mkdir(targetdir);
end
% template_file = 'lrb85315template.mat';
% cd('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav');
cd(laptop_wav_folder);
%load(template_file);
%syllables = [[templates.wavs.segType] -1 102 103];
% load lrb85315auto_annotation4;
load(new_annotation_file);
% cd('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav/mat');
cd([laptop_wav_folder '/mat']);
n_syllables = numel(syllables);
freq_min = 300; freq_max = 8000;
colors = distinguishable_colors(n_syllables);

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

startloc = min(find(locs >= startfrom));

%%
startloc;
for fnum = 1:numel(keys) %ceil(0.75*numel(keys)):numel(keys)
    if (limit_dates == 1) & ~ismember(datenum(dates(fnum,:)),dates_to_process)
        continue;
    end
    matfile = [keys{fnum}(1:end-3) 'mat'];
    load(matfile);
    
    h=figure('Visible','off','Position',[77          91        2215         420]);
    subplot(10,1,2:10);

    imagesc(t,f(7:172),(s(7:172,:)));
    set(gca,'YDir','normal');
    %colormap(1-hot);

    %imagesc(t,f(7:172),s(7:172,:));

    hold on;
    lbls = nan*zeros(size(s));
    phrases = return_phrase_times(elements{fnum});
    for phrasenum = 1:numel(phrases.phraseType)
        tonset = phrases.phraseFileStartTimes(phrasenum);
        toffset = phrases.phraseFileEndTimes(phrasenum);
        line([tonset tonset],[freq_min freq_max],'Color',[1 1 1],'LineStyle','--');
        line([toffset toffset],[freq_min freq_max],'Color',[0.5 0.5 0.5],'LineStyle','--'); 
    end
    xlabel('Time (sec)');
    ylabel('Frequency (Hz)');
    
    subplot(10,1,1);
    
    for phrasenum = 1:numel(phrases.phraseType)
        tonset = phrases.phraseFileStartTimes(phrasenum);
        toffset = phrases.phraseFileEndTimes(phrasenum);
        plot(t((t>=tonset) & (t<=toffset)),ones(1,sum((t>=tonset) & (t<=toffset))),'Color', ...
            colors(find(syllables == phrases.phraseType(phrasenum)),:),'LineWidth',10);
        hold on;
    end
    set(gca,'XTick',[]);
    set(gca,'YTick',[]);
    xlim([0 t(end)]);
    set(gca,'color','none');
    axis off;
    ylim([0.9 2]);
    tokens = regexp(matfile,'_','split');
    title(['bird: ' tokens{1} ', file: ' tokens{2}]);
    saveas(h,fullfile(targetdir,[keys{fnum}(1:end-3) 'png']));
    
    hgclose(h);
    display(fnum/numel(keys));
    display(matfile)
end    
