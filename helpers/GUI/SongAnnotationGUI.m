function SongAnnotationGUI(varargin)
   
    

    settings_file_path = pwd; %'/Users/yardenc/Documents/GitHub/BirdSongBout/helpers/GUI/';
    %settings_file_path = '/Users/yardenc/Documents/GitHub/BirdSongBout/helpers/GUI';
    settings_file_name = 'BoutAnnotation_settings_file.mat';
    spectrogram_type = 'regular';
    nparams=length(varargin);
    for i_ind=1:2:nparams
        switch lower(varargin{i_ind})
            case 'settings_file_path'
                settings_file_path=varargin{i_ind+1};
            case 'spectrogram_type'
                spectrogram_type=varargin{i_ind+1};
        end
    end
    
    full_setting_path = fullfile(settings_file_path,settings_file_name);
    
    if exist(fullfile(settings_file_path,settings_file_name))
        load(fullfile(settings_file_path,settings_file_name),'settings_params')
    else
        settings_params.window_positions = [5.1667   71.7333  140.8333   20.2667; ...
                            883        1019        1660         313; ...
                            116         691        2385         254; ...
                            116          94        2385         518];
        settings_params.tmpthr = 0;
        settings_params.win_size = 1;
        %settings_params.win_size = 3;
        settings_params.t_step = 0.5;
        [tmp_wav_file, tmp_path, ~] = uigetfile('*.wav', 'Choose WAV file');
        [~,settings_params.FS] = audioread(fullfile(tmp_path,tmp_wav_file));
        settings_params.fmax = 8000;
        settings_params.text_height = 8250;
        settings_params.min_gap = 0.005;
        settings_params.min_syl = 0.005;
        settings_params.map_caxis = [0 3];
        settings_params.fmin = 500;  
        settings_params.fmax = 12000;
        save(fullfile(settings_file_path,settings_file_name),'settings_params');
    end
    switch spectrogram_type
        case 'multitaper_deriv'
            settings_params.map_caxis = [-2 2];
        otherwise
            settings_params.map_caxis = [0 3];
    end
    h_params = ParamsDialog('Position',settings_params.window_positions(1,:));
    params_handles = get(h_params,'UserData');
    %% get working directory .. wait for it
    params_handles.dir_name.UserData = 0;
    uiwait(h_params);
