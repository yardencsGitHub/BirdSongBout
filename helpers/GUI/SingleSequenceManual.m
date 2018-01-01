function SingleSequenceManual(DIR,annotation_filename,template_filename)
%%
    window_positions = [5.1667   71.7333  140.8333   20.2667; ...
                        883        1019        1660         313; ...
                        116         691        2385         254; ...
                        116          94        2385         518];
    % Day = '2017_06_28';
    % sylnum = 8;
    tmpthr=0;
    win_size = 1;
    max_win_size = 3;
    t_step = 0.5;
    FS = 48000;
    fmax = 8000;
    text_height = 8250;
    min_gap = 0.005;
    min_syl = 0.005;
    map_caxis = [0 5];
    h_params = ParamsDialog('Position',window_positions(1,:));
    params_handles = get(h_params,'UserData');
    params_handles.MinGap.String = num2str(min_gap);
    params_handles.MinSyl.String = num2str(min_syl);
    params_handles.StepSize.String = num2str(t_step);
    params_handles.caxis_min.String = num2str(map_caxis(1));
    params_handles.caxis_max.String = num2str(map_caxis(2));
    params_handles.dir_name.String = DIR;
    %%
    cd (DIR);
    wav_files = dir('*.wav');
    
    if exist(template_filename)
        load(template_filename,'templates');
        syllables = [[templates.wavs.segType] -1]; 
    else
        syllables = [-1 102 103];
    end
    tmp = {}; 
    for ii = 1:numel(syllables)
        tmp = {tmp{:} num2str(syllables(ii))};
    end    
    params_handles.SylTags.String = tmp;
    n_syllables = numel(syllables);
    freq_min = 300; freq_max = 8000;
    colors = distinguishable_colors(n_syllables,'w');
    if exist(annotation_filename)
        load(annotation_filename,'keys','elements');
        filename = keys{1};
        params_handles.file_name.String = filename;
        params_handles.file_list.String = keys;
        ord = [];
        dates = [];
        times = [];
        phrase_durations = [];
        file_loc_in_keys = find(strcmp(keys,filename));
        if isempty(file_loc_in_keys)
            keys = {keys{:} filename};
            expr = elements{1}.exper;
            base_struct = struct('exper',expr, ...
                             'filenum',sprintf('%04d',numel(elements)+1), ...
                             'segAbsStartTimes',[], ...
                             'segFileStartTimes',[], ...
                             'segFileEndTimes',[], ...
                             'segType',[], ...
                             'fs',FS, ...
                             'drugstatus', 'No Drug', ...
                             'directstatus', 'Undirected');
            elements = [elements; base_struct];
        end
        for i = 1:numel(keys)
            tokens = regexp(keys{i},'_','split');
            ord = [ord; str2num(tokens{2})];
            dates = [dates; char(join(tokens(3:5),'_'))];
             
        end
        [locs,indx] = sort(ord);
        elements = elements(indx);
        keys = keys(indx);
        dates = dates(indx,:);
        file_loc_in_keys = find(strcmp(keys,filename));
        unique_dates = datestr(setdiff(unique(datenum(dates)),[736804]),'yyyy_mm_dd'); %does not include 04/19-21th (remove for other birds)
    else
        bird_exper_name = input('Type bird name: ');
        exper = struct('birdname',bird_exper_name,'expername','Recording from Canary',...
            'desiredInSampRate',48000,'audioCh',0','sigCh',[],'datecreated',date,'researcher','YC');
        elements = struct('exper',expr, ...
                             'filenum','0001', ...
                             'segAbsStartTimes',[], ...
                             'segFileStartTimes',[], ...
                             'segFileEndTimes',[], ...
                             'segType',[], ...
                             'fs',FS, ...
                             'drugstatus', 'No Drug', ...
                             'directstatus', 'Undirected');
          
    end
%%
    gr_lines = [];
    rd_lines = [];
    curr_active = -1;
    current_label = -1;
    filename = keys{1};
    [y,fs] = audioread(fullfile(DIR,filename));
    tmin = 0;
    tmax = numel(y)/fs;
    [S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),220,220-44,512,fs);%,'reassigned');
    if ~isempty(elements{file_loc_in_keys}.segType)
        phrases = return_phrase_times(elements{file_loc_in_keys});
    else
        phrases = [];
    end
    % create map
    h_map = figure('Position',window_positions(2,:)); 
    axes_map = axes;
    plot_full_amplitude_envelope(axes_map);
    set(axes_map,'Position',[[0.01 0.1 0.98 0.85]]); 
    set(axes_map,'YTick',[]);
    xlim([tmin tmax]);
    
    
    tonset = 0;
    toffset = win_size;
    h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<fmax & F>0,:)))))]);
    h_temp = figure('Position',window_positions(3,:)); 
    ax_temp = axes;
    plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))));
    plot_full_amplitude_envelope(ax_temp);
    xlim([tonset toffset]);
    if (tmpthr == 0)
        tmpthr = quantile(log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))),0.1);
    end
    h_line = imline(ax_temp,[tonset tmpthr; toffset tmpthr]);
    pause;
    thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
    tmpthr = thr;
    
        %T >= tonset & T<=toffset (T >= tonset & T<=toffset)
    [on_times,off_times] = syllable_envelope(log(sum(abs(S(F<fmax & F>0,:)))),T,thr,min_gap,min_syl);
    % prepare mock syllables for auto positioning
    mock_offs = off_times(off_times > on_times(1));
    mock_ons = on_times(on_times < mock_offs(end));
    mock_centers = (mock_offs+mock_ons)/2;
    %

    hf=figure('Position',window_positions(4,:));
    ax = axes;
    draw_spec(ax);
    
    
    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
    
    set(hf,'WindowbuttonDownFcn',@clickcallback)
    set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
    drawnow;
    
