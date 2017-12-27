    sig = sum(s(5:100,:));
    figure; h1 = subplot(2,1,1); plot(sig); hold on; plot(labels);
    axis tight

    h2 = subplot(2,1,2); imagesc(s);
    linkaxes([h1,h2],'x')
    
    %%
    
    dlabels = find(diff([0 labels 0]) ~= 0);
    locs = find(labels(dlabels(1:end-1)) ~= 0);
    fx = @(x)mean(sig(dlabels(x):(dlabels(x+1)-1)));
    figure; plot(arrayfun(fx,locs)')
    find(arrayfun(fx,locs)'< 0.1)
    %%
    
% addpath(genpath('/Users/yardenc/Documents/GitHub/pmtk3'),'-end');
% addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout/helpers'),'-end');
% cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation');
% basedir = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation';
% birds = {'bird_1' 'bird_2' 'bird_3' 'bird_4' 'bird_5' 'bird_6'};
% startfrom = 1;
% for birdnum = 1:6
%     if birdnum == 5
%         continue;
%     end
%     cd(fullfile(basedir,birds{birdnum},'mat'));
%     FILES = dir(['bird' num2str(birdnum) '*.*']);
%     for fnum = startfrom:numel(FILES)
%         load(fullfile(basedir,birds{birdnum},'mat',FILES(fnum).name));
%         lbl = labels;
%         sig = sum(s(5:100,:));
%         try
%             dlabels = find(diff([0 labels 0]) ~= 0);
%             locs = find(labels(dlabels(1:end-1)) ~= 0);
%             fx = @(x)mean(sig(dlabels(x):(dlabels(x+1)-1)));
%             b = arrayfun(fx,locs)';
%             locs1 = locs(b<0.1);
%             for nloc = 1:numel(locs1)
%                 loc = locs1(nloc);
%                 labels(dlabels(loc):dlabels(loc+1)-1) = 0;
%             end
%             if ~isempty(locs1)
%                 save(fullfile(basedir,birds{birdnum},'mat',FILES(fnum).name),'s','f','t','labels');
%                 display(FILES(fnum).name)
%             end
%         catch em
%             display(['Error in: ' FILES(fnum).name]);
%         end
%     end
% end

%% fix bird 6's syllables
cd('/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation/bird_6/mat');
FILES = dir('bird6_*.*');
for fnum = 1:numel(FILES)
    load(FILES(fnum).name);
    % fix syl 15
    locs = find(labels == 15);
    dlocs = diff([0 locs]);
    smlocs = find(dlocs < 3 & dlocs > 1);
    if ~isempty(smlocs)
        '*';
    end
end

    