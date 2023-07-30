function [hndls, syls, degrees, probs, freqs, DATA] = bsb_create_pst_from_annotation(path_to_annotation_file,varargin) 
%% Create PSTs
% This script creates the PSTs and figures
% To reduce noise some rare syllables are removed (the variable 'ignore_entries') and the criterion for
% removal is described for each bird (since the number of files changes
% between them)
% some dates are ignored (the 'ignore_dates' list) because of data
% corruption.
% Some entries are joined (the list 'join_entries') because they belong to
% the same syllable class and were separated due to user OCD.. :)
% 'include_zero' is 0/1 for including the label '0' (in birds 853 and
% 3022), 'min_phrases' sets the minimal # of phrases per song bout to
% include.

% The script currently uses a pre-defined set of colors, hard coded in a
% filename. This should change in future passes
%% repos. requirements: pst, BirdSongBout
addpath(genpath('/Users/yardenc/Documents/GitHub/pst'),'-end'); %_yc
addpath(genpath('/Users/yardenc/Documents/GitHub/BirdSongBout'),'-end');
global colors color_tags;
%colors = [];
%color_tags = [];

ignore_dates = {};
join_entries = {};
ignore_entries = [];
include_zero = 0;
min_phrases = 1;
onset_sym = '1';
offset_sym = '2';
title_fsize = 8;
slice_fsize = 8;
L = 5;
MaxSep = 0.5;
p_min = 0.0073; %0.005;
p_smoothing = 1; %0
nparams=length(varargin);
randomsample = 0;
for i=1:2:nparams
	switch lower(varargin{i})
        case 'maxsep'
			MaxSep=varargin{i+1};
		case 'ignore_dates'
			ignore_dates=varargin{i+1};
        case 'join_entries'
            join_entries = varargin{i+1};
        case 'ignore_entries'
            ignore_entries = varargin{i+1};
        case 'include_zeros'
            include_zeros = varargin{i+1};
        case 'min_phrases'
            min_phrases = varargin{i+1};
        case 'onset_sym'
            onset_sym = varargin{i+1};
        case 'offset_sym'
            offset_sym = varargin{i+1};
        case 'title_fsize'
            title_fsize = varargin{i+1};
        case 'slice_fsize'
            slice_fsize = varargin{i+1};
        case 'l'
            L = varargin{i+1};
        case 'p_min'
            p_min = varargin{i+1};
        case 'p_smoothing'
            p_smoothing = varargin{i+1};
        case 'randomsample'
            randomsample = varargin{i+1};
    end
end

%%
[DATA, syls] = bsb_convert_annotation_to_pst(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,... 
     include_zero,min_phrases,'onset_sym',onset_sym,'offset_sym',offset_sym,'maxsep',MaxSep);
if randomsample > 0
    rp = randperm(numel(DATA));
    DATA = DATA(rp(1:randomsample));
end
disp(['# of DATA strings: ' num2str(numel(DATA))]); 
[F_MAT ALPHABET N PI]=pst_build_trans_mat(DATA,L);
TREE = pst_learn(F_MAT,ALPHABET,N,'L',L,'p_smoothing',p_smoothing,'p_min',p_min);
%%
syl_labels = mat2cell(syls',ones(numel(syls),1),1);
load(fullfile('/Users/yardenc/Documents/Projects/Cohen2017_tf_segmentation_annotation/Code','pie_colors.mat'));
if numel(syls) <= size(colors,1)
    colors = colors(1:numel(syls),:);
else
    colors = distinguishable_colors(numel(syls),'w');
end
color_tags = syls;
%%
hndls = [];
degrees = [];
probs = [];
freqs = probs;
for rootnode = 1:numel(TREE(2).string)
    currdeg = [1];
    display(['Main branch: Syllble #' num2str(syls(TREE(2).string{rootnode}))]);
    f=figure; ax = axes(f); h_pie=pie(ax,double(TREE(2).g_sigma_s(:,rootnode)),zeros(1,numel(syls)),cellfun(@num2str,syl_labels,'UniformOutput',0));
    degrees = [degrees; 1];
    probs = [probs; TREE(2).p(rootnode)];
    freqs = [freqs; TREE(2).f(rootnode)];
    for cnt = 2:2:numel(h_pie)
        h_pie(cnt-1).FaceColor = colors(color_tags == str2num(h_pie(cnt).String),:);
        if (slice_fsize > 0)
            h_pie(cnt).FontSize = slice_fsize;
        else
            h_pie(cnt).String = '';
        end
        
    end
    if (title_fsize > 0)
        %title(['Root: ' num2str(syls(TREE(2).string{rootnode}))],'FontSize',title_fsize);
        title(ALPHABET(TREE(2).string{rootnode}),'FontSize',title_fsize,...
            'Color',colors(color_tags == syls(TREE(2).string{rootnode}),:)); %[193 44 66]/255 
    end
    set(h_pie,'LineWidth',0.25);
    hndls = [hndls ax];
    explore_branch(TREE,syls,2,rootnode);
    %degrees = {degrees{:} currdeg};
end
    
function explore_branch(TREE,syls,level_num,branch_num)
%     switch bnum
%         case 1
%             
%             load('/Users/yardenc/Documents/Projects/CohenGardner2017_CanaryHVCImaging/Figures/lrb853_colors.mat');
%         case 2
%             load('/Users/yardenc/Documents/Projects/CohenGardner2017_CanaryHVCImaging/Figures/lbr3022_colors.mat');
%     end
    syl_labels = mat2cell(syls',ones(numel(syls),1),1);
   if (level_num < numel(TREE) & ~isempty(TREE(level_num + 1).parent))
       branches = find(TREE(level_num + 1).parent(1,:) == branch_num);
       currdeg = [currdeg numel(branches)];
       for next_branch_num = 1:numel(branches)
           %display([level_num next_branch_num])
           display(['level ' num2str(level_num) ' Branch: ' num2str(syls(TREE(level_num + 1).string{branches(next_branch_num)}))]);
           f=figure; ax = axes; h_pie=pie(ax,double(TREE(level_num+1).g_sigma_s(:,branches(next_branch_num))),zeros(1,numel(syls)),cellfun(@num2str,syl_labels,'UniformOutput',0));
           degrees = [degrees; level_num]; 
           probs = [probs; TREE(level_num + 1).p(branches(next_branch_num))];
           freqs = [freqs; TREE(level_num + 1).f(branches(next_branch_num))];
           for cnt = 2:2:numel(h_pie)
                h_pie(cnt-1).FaceColor = colors(color_tags == str2num(h_pie(cnt).String),:);
                if (slice_fsize > 0)
                    h_pie(cnt).FontSize = slice_fsize;
                else
                    h_pie(cnt).String = '';
                end
                
            end
            if (title_fsize > 0)
                if TREE(level_num + 1).internal(branches(next_branch_num)) == 1
                    %title(['Internal: ' num2str(syls(TREE(level_num + 1).string{branches(next_branch_num)}))],'FontSize',title_fsize);
                    title(ALPHABET(TREE(level_num + 1).string{branches(next_branch_num)}),'FontSize',title_fsize,'Color',[157 206 200]/255);
                else
                    %title(['Branch: ' num2str(syls(TREE(level_num + 1).string{branches(next_branch_num)}))],'FontSize',title_fsize);
                    title(ALPHABET(TREE(level_num + 1).string{branches(next_branch_num)}),'FontSize',title_fsize,'Color',[0 0 0]);
                end
            end
            set(h_pie,'LineWidth',0.25);
            hndls = [hndls ax];
           explore_branch(TREE,syls,level_num + 1,branches(next_branch_num));
       end
       
   end
end
end