%%%%%%%%%%%%%%%%% functions
    function draw_spec(axes_handle) %(T >= tonset & T<=toffset) T >= tonset & T<=toffset
        imagesc(axes_handle,T,F(F<fmax),abs(S(F<fmax,:))); colormap(1-gray); caxis(map_caxis); xlim([tonset toffset]);
        axes(axes_handle);
        set(gca,'YDir','normal');
        hold on; 
        for i = 1:numel(gr_lines)
            delete(gr_lines(i));
        end
        for i = 1:numel(rd_lines)
            delete(rd_lines(i));
        end
        [gr_lines rd_lines] = draw_lines(axes_handle);
    end

    function [gr_lines rd_lines] = draw_lines(axes_handle)
        gr_lines = [];
        rd_lines = [];
        for line_cnt = 1:numel(on_times)
            h = line([on_times(line_cnt) on_times(line_cnt)],[0 fmax],'Color',[0 0.7 0]);
            gr_lines = [gr_lines;h];
        end
        for line_cnt = 1:numel(off_times)
            h = line([off_times(line_cnt) off_times(line_cnt)],[0 fmax],'Color',[0.7 0 0]);
            rd_lines = [rd_lines;h];
        end
    end

    function clickcallback(obj,evt)
        hd = get(obj,'Children');
        persistent chk
        if isempty(chk)
              chk = 1;
              pause(0.5); %Add a delay to distinguish single click from a double click
              if chk == 1
                  %fprintf(1,'\nI am doing a single-click.\n\n');
                  chk = [];
              end
              mouse_loc = get(hd(end),'CurrentPoint');
              xpos = mouse_loc(1,1); ypos = mouse_loc(1,2);
              if (xpos > tonset & xpos < toffset)
                  for syl_cnt = 1:numel(current_syllables) %start_syl:min(start_syl+numel(hs)-1,numel(syl_idx))
                        %syl_cnt = syl_num - start_syl+1;
                        currpos = get_pos(syl_cnt);    
                        maxx = currpos(1)+currpos(3);
                        minx = currpos(1);
                        if (xpos > minx & xpos < maxx)
                            if (current_syllables(syl_cnt) ~= curr_active)
                                prev_active = find(current_syllables == curr_active);
                               
                                %if ~isempty(prev_active)