%     while flag == 0
%        '*'; 
%        params_handles = get(h_params,'UserData');
%        flag = params_handles.dir_name.UserData;
%     end
    %DIR = pwd;
    %addpath(DIR);
    %cd (DIR);
    DIR = params_handles.dir_name.String; %cd(DIR);
    wav_files = dir(fullfile(DIR,'*.wav'));
    
    annotation_filename = params_handles.annotation_filename.String;
    template_filename = params_handles.templates_filename.String;
    params_handles.MinGap.String = num2str(settings_params.min_gap);
    params_handles.MinSyl.String = num2str(settings_params.min_syl);
    params_handles.StepSize.String = num2str(settings_params.t_step);
    params_handles.caxis_min.String = num2str(settings_params.map_caxis(1));
    params_handles.caxis_max.String = num2str(settings_params.map_caxis(2));
    params_handles.dir_name.String = DIR;
    params_handles.freq_min.String = num2str(settings_params.fmin);
    params_handles.freq_max.String = num2str(settings_params.fmax);
    params_handles.delete_tag_button.UserData = 0;
    
    
    %%
    
    
    if exist(fullfile(DIR,template_filename))
        load(fullfile(DIR,template_filename),'templates');
        if ~ismember(-1,[templates.wavs.segType])
            syllables = [[templates.wavs.segType] -1]; 
        else
            syllables = [templates.wavs.segType];
        end
    else
        syllables = [1 -1];
    end
    
    tmp = {}; 
    for ii = 1:numel(syllables)
        tmp = {tmp{:} num2str(syllables(ii))};
    end    
    params_handles.SylTags.String = tmp;
    n_syllables = numel(syllables);
    freq_min = 300; freq_max = 8000;
    colors = GUI_distinguishable_colors(n_syllables,'w');
    if exist(fullfile(DIR,annotation_filename))
        load(fullfile(DIR,annotation_filename),'keys','elements');
        filename = keys{1};
        params_handles.file_name.String = filename;
        params_handles.file_list.String = keys;
        params_handles.file_list.UserData = elements;
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
                             'settings_params.FS',settings_params.FS, ...
                             'drugstatus', 'No Drug', ...
                             'directstatus', 'Undirected');
            elements = [elements; base_struct];
        end
        for i_ind = 1:numel(keys)
            tokens = regexp(keys{i_ind},'_','split');
            ord = [ord; str2num(tokens{2})];
            dates = [dates; char(join(tokens(3:5),'_'))];
             
        end
        [locs,indx] = sort(ord);
        elements = elements(indx);
        keys = keys(indx);
        dates = dates(indx,:);
        file_loc_in_keys = find(strcmp(keys,filename));
        
        %unique_dates = datestr(setdiff(unique(datenum(dates)),[736804]),'yyyy_mm_dd'); %does not include 04/19-21th (remove for other birds)
    else
        bird_exper_name = input('Type bird name: ','s');
        [y,fs] = audioread(fullfile(DIR,wav_files(1).name));
        exper = struct('birdname',bird_exper_name,'expername','Recording from Canary',...
            'desiredInSampRate',fs,'audioCh',0','sigCh',[],'datecreated',date,'researcher','YC');
        
        [keys, elements, templates] = GUI_create_empty_elements(DIR,bird_exper_name,exper);
        annotation_filename = input('Type ANNOTATION file name: ','s');
        if ~strcmp(annotation_filename(end-3:end),'.mat')
            annotation_filename = [annotation_filename '.mat'];
        end
        save(fullfile(DIR,annotation_filename),'keys','elements');
        template_filename = input('Type TEMPLATE file name: ','s');
        if ~strcmp(template_filename(end-3:end),'.mat')
            template_filename = [template_filename '.mat'];
        end
        save(fullfile(DIR,template_filename),'templates');
        file_loc_in_keys = 1;
        filename = keys{1};
        params_handles.file_name.String = filename;
        params_handles.file_list.String = keys;
        ord = [];
        dates = [];

     
        for i_ind = 1:numel(keys)
            tokens = regexp(keys{i_ind},'_','split');
            ord = [ord; str2num(tokens{2})];
            dates = [dates; char(join(tokens(3:5),'_'))];
             
        end
        [locs,indx] = sort(ord);
        elements = elements(indx);
        keys = keys(indx);
        dates = dates(indx,:);
        file_loc_in_keys = find(strcmp(keys,filename));
          
    end
    params_handles.show_button.UserData = templates;
%%
    gr_lines = [];
    rd_lines = [];
    curr_active = -1;
    current_label = -1;
    filename = keys{1};
    [y,settings_params.FS] = audioread(fullfile(DIR,filename));
    tmin = 0;
    tmax = numel(y)/settings_params.FS;
    %[S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),220,220-44,512,settings_params.FS);%,'reassigned');
    [S,F,T,P] = mt_spectrogram((y/(sqrt(mean(y.^2)))),settings_params.FS,1,'nfft',512);
    if ~isempty(elements{file_loc_in_keys}.segType)
        phrases = GUI_return_phrase_times(elements{file_loc_in_keys});
    else
        phrases = [];
    end
    % create map
    h_map = figure('Position',settings_params.window_positions(2,:)); 
    axes_map = axes;
    plot_full_amplitude_envelope(axes_map);
    set(axes_map,'Position',[0.01 0.15 0.98 0.8]); 
    set(axes_map,'YTick',[]);
    xlim([tmin tmax]);
    set(axes_map,'FontSize',14);
    xlabel(axes_map,'Time (sec)');
    
    tonset = 0;
    toffset = settings_params.win_size;
    h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))))]);
    h_temp = figure('Position',settings_params.window_positions(3,:)); 
    ax_temp = axes;
    %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))));
    plot_full_amplitude_envelope(ax_temp);
    xlim([tonset toffset]);
    set(ax_temp,'YTick',[]);
    set(ax_temp,'FontSize',14);
    xlabel(ax_temp,'Time (sec)');
    if (settings_params.tmpthr ~= -100)
        settings_params.tmpthr = quantile(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,T >= tonset & T<=toffset)))),0.1);
    end
    h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
    pause;
    thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
    settings_params.tmpthr = thr;
    
        %T >= tonset & T<=toffset (T >= tonset & T<=toffset)
    [on_times,off_times] = GUI_syllable_envelope(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))),T,thr,settings_params.min_gap,settings_params.min_syl);
    % prepare mock syllables for auto positioning
    mock_ofsettings_params.FS = off_times(off_times > on_times(1));
    mock_ons = on_times(on_times < mock_ofsettings_params.FS(end));
    mock_centers = (mock_ofsettings_params.FS+mock_ons)/2;
    %

    hf=figure('Position',settings_params.window_positions(4,:));
    ax = axes;
    draw_spec(ax);
    set(ax,'FontSize',14);
    xlabel(ax,'Time (sec)');
    ylabel(ax,'Frequency (Hz)');
    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
    
    set(hf,'WindowbuttonDownFcn',@clickcallback)
    set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
    drawnow;
    window_handles = {params_handles h_map h_temp hf};
    params_handles.save_settings.UserData = {settings_params window_handles full_setting_path};
