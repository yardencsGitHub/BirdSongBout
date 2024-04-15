function fh = bsb_create_complete_PST_fig(TREE,syls,ALPHABET,varargin)
    % This function creates a figure that displays the PST graph with pies
    % in the nodes and node labels for the sequences.
    % Inputs:
    % - tree: Array of length L+1 that describes the PST tree
    %         built using Ron, Bejerano, Tishby et al's algorithm as
    %         implemented by Jeff Markowitz in TREE=pst_learn(F_MAT,ALPHABET,N,varargin)
    % - syls: array of numbers to match the syllable types. This must match
    %         the alphabet used to describe those syllables
    % - alphabet: A string describing the characters used to describe syllables. The order of characters must match the numbers in 'syls'  

    % Output:
    % - fh: Graphics handles.
    pie_colors_file_path = [];
    githubfolder = '/Users/yardenc/Documents/GitHub';
    title_fsize = 8;
    slice_fsize = 8;
    
    nparams=length(varargin);
    for i=1:2:nparams
	    switch lower(varargin{i})
            case 'title_fsize'
                title_fsize = varargin{i+1};
            case 'slice_fsize'
                slice_fsize = varargin{i+1};  
            case 'pie_colors_file_path'
                pie_colors_file_path = varargin{i+1}; 
            case 'githubfolder'
                githubfolder = varargin{i+1}; 
        end
    end

    addpath(genpath(fullfile(githubfolder,'BirdSongBout')),'-end');
    addpath(genpath(fullfile(githubfolder,'pst')),'-end');
    addpath(genpath(fullfile(githubfolder,'small-utils')),'-end');

    if ~isempty(pie_colors_file_path)
        load(pie_colors_file_path);
    else
        colors = small_utils_distinguishable_colors(numel(syls),'w');
    end
    syl_labels = mat2cell(syls',ones(numel(syls),1),1);
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

    % Now group the panels into one figure
    fh = figure('Position',[108 139 518.7402 518.7402]); 
    bgaxis = axes(fh,'Position',[0 0 1 1],'Color','w'); yticks(bgaxis,[]); xticks(bgaxis,[]); set(bgaxis,'YColor','none');  set(bgaxis,'XColor','none');
    xlim(bgaxis,[0 1]); ylim(bgaxis,[0 1]);
    aspect = 247/183; 
    figc = [0.5 0.5]; %[0.25 0.75];
    pandim = 0.05;
    d_leaves = [0.12 0.05 0.05 0.04 0.04 0.04];
    maxp = max(freqs);
    maxw = pandim;
    maxh = pandim;
    %degs = fliplr(degrees);
    numbranches = sum(degrees == 1);
    degbranches = 0:2*pi/numbranches:2*pi-2*pi/numbranches;
    l1loc = [find(degrees == 1);numel(degrees)];
    cnt = 1;
    for branchn = 1:numbranches
        new_panel = copyobj(hndls(cnt),fh); 
        scale_factor = (freqs(cnt)/maxp)^(1/3);
        cnt = cnt+1; 
        nw = maxw * scale_factor;
        nh = maxh * scale_factor;
        branchpos1 = figc-pandim+d_leaves(1)*[cos(degbranches(branchn)) sin(degbranches(branchn))]; 
        new_panel.Position = [branchpos1 nw nh]; %pandim pandim];
        l1center = branchpos1 + [nw nh]/2;
        %numl2 = sum(degreesclose all(l1loc(branchn):l1loc(branchn+1)) == 2);
        l2loc = [intersect(find(degrees == 2),l1loc(branchn):l1loc(branchn+1)); l1loc(branchn+1)];
        numl2 = numel(l2loc)-1;
        degl2 = ([1:numl2]-1)*pi/2.5/(numl2+1e-7);
        for l2n = 1:numl2
            new_panel = copyobj(hndls(cnt),fh); 
            scale_factor = (freqs(cnt)/maxp)^(1/3);
            nw = maxw * scale_factor;
            nh = maxh * scale_factor;
            cnt = cnt+1;
            currdeg = degbranches(branchn) + degl2(l2n) - mean(degl2);
            branchpos2 = branchpos1 + ...
                d_leaves(2)*[cos(currdeg) sin(currdeg)]; 
            l2center = branchpos2 + [nw nh]/2;
            line(bgaxis,[l1center(1) l2center(1)],[l1center(2) l2center(2)],'Color','k','LineWidth',0.5);
            new_panel.Position = [branchpos2 nw nh]; %pandim pandim];
            l3loc = [intersect(find(degrees == 3),l2loc(l2n):l2loc(l2n+1)); l2loc(l2n+1)];
            numl3 = numel(l3loc)-1;
            degl3 = ([1:numl3]-1)*pi/2.5/(numl3+1e-7);
            for l3n = 1:numl3
                new_panel = copyobj(hndls(cnt),fh); 
                scale_factor = (freqs(cnt)/maxp)^(1/3);
                nw = maxw * scale_factor;
                nh = maxh * scale_factor;
                cnt = cnt+1;
                currdeg = degbranches(branchn) + degl2(l2n) - mean(degl2) + ...
                    degl3(l3n) - mean(degl3);
                branchpos3 = branchpos2 +...
                    d_leaves(3)*[cos(currdeg) sin(currdeg)]; 
                new_panel.Position = [branchpos3 nw nh]; %pandim pandim];
                l3center = branchpos3 + [nw nh]/2;
                line(bgaxis,[l2center(1) l3center(1)],[l2center(2) l3center(2)],'Color','k','LineWidth',0.5);
                l4loc = [intersect(find(degrees == 4),l3loc(l3n):l3loc(l3n+1)); l3loc(l3n+1)];
                numl4 = numel(l4loc)-1;
                degl4 = ([1:numl4]-1)*pi/2.5/(numl4+1e-7);
                for l4n = 1:numl4
                    new_panel = copyobj(hndls(cnt),fh); 
                    scale_factor = (freqs(cnt)/maxp)^(1/3);
                    nw = maxw * scale_factor;
                    nh = maxh * scale_factor;
                    cnt = cnt+1;
                    currdeg = degbranches(branchn) + degl2(l2n) - mean(degl2) + ...
                        degl3(l3n) - mean(degl3) + degl4(l4n) - mean(degl4);
                    branchpos4 = branchpos3 +...
                        d_leaves(4)*[cos(currdeg) sin(currdeg)]; 
                    new_panel.Position = [branchpos4 nw nh]; %pandim pandim];
                    l4center = branchpos4 + [nw nh]/2;
                    line(bgaxis,[l3center(1) l4center(1)],[l3center(2) l4center(2)],'Color','k','LineWidth',0.5);
                    l5loc = [intersect(find(degrees == 5),l4loc(l4n):l4loc(l4n+1)); l4loc(l4n+1)];
                    numl5 = numel(l5loc)-1;
                    degl5 = ([1:numl5]-1)*pi/2.5/(numl5+1e-7);
                    for l5n = 1:numl5
                        new_panel = copyobj(hndls(cnt),fh); 
                        scale_factor = (freqs(cnt)/maxp)^(1/3);
                        nw = maxw * scale_factor;
                        nh = maxh * scale_factor;
                        cnt = cnt+1;
                        currdeg = degbranches(branchn) + degl2(l2n) - mean(degl2) + ...
                            degl3(l3n) - mean(degl3) + degl4(l4n) - mean(degl4) + ...
                            degl5(l5n) - mean(degl5);
                        branchpos5 = branchpos4 +...
                            d_leaves(5)*[cos(currdeg) sin(currdeg)]; 
                        new_panel.Position = [branchpos5 nw nh]; %pandim pandim];
                        l5center = branchpos5 + [nw nh]/2;
                        line(bgaxis,[l4center(1) l5center(1)],[l4center(2) l5center(2)],'Color','k','LineWidth',0.5);

                        l6loc = [intersect(find(degrees == 6),l5loc(l5n):l5loc(l5n+1)); l5loc(l5n+1)];
                        numl6 = numel(l6loc)-1;
                        degl6 = ([1:numl6]-1)*pi/2.5/(numl6+1e-7);
                        for l6n = 1:numl6
                            new_panel = copyobj(hndls(cnt),fh); 
                            scale_factor = (freqs(cnt)/maxp)^(1/3);
                            nw = maxw * scale_factor;
                            nh = maxh * scale_factor;
                            cnt = cnt+1;
                            currdeg = degbranches(branchn) + degl2(l2n) - mean(degl2) + ...
                                degl3(l3n) - mean(degl3) + degl4(l4n) - mean(degl4) + ...
                                degl5(l5n) - mean(degl5) + degl6(l6n) - mean(degl6);
                            branchpos6 = branchpos5 +...
                                d_leaves(6)*[cos(currdeg) sin(currdeg)]; 
                            new_panel.Position = [branchpos6 nw nh]; %pandim pandim];
                            l6center = branchpos6 + [nw nh]/2;
                            line(bgaxis,[l5center(1) l6center(1)],[l5center(2) l6center(2)],'Color','k','LineWidth',0.5);
                        end
                    end
                end
            end
        end
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