% % %                                     curr_active_handle = imrect(ax,[elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt)) ...
% % %                                      0 elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt)) - ...
% % %                                      elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt)) fmax]);
% % %                                     hs ={hs{:} curr_active_handle};
% % %                                     textpos = getPosition(curr_active_handle);
% % %                                     h = text(axes_handle,textpos(1)+textpos(3)/2,text_height,num2str(elements{file_loc_in_keys}.segType(current_syllables(syl_cnt))),...
% % %                                         'Units','data','HorizontalAlignment','center','FontSize',24, ...
% % %                                         'Color', colors(find(syllables == elements{file_loc_in_keys}.segType(current_syllables(syl_cnt))),:));
% % %                                     set(curr_active_handle,'UserData', h);
% % %                                     id = addNewPositionCallback(curr_active_handle,@(pos)set(get(curr_active_handle,'UserData'),'Position',[pos(1)+pos(3)/2 text_height 0]));
% % %                                     % result_hs{end}
% % %                                 
                                    
                                    %cellfun(@delete,hs);
                                    update_elements;
                                    curr_active = current_syllables(syl_cnt);
                                    remove_syllables;
                                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                               % end         
                            end
                        end
                    end
                  
               end
        
         else
            
              chk = [];
              mouse_loc = get(hd(end),'CurrentPoint');
              xpos = mouse_loc(1,1); ypos = mouse_loc(1,2);
                  if (xpos > tonset & xpos < toffset)

                      for syl_cnt = 1:numel(current_syllables) 
                            currpos = get_pos(syl_cnt);    
                            maxx = currpos(1)+currpos(3);
                            minx = currpos(1);
                            if (xpos > minx & xpos < maxx)                           
                                rectpos = get_pos(syl_cnt);
                                rec_center = rectpos(1) + rectpos(3)/2;
                                mock_dist = abs(mock_centers - rec_center);
                                mock_loc = min(find(mock_dist == min(mock_dist)));
                                targetx = [mock_ons(mock_loc) mock_offs(mock_loc)];
                                numtags = setdiff(1:numel(elements{file_loc_in_keys}.segType),current_syllables(syl_cnt)) ;
                                if ~any((elements{file_loc_in_keys}.segFileStartTimes(numtags) < targetx(2)) & ...
                                        (elements{file_loc_in_keys}.segFileEndTimes(numtags) > targetx(1)))
                                    set_pos(syl_cnt,[mock_ons(mock_loc) rectpos(2) (mock_offs(mock_loc)-mock_ons(mock_loc)) rectpos(4)]);
                                end
                            end
                      end
                      update_elements;
                  end
              %fprintf(1,'\nI am doing a double-click.\n\n');
        end
    end

    function keystroke(h_obj,evt)
        
        disp(evt.Key);
        hd = get(h_obj,'Children');
        mouse_loc = get(hd(end),'CurrentPoint');
        xpos = mouse_loc(1,1); ypos = mouse_loc(1,2);
        disp([xpos ypos]);
        switch evt.Key
            case 'f'
                range_rect = getrect(ax); 
                tonset = range_rect(1);
                toffset = range_rect(1)+range_rect(3);
                setPosition(h_rect,[tonset min(log(sum(abs(S(F<fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<fmax & F>0,:)))))]);
                axes(ax);
                remove_syllables;
                xlim([tonset toffset]);  
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                axes(ax_temp);
                
                xlim([tonset toffset]);
                thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                delete(h_line);
                h_line = imline(ax_temp,[tonset tmpthr; toffset tmpthr]);
                axes(ax);
                
            case 'p'
                time_stamps = [1:numel(y)]/fs -1/fs;
               soundsc(y(time_stamps >= tonset & time_stamps <= toffset),fs);
               
            case 'g'
                for syl_cnt = 1:numel(current_syllables) 
                        currpos = get_pos(syl_cnt);    
                                                 
                        rectpos = get_pos(syl_cnt);
                        rec_center = rectpos(1) + rectpos(3)/2;
                        mock_dist = abs(mock_centers - rec_center);
                        mock_loc = min(find(mock_dist == min(mock_dist)));
                        targetx = [mock_ons(mock_loc) mock_offs(mock_loc)];
                        numtags = setdiff(1:numel(elements{file_loc_in_keys}.segType),current_syllables(syl_cnt)) ;
                        if ~any((elements{file_loc_in_keys}.segFileStartTimes(numtags) < targetx(2)) & ...
                                (elements{file_loc_in_keys}.segFileEndTimes(numtags) > targetx(1)))
                            set_pos(syl_cnt,[mock_ons(mock_loc) rectpos(2) (mock_offs(mock_loc)-mock_ons(mock_loc)) rectpos(4)]);
                        end
                        
                 end
                      update_elements;
            case 'u'
                min_gap = str2num(params_handles.MinGap.String);
                min_syl = str2num(params_handles.MinSyl.String);
                t_step = str2num(params_handles.StepSize.String);
                old_caxis = map_caxis;
                map_caxis = [str2num(params_handles.caxis_min.String) str2num(params_handles.caxis_max.String)];
                if (sum(abs(old_caxis-map_caxis)) ~= 0)
                    caxis(ax,map_caxis);
                end
                posflag = 0;
                update_elements;
                newpos = getPosition(h_rect);
                new_tonset = newpos(1); new_toffset = newpos(1)+newpos(3);
                if (new_tonset ~= tonset | new_toffset ~= toffset)
                    posflag = 1;
                    tonset = new_tonset; toffset = new_toffset;
                end
                win_size = toffset-tonset;
                thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                thrflag = 1;
                %if (tmpthr ~= thr)
                    thrflag = 1;
                    tmpthr = thr;
                    [on_times,off_times] = syllable_envelope(log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))),T(T >= tonset & T<=toffset),thr,min_gap,min_syl);
                    % prepare mock syllables for auto positioning
                    mock_offs = off_times(off_times > on_times(1));
                    mock_ons = on_times(on_times < mock_offs(end));
                    mock_centers = (mock_offs+mock_ons)/2; 
                %end
                axes(ax);
                if (posflag == 1)
                    remove_syllables;
                    %cellfun(@delete,hs);