%%%%%%%%%%%%%%%%% functions
    function [S,F,T,P] = mt_spectrogram(sig_in,samplerate,time_step_ms,varargin)
        switch spectrogram_type
            case 'regular'
                [S,F,T,P] = spectrogram(sig_in,220,220-44,512,settings_params.FS);
                return
            
            otherwise
                % will use Slepian tapers
                NW = 4;
                nfft = 1024;
                
                nparams=length(varargin);
                for i_ind=1:2:nparams
	                switch lower(varargin{i_ind})
		                case 'nw'
                            NW = varargin{i_ind+1};
                        case 'nfft'
                            nfft = varargin{i_ind+1};
                    end
                end
                noverlap = nfft - round(time_step_ms/1000*samplerate);
                if noverlap < 0
                    disp('overlap cannot be negative');
                    return
                end
                [E,V] = dpss(nfft,NW);
                [S1,F,T] = spectrogram(sig_in,E(:,1),noverlap,nfft,samplerate);
                [S2,F,T] = spectrogram(sig_in,E(:,2),noverlap,nfft,samplerate);
                S = S1.*conj(S1)+S2.*conj(S2);
                dx = -real(S1.*conj(S2));
                dy = real(1i*(S1.*conj(S2)));
                fm = atan(max(dx(F>=settings_params.fmin))./max(dy(F>=settings_params.fmin))+eps);
                P = repmat(cos(fm),length(F),1).*dx + repmat(sin(fm),length(F),1).*dy;
        end
    end

    function draw_spec(axes_handle) %(T >= tonset & T<=toffset) T >= tonset & T<=toffset
        
        switch spectrogram_type
            case 'regular'
                imagesc(axes_handle,T,F(F<settings_params.fmax & F>settings_params.fmin),log(1+abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))); 
                caxis(settings_params.map_caxis); 
            case 'multitaper_psd'
                imagesc(axes_handle,T,F(F<settings_params.fmax & F>settings_params.fmin),log(1+abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))); 
                caxis(settings_params.map_caxis); 
            case 'multitaper_deriv'
                P_temp = P(F<settings_params.fmax & F>settings_params.fmin,:);
                %P_temp = log(1+abs(P_temp.*(P_temp>=0)))-log(1+abs(P_temp.*(P_temp<0)));
                imagesc(axes_handle,T,F(F<settings_params.fmax & F>settings_params.fmin),P_temp); 
                caxis(settings_params.map_caxis);
        end
        colormap( 1-gray); 
        
        xlim([tonset toffset]);
        axes(axes_handle);
        set(gca,'YDir','normal');
        hold on; 
        for i_ind = 1:numel(gr_lines)
            delete(gr_lines(i_ind));
        end
        for i_ind = 1:numel(rd_lines)
            delete(rd_lines(i_ind));
        end
        [gr_lines rd_lines] = draw_lines(axes_handle);
        ylim([settings_params.fmin settings_params.fmax]);
    end

    function [gr_lines rd_lines] = draw_lines(axes_handle)
        gr_lines = [];
        rd_lines = [];
        for line_cnt = 1:numel(on_times)
            h = line([on_times(line_cnt) on_times(line_cnt)],[0 settings_params.fmax],'Color',[0 0.7 0]);
            gr_lines = [gr_lines;h];
        end
        for line_cnt = 1:numel(off_times)
            h = line([off_times(line_cnt) off_times(line_cnt)],[0 settings_params.fmax],'Color',[0.7 0 0]);
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
% % %                                      elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt)) settings_params.fmax]);
% % %                                     hs ={hs{:} curr_active_handle};
% % %                                     textpos = getPosition(curr_active_handle);
% % %                                     h = text(axes_handle,textpos(1)+textpos(3)/2,settings_params.text_height,num2str(elements{file_loc_in_keys}.segType(current_syllables(syl_cnt))),...
% % %                                         'Units','data','HorizontalAlignment','center','FontSize',24, ...
% % %                                         'Color', colors(find(syllables == elements{file_loc_in_keys}.segType(current_syllables(syl_cnt))),:));
% % %                                     set(curr_active_handle,'UserData', h);
% % %                                     id = addNewPositionCallback(curr_active_handle,@(pos)set(get(curr_active_handle,'UserData'),'Position',[pos(1)+pos(3)/2 settings_params.text_height 0]));
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
                                targetx = [mock_ons(mock_loc) mock_ofsettings_params.FS(mock_loc)];
                                numtags = setdiff(1:numel(elements{file_loc_in_keys}.segType),current_syllables(syl_cnt)) ;
                                if ~any((elements{file_loc_in_keys}.segFileStartTimes(numtags) < targetx(2)) & ...
                                        (elements{file_loc_in_keys}.segFileEndTimes(numtags) > targetx(1)))
                                    set_pos(syl_cnt,[mock_ons(mock_loc) rectpos(2) (mock_ofsettings_params.FS(mock_loc)-mock_ons(mock_loc)) rectpos(4)]);
                                end
                            end
                      end
                      update_elements;
                  end
              %fprintf(1,'\nI am doing a double-click.\n\n');
        end
    end

    function keystroke(h_obj,evt)
        
%         disp(evt.Key);
        hd = get(h_obj,'Children');
        mouse_loc = get(hd(end),'CurrentPoint');
        xpos = mouse_loc(1,1); ypos = mouse_loc(1,2);
