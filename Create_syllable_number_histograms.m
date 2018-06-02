%%
addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/GitHub/VideoAnalysisPipeline'));
cd('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lrb853_15/movs/wav');

annotation_file = 'lrb85315auto_annotation6.mat';

template_file = 'lrb85315template.mat';

load(annotation_file);
load(template_file);

syllables = [templates.wavs.segType];
res = cell(numel(syllables),1);
for fnum = 1:numel(elements)
    phrases = return_phrase_times(elements{fnum});
    for phrasenum = 1:numel(phrases.phraseType)
        sylnum = find(syllables == phrases.phraseType(phrasenum));
        if ~ismember(phrases.phraseType(phrasenum),[-1 100 101 102 103])
            res{sylnum} = [res{sylnum}(:); numel(find((elements{fnum}.segFileStartTimes >= phrases.phraseFileStartTimes(phrasenum)) ...
                & (elements{fnum}.segFileStartTimes <= phrases.phraseFileEndTimes(phrasenum))))];
        end
    end
end

%%
% for cnt = 1:numel(syllables)
%     if ~ismember(syllables(cnt),[-1 100 101 102 103])
%         f=figure;
%         hist(res{cnt});
%         title(syllables(cnt));
%         pause;
%         hgclose(f);
%     end
% end
%%
f=figure;
lgnd = {};
v = [];
for cnt = 1:numel(syllables)
    if ismember(syllables(cnt),[3 6 7 201 202 205 206 207 307 401 402 403 404 405 407])
        if ~isempty(res{cnt})
            [n,x] = hist(res{cnt},1:10);
            plot(x,n/sum(n),'LineWidth',2);
            lgnd = {lgnd{:} num2str(syllables(cnt))};
            p = n/sum(n);
            v = [v; p];
            hold on;
        end    
    end
end
colors = distinguishable_colors(8,'w');
[IDX, C] = kmeans(v, 6);
[IDX,I] = sort(IDX);
v = v(I,:);
figure; 
for cnt = 1:size(v,1)
    plot(x,v(cnt,:),'LineWidth',2,'Color',colors(IDX(cnt),:));
    hold on;
end
legend(lgnd(I));

set(gca,'FontSize',16);
set(gca,'YTick',[0 .5 1]);
set(gca,'XTick',[1 5 10]);
xlim([0 11])
xlabel('# of syllables');
ylabel('Frac. phrases');
%legend(lgnd)
title('syllables per phrase - Long syllables')

    
%%
f=figure;
lgnd = {};
entropies = [];
v = [];
short_syls = setdiff(syllables,[203 302 3 6 7 201 202 205 206 207 307 401 402 403 404 405 406 408 407 -1 100 101 102 103]);
for cnt = 1:numel(syllables)
    if ismember(syllables(cnt),short_syls)
        if ~isempty(res{cnt})
            [n,x] = hist(res{cnt},1:5:70);
            plot(x,n/sum(n));
            p = n/sum(n);
            v = [v; p];
            entropies = [entropies; -sum(p.*log(p+1e-5))/log(2)];
            lgnd = {lgnd{:} num2str(syllables(cnt))};
            hold on;
        end    
    end
end
set(gca,'FontSize',16);
set(gca,'YTick',[0 .5 1]);
set(gca,'XTick',[0:10:70]);
xlim([0 75])
xlabel('# of syllables');
ylabel('Frac. phrases');
legend(lgnd)
title('syllables per phrase - short syllables');

colors = distinguishable_colors(8,'w');
[IDX, C] = kmeans(v, 6);
[IDX,I] = sort(IDX);
v = v(I,:);
figure; 
for cnt = 1:size(v,1)
    plot(x,v(cnt,:),'LineWidth',2,'Color',colors(IDX(cnt),:));
    hold on;
end
legend(lgnd(I));

set(gca,'FontSize',16);
set(gca,'YTick',[0 .5 1]);
set(gca,'XTick',[0:10:70]);
xlim([0 75])
xlabel('# of syllables');
ylabel('Frac. phrases');

title('syllables per phrase - short syllables');