%                     for syl_cnt = 1:numel(current_syllables)
%                         delete(get(hs(syl_cnt),'UserData'));
%                         delete(hs(syl_cnt));
%                     end
%                     
%                         hold off;
%                         draw_spec(ax);
%                         hold on;
                    
                        xlim([tonset toffset]);  
                    
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                else
                     if thrflag == 1
                         %cellfun(@delete,hs);
                         remove_syllables;
                         delete(rd_lines); delete(gr_lines);
%                         for syl_cnt = 1:numel(current_syllables)
%                             delete(get(hs(syl_cnt),'UserData'));
%                             delete(hs(syl_cnt));
%                         end
%                          hold off;
%                         draw_spec(ax);
%                         hold on;
                        [gr_lines rd_lines] = draw_lines(ax);
                        [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                     end
                end
                
                

%                 set(hf,'WindowbuttonDownFcn',@clickcallback)
%                 set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
                drawnow;
                axes(ax_temp); %hold off;
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))));
                %plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                delete(h_line);
                h_line = imline(ax_temp,[tonset tmpthr; toffset tmpthr]);
                axes(ax);
            case 'x'
                update_elements;
                toffset = min(tmax,toffset+t_step); tonset = min([tonset+t_step,tmax-t_step,toffset-win_size]); 
                axes(ax); xlim([tonset toffset]);
%                 for syl_cnt = 1:numel(hs)
%                     delete(get(hs(syl_cnt),'UserData'));
%                     delete(hs(syl_cnt));
%                 end
                %cellfun(@delete,hs);
                remove_syllables;
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                drawnow;
                axes(ax_temp); %hold off;
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))));
                %plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                delete(h_line);
                h_line = imline(ax_temp,[tonset tmpthr; toffset tmpthr]);
                axes(ax);
                setPosition(h_rect,[tonset min(log(sum(abs(S(F<fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<fmax & F>0,:)))))]);
            case 'z'
                update_elements;
                tonset = max(tonset-t_step,tmin); toffset = max([tmin+t_step,toffset-t_step,tonset+win_size]);

                axes(ax); xlim([tonset toffset]);
                %cellfun(@delete,hs);
                remove_syllables;
%                 for syl_cnt = 1:numel(hs)
%                     delete(get(hs(syl_cnt),'UserData'));
%                     delete(hs(syl_cnt));
%                 end
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                drawnow;
                axes(ax_temp); %hold off;
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))));
                %plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                delete(h_line);
                h_line = imline(ax_temp,[tonset tmpthr; toffset tmpthr]);
                axes(ax);
                setPosition(h_rect,[tonset min(log(sum(abs(S(F<fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<fmax & F>0,:)))))]);
            case 'a'
                update_elements;