%         disp([xpos ypos]);
        switch evt.Key
            case 's'
                range_rect = getrect(ax); 
                tstart = range_rect(1);
                tend = range_rect(1)+range_rect(3);
                taglist = cellfun(@str2num,params_handles.SylTags.String);
                if numel(taglist ~= numel(syllables))
                    syllables = taglist;
                    n_syllables = numel(syllables);
                    colors = GUI_distinguishable_colors(n_syllables,'w');
                end
                current_label = syllables(params_handles.SylTags.Value);
                to_change = find(elements{file_loc_in_keys}.segFileStartTimes(current_syllables) >= tstart & ...
                    elements{file_loc_in_keys}.segFileEndTimes(current_syllables) <= tend);
                elements{file_loc_in_keys}.segType(current_syllables(to_change)) = current_label;
              
                remove_syllables;
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                params_handles.file_list.UserData = elements;
            case 'q' %quit
                button = questdlg(['Do you want to save before quitting?'],'Quitters never win. Winners never quit!','Yes','No','No');
                if strcmp(button,'Yes')
                    save(fullfile(DIR,annotation_filename),'keys','elements');
                    templates = params_handles.show_button.UserData;
                    save(fullfile(DIR,template_filename),'templates');
                 end
                hgclose(hf);
                hgclose(h_temp);
                hgclose(h_map);  
                close(h_params);
                
            case 'w'
                button = questdlg(['Do you want to save before switching?'],'Quitters never win. Winners never quit!','Yes','No','No');
                if strcmp(button,'Yes')
                    save(fullfile(DIR,annotation_filename),'keys','elements');
                    templates = params_handles.show_button.UserData;
                    save(fullfile(DIR,template_filename),'templates');
                end
                hgclose(hf);
                hgclose(h_temp);
                hgclose(h_map);  
                close(h_params);
                SongAnnotationGUI('settings_file_path',settings_file_path);
                
                
            case 'e' %delete entry from keys
                current_entry = file_loc_in_keys;
                button = questdlg(['Are you sure that you want to exclude ' keys{current_entry}],'Deleting? Are you mad?','Yes','No','No');
                if strcmp(button,'Yes')
                    keys(current_entry) = [];
                    elements(current_entry) = [];
                    if (numel(keys) < current_entry)
                        file_loc_in_keys = numel(keys);
                    end
                    filename = keys{file_loc_in_keys};
                    params_handles.file_name.String = filename;
                    params_handles.file_list.String = keys;
                    save(fullfile(DIR,annotation_filename),'keys','elements');
                     save(fullfile(DIR,template_filename),'templates');
                     settings_params.window_positions = [window_handles{1}.figure1.Position;get(window_handles{2},'Position');get(window_handles{3},'Position');get(window_handles{4},'Position')];
                     %save(fullfile(settings_file_path,settings_file_name),'settings_params');
                     hgclose(hf);
                     hgclose(h_temp);
                     hgclose(h_map);     
                     gr_lines = [];
                    rd_lines = [];
                    curr_active = -1;
                    current_label = -1;
