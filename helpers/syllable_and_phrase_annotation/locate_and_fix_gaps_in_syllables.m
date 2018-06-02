% locate and fix broken annotations of long syllables
%%
maxdiff = 0.005;

addpath(genpath('/Users/yardenc/Documents/Experiments/Code and Hardware Dev/GitHub/VideoAnalysisPipeline'),'-end');
cd('/Users/yardenc/Documents/Experiments/Imaging/Data/CanaryData/lbr3022');

annotation_file = 'lbr3022auto_annotation5_alexa.mat'; %'lrb85315auto_annotation5.mat';
load(annotation_file);
res = {};
res1 = {};
cnt = 1;
cnt1 = 1;
for fnum = 1:numel(elements)
  phrases = return_phrase_times(elements{fnum});
  diffs = elements{fnum}.segFileStartTimes(2:end) - elements{fnum}.segFileEndTimes(1:end-1);  
  locs = find(diffs < maxdiff);
  if any(locs)
      errs = [];
      errs1 = [];
      for tmp = 1:numel(locs)
          if ismember(elements{fnum}.segType(locs(tmp)),[3 6 7 201 202 205 206 207 307 400 401 402 403 404 405 407 500])
              errs = [errs locs(tmp)];
          else
              if (diffs(locs(tmp)) < 0.002)
                errs1 = [errs1 locs(tmp)];
              end
          end
      end
      if ~isempty(errs)
        res{cnt} = [fnum errs];
        cnt = cnt+1;
      end
      if ~isempty(errs1)
        res1{cnt1} = [fnum errs1];
        cnt1 = cnt1+1;
      end
  end
end
%%
for n = 1:numel(res)
    locs = res{n}(2:end);
    for cnt = numel(locs):-1:1
        if elements{res{n}(1)}.segType(locs(cnt)) == elements{res{n}(1)}.segType(locs(cnt)+1)
            elements{res{n}(1)}.segType(locs(cnt)+1) = [];
            elements{res{n}(1)}.segAbsStartTimes(locs(cnt)+1) = [];
            elements{res{n}(1)}.segFileEndTimes(locs(cnt)) = elements{res{n}(1)}.segFileEndTimes(locs(cnt)+1);
            elements{res{n}(1)}.segFileEndTimes(locs(cnt)+1) = [];
            elements{res{n}(1)}.segFileStartTimes(locs(cnt)+1) = [];
        end
    end
end