%                 rectpos = getPosition(hs(1)); minx = rectpos(1);
%                 rectpos = getPosition(hs(end)); maxx = rectpos(1)+rectpos(3);
                new_rect = getrect(ax);
                add_syllable(new_rect,-1);
                axes(ax);
                %cellfun(@delete,hs);
                remove_syllables;
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                    
                
%         end
            case 'n'
                 save(annotation_filename,'keys','elements');
                 hgclose(hf);
                 hgclose(h_temp);
                 hgclose(h_map);     
                 gr_lines = [];
                rd_lines = [];
                curr_active = -1;
                current_label = -1;
                filename = keys{params_handles.file_list.Value};
                params_handles.file_name.String = filename;
                if (find(strcmp(keys,filename)) ~= file_loc_in_keys)
                    file_loc_in_keys = find(strcmp(keys,filename));
                else
                    if (file_loc_in_keys < numel(keys))
                        file_loc_in_keys = file_loc_in_keys + 1;
                        filename = keys{file_loc_in_keys};
                        params_handles.file_list.Value = file_loc_in_keys;
                    end
                end
                [y,fs] = audioread(fullfile(DIR,filename));
                tmin = 0;
                tmax = numel(y)/fs;
                [S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),220,220-44,512,fs);%,'reassigned');
                if ~isempty(elements{file_loc_in_keys}.segType)
                    phrases = return_phrase_times(elements{file_loc_in_keys});
                else
                    phrases = [];
                end
                % create map
                h_map = figure('Position',window_positions(2,:)); 
                axes_map = axes;
                plot_full_amplitude_envelope(axes_map);
                set(axes_map,'Position',[[0.01 0.1 0.98 0.85]]); 
                set(axes_map,'YTick',[]);
                xlim([tmin tmax]);

                tonset = 0;
                toffset = win_size;
                h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<fmax & F>0,:)))))]);

                h_temp = figure('Position',window_positions(3,:)); 
                ax_temp = axes;
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))));
                plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                if (tmpthr == 0)
                    tmpthr = quantile(log(sum(abs(S(F<fmax & F>0,T >= tonset & T<=toffset)))),0.1);
                end
                h_line = imline(ax_temp,[tonset tmpthr; toffset tmpthr]);
                pause;
                thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                tmpthr = thr;

                    %T >= tonset & T<=toffset (T >= tonset & T<=toffset)
                [on_times,off_times] = syllable_envelope(log(sum(abs(S(F<fmax & F>0,:)))),T,thr,min_gap,min_syl);
                % prepare mock syllables for auto positioning
                mock_offs = off_times(off_times > on_times(1));
                mock_ons = on_times(on_times < mock_offs(end));
                mock_centers = (mock_offs+mock_ons)/2;
                %

                hf=figure('Position',window_positions(4,:)); 
                ax = axes;
                draw_spec(ax);


                [hs, current_syllables] = display_rects(ax,[tonset toffset]);

                set(hf,'WindowbuttonDownFcn',@clickcallback)
                set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
                drawnow;
                 
            case 'd'
                if (xpos > tonset & xpos < toffset)             
                  for syl_cnt = 1:numel(current_syllables) %start_syl:min(start_syl+numel(hs)-1,numel(syl_idx))
                    %syl_cnt = syl_num - start_syl+1;
                    rectpos = get_pos(syl_cnt);
                    maxx = rectpos(1)+rectpos(3);
                    minx = rectpos(1);
                    if (xpos > minx & xpos < maxx) 
                        if current_syllables(syl_cnt) <= curr_active
                            curr_active = curr_active - 1;
                        end
                        elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt)) = [];
                        elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt)) = [];
                        elements{file_loc_in_keys}.segAbsStartTimes(current_syllables(syl_cnt)) = [];
                        elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)) = [];
                        remove_syllables;
                        current_syllables(syl_cnt+1:end) = current_syllables(syl_cnt+1:end) - 1;
                        current_syllables(syl_cnt) = [];        
                        %cellfun(@delete,hs);
                        
                        [hs, current_syllables] = display_rects(ax,[tonset toffset]);