%                     filename = keys{params_handles.file_list.Value};
%                     params_handles.file_name.String = filename;
                   
                    [y,settings_params.FS] = audioread(fullfile(DIR,filename));
                    tmin = 0;
                    tmax = numel(y)/settings_params.FS;
                    %[S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),220,220-44,512,settings_params.FS);%,'reassigned');
                    [S,F,T,P] = mt_spectrogram((y/(sqrt(mean(y.^2)))),settings_params.FS,1,'nfft',512);
                    if ~isempty(elements{file_loc_in_keys}.segType)
                        phrases = GUI_return_phrase_times(elements{file_loc_in_keys});
                    else
                        phrases = [];
                    end
                    % create map
                    h_map = figure('Position',settings_params.window_positions(2,:)); 
                    axes_map = axes;
                    plot_full_amplitude_envelope(axes_map);
                    set(axes_map,'Position',[0.01 0.15 0.98 0.8]); 
                    set(axes_map,'YTick',[]);
                    xlim([tmin tmax]);
                    set(axes_map,'FontSize',14);
                    xlabel(axes_map,'Time (sec)');

                    tonset = 0;
                    toffset = settings_params.win_size;
                    h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>0,:)))))]);

                    h_temp = figure('Position',settings_params.window_positions(3,:)); 
                    ax_temp = axes;
                    %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))));
                    plot_full_amplitude_envelope(ax_temp);
                    xlim([tonset toffset]);
                    set(ax_temp,'YTick',[]);
                    set(ax_temp,'FontSize',14);
                    xlabel(ax_temp,'Time (sec)');
                    if (settings_params.tmpthr == 0)
                        settings_params.tmpthr = quantile(log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))),0.1);
                    end
                    h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                    pause;
                    thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                    settings_params.tmpthr = thr;

                        %T >= tonset & T<=toffset (T >= tonset & T<=toffset)
                    [on_times,off_times] = GUI_syllable_envelope(log(sum(abs(S(F<settings_params.fmax & F>0,:)))),T,thr,settings_params.min_gap,settings_params.min_syl);
                    % prepare mock syllables for auto positioning
                    mock_ofsettings_params.FS = off_times(off_times > on_times(1));
                    mock_ons = on_times(on_times < mock_ofsettings_params.FS(end));
                    mock_centers = (mock_ofsettings_params.FS+mock_ons)/2;
                    %

                    hf=figure('Position',settings_params.window_positions(4,:)); 
                    ax = axes;
                    draw_spec(ax);
                    set(ax,'FontSize',14);
                    xlabel(ax,'Time (sec)');
                    ylabel(ax,'Frequency (Hz)');

                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);

                    set(hf,'WindowbuttonDownFcn',@clickcallback)
                    set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
                    drawnow;
                    window_handles = {params_handles h_map h_temp hf};
                    params_handles.save_settings.UserData = {settings_params window_handles full_setting_path}; 
                    params_handles.file_list.UserData = elements;
                end
            case 'r' %update map colors
                phrases = GUI_return_phrase_times(elements{file_loc_in_keys});
                plot_full_amplitude_envelope(axes_map);
                set(axes_map,'Position',[0.01 0.15 0.98 0.8]); 
                set(axes_map,'YTick',[]);
                tmin = 0;
                tmax = numel(y)/settings_params.FS;
                xlim(axes_map,[tmin tmax]);
                h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>0,:)))))]);
                plot_full_amplitude_envelope(ax_temp);
                xlim(ax_temp,[tonset toffset]);
                h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
            case 'f' % zoom
                range_rect = getrect(ax); 
                tonset = range_rect(1);
                toffset = range_rect(1)+range_rect(3);
                setPosition(h_rect,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>0,:)))))]);
                axes(ax);
                remove_syllables;
                xlim([tonset toffset]);  
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                axes(ax_temp);
                
                xlim([tonset toffset]);
                thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                settings_params.tmpthr = thr;
                delete(h_line);
                h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                axes(ax);
                
            case 'p' %play sound
               time_stamps = [1:numel(y)]/settings_params.FS -1/settings_params.FS;
               soundsc(y(time_stamps >= tonset & time_stamps <= toffset),settings_params.FS);
            case 'c'
               time_stamps = [1:numel(y)]/settings_params.FS -1/settings_params.FS;
               [filename_tosave, pathname_tosave, ~] = uiputfile('*.wav', 'Enter file name');
               audiowrite(fullfile(pathname_tosave,filename_tosave),y(time_stamps >= tonset & time_stamps <= toffset),settings_params.FS);
            case 'g' %update borders to threshold crossings
                for syl_cnt = 1:numel(current_syllables) 
                        currpos = get_pos(syl_cnt);    
                                                 
                        rectpos = get_pos(syl_cnt);
                        rec_center = rectpos(1) + rectpos(3)/2;
                        mock_dist = abs(mock_centers - rec_center);
                        mock_loc = min(find(mock_dist == min(mock_dist)));
                        targetx = [mock_ons(mock_loc) mock_ofsettings_params.FS(mock_loc)];
                        numtags = setdiff(1:numel(elements{file_loc_in_keys}.segType),current_syllables(syl_cnt)) ;
                        if ~any((elements{file_loc_in_keys}.segFileStartTimes(numtags) < targetx(2)) & ...
                                (elements{file_loc_in_keys}.segFileEndTimes(numtags) > targetx(1)))
                            set_pos(syl_cnt,[mock_ons(mock_loc) rectpos(2) (mock_ofsettings_params.FS(mock_loc)-mock_ons(mock_loc)) rectpos(4)]);
                        end
                        
                 end
                      update_elements;
            case 'u' % update parameters and borders
                if params_handles.delete_tag_button.UserData == 1
                    elements = params_handles.file_list.UserData;
                    templates = params_handles.show_button.UserData;
                    params_handles.delete_tag_button.UserData = 0;
                end
                settings_params.min_gap = str2num(params_handles.MinGap.String);
                settings_params.min_syl = str2num(params_handles.MinSyl.String);
                settings_params.t_step = str2num(params_handles.StepSize.String);
                frange_old = [settings_params.fmin settings_params.fmax];
                settings_params.fmin = str2num(params_handles.freq_min.String);
                settings_params.fmax = str2num(params_handles.freq_max.String);
                old_caxis = settings_params.map_caxis;
                settings_params.map_caxis = [str2num(params_handles.caxis_min.String) str2num(params_handles.caxis_max.String)];
                if (sum(abs(old_caxis-settings_params.map_caxis)) ~= 0)
                    caxis(ax,settings_params.map_caxis);
                end
                if (sum(abs(frange_old-[settings_params.fmin settings_params.fmax])) ~= 0)
                    delete(h_rect);
                    plot_full_amplitude_envelope(axes_map);
                    set(axes_map,'Position',[0.01 0.15 0.98 0.8]); 
                    set(axes_map,'YTick',[]);
                    xlim([tmin tmax]);
                    set(axes_map,'FontSize',14);
                    xlabel(axes_map,'Time (sec)');
                    h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>0,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))))]);
    
                    delete(h_line);
                    plot_full_amplitude_envelope(ax_temp);
                    xlim([tonset toffset]);
                    set(ax_temp,'YTick',[]);
                    set(ax_temp,'FontSize',14);
                    xlabel(ax_temp,'Time (sec)');
                    h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                    
                    settings_params.text_height = settings_params.fmax*1.05;
                    remove_syllables;
                    draw_spec(ax);
                    set(ax,'FontSize',14);
                    xlabel(ax,'Time (sec)');
                    ylabel(ax,'Frequency (Hz)');
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);

                    set(hf,'WindowbuttonDownFcn',@clickcallback)
                    set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
                    drawnow;
                end
                posflag = 0;
                update_elements;
                newpos = getPosition(h_rect);
                new_tonset = newpos(1); new_toffset = newpos(1)+newpos(3);
                if (new_tonset ~= tonset | new_toffset ~= toffset)
                    posflag = 1;
                    tonset = new_tonset; toffset = new_toffset;
                end
                settings_params.win_size = toffset-tonset;
                thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                
                %if (settings_params.tmpthr ~= thr)
                thrflag = 1;
                settings_params.tmpthr = thr;
                [on_times,off_times] = GUI_syllable_envelope(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,T >= tonset & T<=toffset)))),T(T >= tonset & T<=toffset),thr,settings_params.min_gap,settings_params.min_syl);
                % prepare mock syllables for auto positioning
                mock_ofsettings_params.FS = off_times(off_times > on_times(1));
                mock_ons = on_times(on_times < mock_ofsettings_params.FS(end));
                mock_centers = (mock_ofsettings_params.FS+mock_ons)/2; 
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
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))));
                %plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                delete(h_line);
                h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                axes(ax);
                
                params_handles.save_settings.UserData = {settings_params window_handles full_setting_path};
                params_handles.file_list.UserData = elements;
            case 'x'
                update_elements;
                toffset = min(tmax,toffset+settings_params.t_step); tonset = min([tonset+settings_params.t_step,tmax-settings_params.t_step,toffset-settings_params.win_size]); 
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
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))));
                %plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                delete(h_line);
                h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                axes(ax);
                setPosition(h_rect,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))))]);
            case 'z'
                update_elements;
                tonset = max(tonset-settings_params.t_step,tmin); toffset = max([tmin+settings_params.t_step,toffset-settings_params.t_step,tonset+settings_params.win_size]);

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
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))));
                %plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                delete(h_line);
                h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                axes(ax);
                setPosition(h_rect,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))))]);
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
                 save(fullfile(DIR,annotation_filename),'keys','elements');
                 templates = params_handles.show_button.UserData;
                 save(fullfile(DIR,template_filename),'templates');
                 settings_params.window_positions = [window_handles{1}.figure1.Position;get(window_handles{2},'Position');get(window_handles{3},'Position');get(window_handles{4},'Position')];
                 %save(fullfile(settings_file_path,settings_file_name),'settings_params');
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
                        params_handles.file_name.String = filename;
                    end
                end
                [y,settings_params.FS] = audioread(fullfile(DIR,filename));
                tmin = 0;
                tmax = numel(y)/settings_params.FS;
                %[S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),220,220-44,512,settings_params.FS);%,'reassigned');
                [S,F,T,P] = mt_spectrogram((y/(sqrt(mean(y.^2)))),settings_params.FS,1,'nfft',512);
                if ~isempty(elements{file_loc_in_keys}.segType)
                    phrases = GUI_return_phrase_times(elements{file_loc_in_keys});
                else
                    phrases = [];
                end
                % create map
                h_map = figure('Position',settings_params.window_positions(2,:)); 
                axes_map = axes;
                plot_full_amplitude_envelope(axes_map);
                set(axes_map,'Position',[0.01 0.15 0.98 0.8]); 
                set(axes_map,'YTick',[]);
                xlim([tmin tmax]);
                set(axes_map,'FontSize',14);
                xlabel(axes_map,'Time (sec)');

                tonset = 0;
                toffset = settings_params.win_size;
                h_rect = imrect(axes_map,[tonset min(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:))))) toffset-tonset max(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))))]);

                h_temp = figure('Position',settings_params.window_positions(3,:)); 
                ax_temp = axes;
                %plot(T(T >= tonset & T<=toffset),log(sum(abs(S(F<settings_params.fmax & F>0,T >= tonset & T<=toffset)))));
                plot_full_amplitude_envelope(ax_temp);
                xlim([tonset toffset]);
                set(ax_temp,'YTick',[]);
                set(ax_temp,'FontSize',14);
                xlabel(ax_temp,'Time (sec)');
                if (settings_params.tmpthr == 0)
                    settings_params.tmpthr = quantile(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,T >= tonset & T<=toffset)))),0.1);
                end
                h_line = imline(ax_temp,[tonset settings_params.tmpthr; toffset settings_params.tmpthr]);
                pause;
                thr = (ax_temp.Children(1).Children(1).YData + ax_temp.Children(1).Children(2).YData)/2;
                settings_params.tmpthr = thr;

                    %T >= tonset & T<=toffset (T >= tonset & T<=toffset)
                [on_times,off_times] = GUI_syllable_envelope(log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:)))),T,thr,settings_params.min_gap,settings_params.min_syl);
                % prepare mock syllables for auto positioning
                mock_ofsettings_params.FS = off_times(off_times > on_times(1));
                mock_ons = on_times(on_times < mock_ofsettings_params.FS(end));
                mock_centers = (mock_ofsettings_params.FS+mock_ons)/2;
                %

                hf=figure('Position',settings_params.window_positions(4,:)); 
                ax = axes;
                draw_spec(ax);
                set(ax,'FontSize',14);
                xlabel(ax,'Time (sec)');
                ylabel(ax,'Frequency (Hz)');

                [hs, current_syllables] = display_rects(ax,[tonset toffset]);

                set(hf,'WindowbuttonDownFcn',@clickcallback)
                set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
                drawnow;
                window_handles = {params_handles h_map h_temp hf};
                params_handles.save_settings.UserData = {settings_params window_handles full_setting_path}; 
                params_handles.file_list.UserData = elements;
            case 'd' %delete syllable
                range_rect = getrect(ax); 
                tstart = range_rect(1);
                tend = range_rect(1)+range_rect(3);
                remove_syllables;
                to_delete = find(elements{file_loc_in_keys}.segFileStartTimes(current_syllables) >= tstart & ...
                    elements{file_loc_in_keys}.segFileEndTimes(current_syllables) <= tend);
                elements{file_loc_in_keys}.segFileStartTimes(current_syllables(to_delete)) = [];
                elements{file_loc_in_keys}.segFileEndTimes(current_syllables(to_delete)) = [];
                elements{file_loc_in_keys}.segAbsStartTimes(current_syllables(to_delete)) = [];
                elements{file_loc_in_keys}.segType(current_syllables(to_delete)) = [];
                
                syl_in_win = find(elements{file_loc_in_keys}.segFileStartTimes >= tonset & ...
                    elements{file_loc_in_keys}.segFileEndTimes <= toffset);
                if ~isempty(syl_in_win)
                    curr_active = syl_in_win(1);
                end
                [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                params_handles.file_list.UserData = elements;
                    
% % %                 if (xpos > tonset & xpos < toffset)             
% % %                   for syl_cnt = 1:numel(current_syllables) %start_syl:min(start_syl+numel(hs)-1,numel(syl_idx))
% % %                     %syl_cnt = syl_num - start_syl+1;
% % %                     rectpos = get_pos(syl_cnt);
% % %                     maxx = rectpos(1)+rectpos(3);
% % %                     minx = rectpos(1);
% % %                     if (xpos > minx & xpos < maxx) 
% % %                         if current_syllables(syl_cnt) <= curr_active
% % %                             curr_active = curr_active - 1;
% % %                         end
% % %                         elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt)) = [];
% % %                         elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt)) = [];
% % %                         elements{file_loc_in_keys}.segAbsStartTimes(current_syllables(syl_cnt)) = [];
% % %                         elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)) = [];
% % %                         remove_syllables;
% % %                         current_syllables(syl_cnt+1:end) = current_syllables(syl_cnt+1:end) - 1;
% % %                         current_syllables(syl_cnt) = [];        
% % %                         %cellfun(@delete,hs);
% % %                         
% % %                         [hs, current_syllables] = display_rects(ax,[tonset toffset]);
% % % %                         delete(get(hs(syl_cnt),'UserData'));
% % % %                         delete(hs(syl_cnt));
% % %                         %hs(syl_cnt) = [];
% % %                         break;
% % %                     end
% % %                   end
% % %                   params_handles.file_list.UserData = elements;
% % %                 end
            case 't' %tag
                if ismember(curr_active,current_syllables)
                    syl_cnt = find(current_syllables == curr_active);
                    taglist = cellfun(@str2num,params_handles.SylTags.String);
                    if numel(taglist ~= numel(syllables))
                        syllables = taglist;
                        n_syllables = numel(syllables);
                        colors = GUI_distinguishable_colors(n_syllables,'w');
                    end
                    current_label = syllables(params_handles.SylTags.Value);
                    elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)) = current_label;
                    %cellfun(@delete,hs);
                    remove_syllables;
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                    params_handles.file_list.UserData = elements;
                end
            case 'b' % create threshold base boundaries
                taglist = cellfun(@str2num,params_handles.SylTags.String);
                if numel(taglist ~= numel(syllables))
                    syllables = taglist;
                    n_syllables = numel(syllables);
                    colors = GUI_distinguishable_colors(n_syllables,'w');
                end
                current_label = syllables(params_handles.SylTags.Value);
                mock_locs = find(mock_ons >= tonset & mock_ofsettings_params.FS <= toffset);
                for mock_cnt = 1:numel(mock_locs)
                    mock_loc = mock_locs(mock_cnt);
                    newrect = [mock_ons(mock_loc) settings_params.fmin (mock_ofsettings_params.FS(mock_loc)-mock_ons(mock_loc)) settings_params.fmax];
                    add_syllable(newrect,current_label);
                    axes(ax);
                    %cellfun(@delete,hs);
                    remove_syllables;
                    [hs, current_syllables] = display_rects(ax,[tonset toffset]);
                end
                params_handles.file_list.UserData = elements;
            case 'l'         
                if ismember(curr_active,current_syllables)
                    syl_cnt = find(current_syllables == curr_active);
                    taglist = cellfun(@str2num,params_handles.SylTags.String);
                    if numel(unique([taglist;-1])) ~= numel(syllables)
                        syllables = taglist;
                        n_syllables = numel(syllables);
                        colors = GUI_distinguishable_colors(n_syllables,'w');
                    end
                    current_label = syllables(params_handles.SylTags.Value);
                    button = questdlg(['Do you want to update the template for syllable #' num2str(current_label) ' ?'],'LABELING','Yes','No','No');
                    if strcmp(button,'Yes')
                        if (current_label == elements{file_loc_in_keys}.segType(current_syllables(syl_cnt)))
                            time_stamps = [1:numel(y)]/settings_params.FS -1/settings_params.FS;
                            templates.wavs(params_handles.SylTags.Value).segType = current_label;
                            templates.wavs(params_handles.SylTags.Value).filename = keys{params_handles.file_list.Value};
                            templates.wavs(params_handles.SylTags.Value).startTime = elements{file_loc_in_keys}.segFileStartTimes(current_syllables(syl_cnt));
                            templates.wavs(params_handles.SylTags.Value).endTime = elements{file_loc_in_keys}.segFileEndTimes(current_syllables(syl_cnt));
                            templates.wavs(params_handles.SylTags.Value).fs = settings_params.FS;
                            templates.wavs(params_handles.SylTags.Value).wav = y(time_stamps >= templates.wavs(params_handles.SylTags.Value).startTime & ...
                                time_stamps <= templates.wavs(params_handles.SylTags.Value).endTime);
                            params_handles.show_button.UserData = templates;
                        else
                            msgbox('The spectrogram segment must have the same label as the tagging dialog box!');
                        end
                    end
                        
                end
                %current_label = input('Label: '); 
            case 'j' % joint current with next. label is current
                if ismember(curr_active,current_syllables)
                    syl_cnt = find(current_syllables == curr_active);
                    taglist = cellfun(@str2num,params_handles.SylTags.String);
                    if numel(taglist ~= numel(syllables))
                        syllables = taglist;
                        n_syllables = numel(syllables);
                        colors = GUI_distinguishable_colors(n_syllables,'w');
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
                    params_handles.file_list.UserData = elements;
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
                     settings_params.fmin elements{file_loc_in_keys}.segFileEndTimes(syl_idx(syl_num)) - ...
                     elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) settings_params.fmax]);
                result_hs ={result_hs{:} curr_active_handle};
                textpos = getPosition(curr_active_handle);
                h = text(axes_handle,textpos(1)+textpos(3)/2,settings_params.text_height,num2str(elements{file_loc_in_keys}.segType(syl_idx(syl_num))),...
                    'Units','data','HorizontalAlignment','center','FontSize',24, ...
                    'Color', colors(find(syllables == elements{file_loc_in_keys}.segType(syl_idx(syl_num))),:));
                set(curr_active_handle,'UserData', h);
                id = addNewPositionCallback(result_hs{end},@(pos)set(get(curr_active_handle,'UserData'),'Position',[pos(1)+pos(3)/2 settings_params.text_height 0]));
           else
                h=rectangle(axes_handle,'Position',[elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) ...
                     settings_params.fmin elements{file_loc_in_keys}.segFileEndTimes(syl_idx(syl_num)) - ...
                     elements{file_loc_in_keys}.segFileStartTimes(syl_idx(syl_num)) settings_params.fmax],'LineWidth',2,...
                     'EdgeColor',colors(find(syllables == elements{file_loc_in_keys}.segType(syl_idx(syl_num))),:));

                result_hs ={result_hs{:} h};
                textpos = get(result_hs{end},'Position');
                h = text(axes_handle,textpos(1)+textpos(3)/2,settings_params.text_height,num2str(elements{file_loc_in_keys}.segType(syl_idx(syl_num))),...
                    'Units','data','HorizontalAlignment','center','FontSize',24, ...
                    'Color', colors(find(syllables == elements{file_loc_in_keys}.segType(syl_idx(syl_num))),:));
                set(result_hs{end},'UserData', h);
                %id = addNewPositionCallback(result_hs(end),@(pos)set(get(result_hs(end),'UserData'),'Position',[pos(1)+pos(3)/2 settings_params.text_height 0]));
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
        params_handles.file_list.UserData = elements;
    end

    function add_syllable(rect,syl_id)
        new_rec_minx = rect(1); new_rec_maxx = rect(1)+rect(3);          