%                         delete(get(hs(syl_cnt),'UserData'));
%                         delete(hs(syl_cnt));
                        %hs(syl_cnt) = [];
                        break;
                    end
                  end
                end
            case 't' %tag
                if ismember(curr_active,current_syllables)
                    syl_cnt = find(current_syllables == curr_active);
                    taglist = cellfun(@str2num,params_handles.SylTags.String);
                    if numel(taglist ~= numel(syllables))
                        syllables = taglist;
                        n_syllables = numel(syllables);
                        colors = distinguishable_colors(n_syllables,'w');
                    end
                    current_label = syllables(params_handles.SylTags.Value);
                    elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)) = current_label;
                    %cellfun(@delete,hs);
                    remove_syllables;
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                end
% % %                 if (xpos > tonset & xpos < toffset)             
% % %                   for syl_cnt = 1:numel(current_syllables) %start_syl:min(start_syl+numel(hs)-1,numel(syl_idx))
% % %                     %syl_cnt = syl_num - start_syl+1;
% % %                     rectpos = get_pos(syl_cnt);
% % %                     maxx = rectpos(1)+rectpos(3);
% % %                     minx = rectpos(1);
% % %                     if (xpos > minx & xpos < maxx)                      
% % %                         taglist = cellfun(@str2num,params_handles.SylTags.String);
% % %                         if numel(taglist ~= numel(syllables))
% % %                             syllables = taglist;
% % %                             n_syllables = numel(syllables);
% % %                             colors = distinguishable_colors(n_syllables,'w');
% % %                         end
% % %                         current_label = syllables(params_handles.SylTags.Value);
% % %                         elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)) = current_label;
% % %                       
% % %                         %delete(hs(syl_cnt));
% % %                         
% % %                         break;
% % %                     end
% % %                   end
% % %                   for syl_cnt = 1:numel(hs)
% % %                     delete(get(hs(syl_cnt),'UserData'));
% % %                     delete(hs(syl_cnt));
% % %                   end
% % %                     [hs, current_syllables] = display_rects(ax,[tonset toffset]);
% % %                 end
            case 'b' % create threshold base boundaries
                taglist = cellfun(@str2num,params_handles.SylTags.String);
                if numel(taglist ~= numel(syllables))
                    syllables = taglist;
                    n_syllables = numel(syllables);
                    colors = distinguishable_colors(n_syllables,'w');
                end
                current_label = syllables(params_handles.SylTags.Value);
                mock_locs = find(mock_ons >= tonset & mock_offs <= toffset);
                for mock_cnt = 1:numel(mock_locs)
                    mock_loc = mock_locs(mock_cnt);
                    newrect = [mock_ons(mock_loc) 0 (mock_offs(mock_loc)-mock_ons(mock_loc)) fmax];
                    add_syllable(newrect,current_label);
                    axes(ax);
                    %cellfun(@delete,hs);
                    remove_syllables;
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                end
            case 'l'
                current_label = input('Label: '); 
            case 'j' % joint current with next. label is current
                if ismember(curr_active,current_syllables)
                    syl_cnt = find(current_syllables == curr_active);
                    taglist = cellfun(@str2num,params_handles.SylTags.String);
                    if numel(taglist ~= numel(syllables))
                        syllables = taglist;
                        n_syllables = numel(syllables);
                        colors = distinguishable_colors(n_syllables,'w');
                    end
                    current_label = syllables(params_handles.SylTags.Value);
                    if (current_syllables(syl_cnt) < numel(elements{file_loc_in_keys}.segType))
                        elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt)+1) = [];
                        elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt)) = ...
                            elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt)+1); 
                         elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt)+1) = [];
                        elements{file_loc_in_keys}.segAbsStartTimes(current_syllables(syl_cnt)+1) = [];
                        elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)+1) = [];
                    end
                    %elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)) = current_label;
                    %cellfun(@delete,hs);
                    remove_syllables;
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                end
        end
    end

    function [result_hs, syl_idx] = display_rects(axes_handle,time_window)
       result_hs = {};
       
       syl_idx = find(elements{file_loc_in_keys}.segFileStartTimes >= time_window(1) & ...
           elements{file_loc_in_keys}.segFileEndTimes <= time_window(2));
       
       for syl_num = 1:numel(syl_idx)
           if syl_idx(syl_num) == curr_active
               curr_active_handle = imrect(axes_handle,[elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) ...
                     0 elements{file_loc_in_keys}.segFileEndTimes(syl_idx(syl_num)) - ...
                     elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) fmax]);
                result_hs ={result_hs{:} curr_active_handle};
                textpos = getPosition(curr_active_handle);
                h = text(axes_handle,textpos(1)+textpos(3)/2,text_height,num2str(elements{file_loc_in_keys}.segType(syl_idx(syl_num))),...
                    'Units','data','HorizontalAlignment','center','FontSize',24, ...
                    'Color', colors(find(syllables == elements{file_loc_in_keys}.segType(syl_idx(syl_num))),:));
                set(curr_active_handle,'UserData', h);
                id = addNewPositionCallback(result_hs{end},@(pos)set(get(curr_active_handle,'UserData'),'Position',[pos(1)+pos(3)/2 text_height 0]));
           else
                h=rectangle(axes_handle,'Position',[elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) ...
                     0 elements{file_loc_in_keys}.segFileEndTimes(syl_idx(syl_num)) - ...
                     elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) fmax],'LineWidth',2,...
                     'EdgeColor',colors(find(syllables == elements{file_loc_in_keys}.segType(syl_idx(syl_num))),:));

                result_hs ={result_hs{:} h};
                textpos = get(result_hs{end},'Position');
                h = text(axes_handle,textpos(1)+textpos(3)/2,text_height,num2str(elements{file_loc_in_keys}.segType(syl_idx(syl_num))),...
                    'Units','data','HorizontalAlignment','center','FontSize',24, ...
                    'Color', colors(find(syllables == elements{file_loc_in_keys}.segType(syl_idx(syl_num))),:));
                set(result_hs{end},'UserData', h);
                %id = addNewPositionCallback(result_hs(end),@(pos)set(get(result_hs(end),'UserData'),'Position',[pos(1)+pos(3)/2 text_height 0]));
           end     
       end 
    end
    

    function update_elements
        for syl_num = 1:numel(current_syllables)
            currpos = get_pos(syl_num);    
            maxx = currpos(1)+currpos(3);
            minx = currpos(1);
            elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_num)) = minx;
            elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_num)) = maxx;
        end
    end

    function add_syllable(rect,syl_id)
        new_rec_minx = rect(1); new_rec_maxx = rect(1)+rect(3);          