%                 if (new_rec_minx < maxx & new_rec_minx > minx & new_rec_maxx < maxx & new_rec_maxx > minx)
        new_syl_loc = [];
        if isempty(elements{file_loc_in_keys}.segType)
                elements{file_loc_in_keys}.segFileStartTimes =  new_rec_minx;
                elements{file_loc_in_keys}.segAbsStartTimes = ...
                    GUI_getFileTime(filename) + elements{file_loc_in_keys}.segFileStartTimes/(24*60*60);
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
                    GUI_getFileTime(filename) + elements{file_loc_in_keys}.segFileStartTimes/(24*60*60);
                elements{file_loc_in_keys}.segFileEndTimes = ...
                    [elements{file_loc_in_keys}.segFileEndTimes(1:syl_before) new_rec_maxx ...
                    elements{file_loc_in_keys}.segFileEndTimes(syl_before+1:end)];
                elements{file_loc_in_keys}.segType = ...
                    [elements{file_loc_in_keys}.segType(1:syl_before); syl_id; ...
                    elements{file_loc_in_keys}.segType(syl_before+1:end)];

                %phrases = GUI_return_phrase_times(elements{file_loc_in_keys});
                %tonset = phrases.phraseFileStartTimes(locs(cnt));
                %toffset = phrases.phraseFileEndTimes(locs(cnt));
               
                %set(hf,'WindowbuttonDownFcn',@clickcallback)
                %set(hf,'KeyPressFcn',@(h_obj,evt) keystroke(h_obj,evt));
                params_handles.file_list.UserData = elements;
            end
        end
    end
    

    function remove_syllables
        for syl_cnt = 1:numel(current_syllables)
            delete(get(hs{syl_cnt},'UserData'));
        end
        cellfun(@delete,hs); 
    end

    function time = GUI_getFileTime(filename)
        strparts = regexp(filename,'_', 'split');
        yr = str2double(strparts{3});
        m = str2double(strparts{4});
        d = str2double(strparts{5});
        th = str2double(strparts{6});
        tm = str2double(strparts{7});
        time = datenum(yr,m,d,th,tm,0);
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
        cla(target_axes_handle);
        logS = log(sum(abs(S(F<settings_params.fmax & F>settings_params.fmin,:))));
        if isempty(phrases)
            plot(target_axes_handle,T,logS);
        else
            
            plot(target_axes_handle,T(T <= phrases.phraseFileStartTimes(1)),logS(T <= phrases.phraseFileStartTimes(1)),'Color',[0.5 0.5 0.5],'LineStyle',':');
            hold(target_axes_handle,'on')
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
            
        end
        ylim(target_axes_handle,[min(logS) max(logS)]);
    end

    

end