%                 if (new_rec_minx < maxx & new_rec_minx > minx & new_rec_maxx < maxx & new_rec_maxx > minx)
        new_syl_loc = [];
        if isempty(elements{file_loc_in_keys}.segType)
                elements{file_loc_in_keys}.segFileStartTimes =  new_rec_minx;
                elements{file_loc_in_keys}.segAbsStartTimes = ...
                    getFileTime(filename) + elements{file_loc_in_keys}.segFileStartTimes/(24*60*60);
                elements{file_loc_in_keys}.segFileEndTimes = new_rec_maxx;
                elements{file_loc_in_keys}.segType = syl_id;
                axes(ax); %hold off;
                curr_active = 1;
                new_syl_loc = 1;
                %[hs, current_syllables] = display_rects(ax,[tonset toffset]);
        else
            if elements{file_loc_in_keys}.segFileEndTimes(end) < new_rec_minx
                new_syl_loc = numel(elements{file_loc_in_keys}.segType) + 1;
                curr_active = new_syl_loc;
            elseif elements{file_loc_in_keys}.segFileStartTimes(1) > new_rec_maxx
                new_syl_loc = 1;
                curr_active = 1;
            else            
                for syl_cnt = 1:numel(elements{file_loc_in_keys}.segType)-1
                    maxx = elements{file_loc_in_keys}.segFileStartTimes(syl_cnt+1);
                    minx = elements{file_loc_in_keys}.segFileEndTimes(syl_cnt);
                    if (new_rec_minx > minx & new_rec_maxx < maxx)
                        new_syl_loc = syl_cnt + 1;
                    end
                end
            end
        


            if ~isempty(new_syl_loc)
                syl_before = new_syl_loc - 1;
                
                %syl_before = max(find(elements{files_idx(file_cnt)}.segFileStartTimes < rect(1)));
                elements{file_loc_in_keys}.segFileStartTimes = ...
                    [elements{file_loc_in_keys}.segFileStartTimes(1:syl_before) new_rec_minx ...
                    elements{file_loc_in_keys}.segFileStartTimes(syl_before+1:end)];
                elements{file_loc_in_keys}.segAbsStartTimes = ...
                    getFileTime(filename) + elements{file_loc_in_keys}.segFileStartTimes/(24*60*60);
                elements{file_loc_in_keys}.segFileEndTimes = ...
                    [elements{file_loc_in_keys}.segFileEndTimes(1:syl_before) new_rec_maxx ...
                    elements{file_loc_in_keys}.segFileEndTimes(syl_before+1:end)];
                elements{file_loc_in_keys}.segType = ...
                    [elements{file_loc_in_keys}.segType(1:syl_before); syl_id; ...
                    elements{file_loc_in_keys}.segType(syl_before+1:end)];

                %phrases = return_phrase_times(elements{file_loc_in_keys});
                %tonset = phrases.phraseFileStartTimes(locs(cnt));
                %toffset = phrases.phraseFileEndTimes(locs(cnt));
               
                %set(hf,'WindowbuttonDownFcn',@clickcallback)
                %set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));

            end
        end
    end
    

    function remove_syllables
        for syl_cnt = 1:numel(current_syllables)
            delete(get(hs{syl_cnt},'UserData'));
        end
        cellfun(@delete,hs); 
    end

    function time = getFileTime(filename)
        strparts = regexp(filename,'_', 'split');
        y = str2double(strparts{3});
        m = str2double(strparts{4});
        d = str2double(strparts{5});
        th = str2double(strparts{6});
        tm = str2double(strparts{7});
        time = datenum(y,m,d,th,tm,0);
    end

    function pos = get_pos(syl_cnt_in_idx)
        if (current_syllables(syl_cnt_in_idx) == curr_active)
            pos = getPosition(hs{syl_cnt_in_idx});
        else
            pos = get(hs{syl_cnt_in_idx},'Position');
        end
    end
    
    function set_pos(syl_cnt_in_idx,pos)
        if (current_syllables(syl_cnt_in_idx) == curr_active)
            setPosition(hs{syl_cnt_in_idx},pos);
        else
            set(hs{syl_cnt_in_idx},'Position',pos);
        end
    end

    function plot_full_amplitude_envelope(target_axes_handle)
        if isempty(phrases)
            plot(target_axes_handle,T,log(sum(abs(S(F<fmax & F>0,:)))));
        else
            logS = log(sum(abs(S(F<fmax & F>0,:))));
            plot(target_axes_handle,T(T <= phrases.phraseFileStartTimes(1)),logS(T <= phrases.phraseFileStartTimes(1)),'Color',[0.5 0.5 0.5],'LineStyle',':');
            hold on;
            plot(target_axes_handle,T(T >= phrases.phraseFileEndTimes(end)),logS(T >= phrases.phraseFileEndTimes(end)),'Color',[0.5 0.5 0.5],'LineStyle',':');
            for phrasenum = 1:numel(phrases.phraseType)
                plot(target_axes_handle,T(T >= phrases.phraseFileStartTimes(phrasenum) & T <= phrases.phraseFileEndTimes(phrasenum)), ...
                    logS(T >= phrases.phraseFileStartTimes(phrasenum) & T <= phrases.phraseFileEndTimes(phrasenum)), ...
                    'Color',colors(find(syllables == phrases.phraseType(phrasenum)),:));
                if (phrasenum < numel(phrases.phraseType))
                    plot(target_axes_handle,T(T >= phrases.phraseFileEndTimes(phrasenum) & T <= phrases.phraseFileStartTimes(phrasenum+1)), ...
                        logS(T >= phrases.phraseFileEndTimes(phrasenum) & T <= phrases.phraseFileStartTimes(phrasenum+1)), ...
                        'Color',[0.5 0.5 0.5],'LineStyle',':');
                end
            end
            ylim([min(logS) max(logS)]);
        end
    end

end