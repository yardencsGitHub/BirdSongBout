function SAT_similarity_plot(obj)
% This is a GUI for SAT_similarity. For more information type help SAT_similarity
    global SAT_params;
    global sfig; 
    vr=version;
    if vr(1)=='8' && str2double(vr(3))>5
        New_Matlab=true;
    else 
        New_Matlab=false;
    end;
    freq_range=floor(SAT_params.FFT*SAT_params.Frequency_range/2); % with 1024 frequency range and 0.5 in SAT_params, range is 256
    to_Hz=floor(obj.sound1.sound.fs/SAT_params.FFT);
    sfig=figure('pos',[10,300,1000,1000]);
    
 % set panel and edit box for displaying results   
    results_panel = uipanel('Parent', sfig, 'Units', 'normal', 'Position', [0.3 .93 .6 .071]);
    results=uicontrol('Style', 'edit', 'Parent', results_panel, 'Position', [5 1 600 50],'Max', 10);
 
    
  % set panel for controls  
    controls_panel = uipanel('Parent', sfig, 'Units', 'normal', 'Position', [0.01 .75 .23 .25]);
    %results=uicontrol('Style', 'edit', 'Parent', controls_panel, 'Position', [5 1 600 50],'Max', 10);
    
    
  %subplot sound 1:
    subplot(5,5,[2 5]);
    F=1:to_Hz:obj.sound1.sound.fs*SAT_params.Frequency_range;
    sample_dur=1/obj.sound1.sound.fs;
    FFT_slice=sample_dur*SAT_params.FFT_step; % this gives us the duration of each FFT 'slice' in the sonogram
    duration=FFT_slice*obj.sound1.num_slices;
    tt=0:FFT_slice:duration+10; 
    T=tt(1:obj.sound1.num_slices);
    surf(T,F(1:freq_range),log(obj.sound1.sonogram(1:freq_range,1:obj.sound1.num_slices)),'edgecolor','none'); axis tight;
    colormap(jet);    
    view(0,90);
    xlabel('Time (Seconds)'); ylabel('Hz');

  %subplot sound 2
    subplot(5,5,[6 21]); 
    FFT_slice=sample_dur*SAT_params.FFT_step; % this gives us the duration of each FFT 'slice' in the sonogram
    duration=FFT_slice*obj.sound2.num_slices;
    tt=0:FFT_slice:duration+10; 
    T=tt(1:obj.sound2.num_slices);

    surf(F(1:freq_range),T,log(obj.sound2.sonogram(1:freq_range,obj.sound2.num_slices:-1:1)'),'edgecolor','none'); axis tight;
    colormap(jet);    
    view(0,90);
    ylabel('Time (Seconds)'); xlabel('Hz');
    
% Create pop-up menu for method
    sim_method=uicontrol('Style', 'popup','String', {'Blur (fast)','time course (accurate)'}, 'Parent', controls_panel,...
        'Position', [50 97 160 70],'Value', 2, 'Callback', @similarity_method, 'Visible', 'on');  
    uicontrol('Style','text', 'Parent', controls_panel, 'Position',[2 145 60 20],'String','Method');
     function similarity_method(source,~)
        vl=get(source,'Value');%floor(get(interval, 'Value')); 
        SAT_params.similarity_method=vl-1;
        save('SAT_params.mat','SAT_params');
    end
    
  % create a slider for similarity interval:
    interval=uicontrol('Style', 'slider','Min',10,'Max',200,'Value',70,'Parent', controls_panel, 'Position', [60 125 130 20], 'Callback', @set_interval); 
    uicontrol('Style','text','Parent', controls_panel, 'Position',[2 125 60 20],'String','Interval');
    x=get(interval,'Value');
    interval_label=uicontrol('Style','text', 'Parent', controls_panel, 'Position',[190 125 40 20],'String',x);
    function set_interval(~,~)
        SAT_params.similarity_interval = floor(get(interval, 'Value')); 
        interval_label.String=SAT_params.similarity_interval;
        save('SAT_params.mat','SAT_params');
    end

  % create a slider for similarity threshold according to MADs:
    thresh=uicontrol('Style', 'slider','Min',0,'Max',100,'Value',20,'Parent', controls_panel, 'Position', [60 105 130 20], 'Callback', @set_thresh);
    uicontrol('Style','text','Parent', controls_panel, 'Position',[2 105 60 20],'String','Thesh');
    x=get(thresh,'Value')/10;
    thresh_label=uicontrol('Style','text','Parent', controls_panel, 'Position',[190 105 40 20],'String',x);
    function set_thresh(~,~)
        x=floor(get(thresh, 'Value'));
        SAT_params.similarity_threshold = x/10; 
        thresh_label.String=SAT_params.similarity_threshold;
        save('SAT_params.mat','SAT_params');
    end




% create a slider for section size constraint:
    section_size=uicontrol('Style', 'slider','Min',1,'Max',100,'Value',10, 'Parent', controls_panel,'Position', [60 85 130 20], 'Callback', @set_section_size); 
    uicontrol('Style','text', 'Parent', controls_panel,'Position',[2 85 60 20],'String','min sect');
    x=get(section_size,'Value');
    section_label=uicontrol('Style','text', 'Parent', controls_panel, 'Position', [190 85 40 20],'String',x);
    function set_section_size(~,~)
        SAT_params.similarity_section_min_dur = floor(get(section_size, 'Value')); 
        section_label.String=SAT_params.similarity_section_min_dur;
        save('SAT_params.mat','SAT_params');
    end




    % Create checkbox for calculating similarity sections through siences or not
    calc_silence = uicontrol('style','checkbox','units','pixels','Parent', controls_panel,...
    'position',[10 51 150 40],'string','calc through silences','Callback', @clc_silence);
     function clc_silence(source,~)
        vl=get(source,'Value');
        SAT_params.calc_silence=vl;
        save('SAT_params.mat','SAT_params');
     end
 
   % Create push button for similarity
    uicontrol('Style', 'pushbutton', 'String', 'Score','Parent', controls_panel,...
        'Position', [30 25 120 35],...
        'Callback', @similarity_score); 
 
 % Create a labele for waiting
    wait_label=uicontrol('Style','text', 'Position',[400 500 200 100],'String','Please wait','Visible', 'off');
    set(wait_label, 'FontSize', 50);
 
 % Create pop-up menu for distance matrixes
    sim_display=uicontrol('Style', 'popup', 'String', {'Global similarity','Similarity sections',...
        'Local similarity','local pitch','local goodness', 'local FM','local AM', 'local entropy',...
        'global pitch','global goodness', 'global FM','global AM', 'global entropy'},'Parent', controls_panel,'Position',...
        [10 1 160 20],'Callback', @show_features, 'Visible', 'off');   
   
    
    x=SAT_params.similarity_method;
    set(sim_method,'Value',x+1);

    x=floor(SAT_params.similarity_threshold*10);
    set(thresh,'Value',x);
    set(thresh_label,'String',x/10);

    x=SAT_params.similarity_interval;
    set(interval,'Value',x);
    set(interval_label,'String',x);

    x=SAT_params.calc_silence;
    set(calc_silence,'Value',x);
           


 function similarity_score(~,~)
     if New_Matlab
         set(wait_label, 'Visible', 'on');
         drawnow;
     end;
     SAT_params.calc_silence = get(calc_silence, 'Value');
     obj.calculate_similarity;
     % create a text box for similarity scores presentation:
     %subgroup1_plotbox = uipanel('Parent', sfig, 'Units', 'normal', 'Position', [0 .9 .1 .1]);  %plot in top 9/10 of the group
     %A=uicontrol('Style', 'edit', 'String', floor(obj.score.similarity),'Parent', subgroup1_plotbox);%'Position', [300 750 400 50],'Max', 10); 
     sim = cell(1,2);  
     sim{1,1} = sprintf('precent similarity = %d \n%', floor(obj.score.similarity));                                                           
     sim{1,2} = sprintf('accuracy = %d \n%', floor(obj.score.accuracy));                                                   
     simstring = sprintf('%s\n%s',sim{1,1},sim{1,2});
     set(results, 'String', simstring);
     sp1=subplot(5,5,[7 25]);
     if(New_Matlab)
         colormap(sp1,parula);
     end;
     imagesc(-1*obj.global_similarity.all');
        for i=1:obj.number_of_sections
            if obj.similarity_sections(i,5)>0
                BoundingRect(1)=floor(obj.similarity_sections(i,1));
                BoundingRect(2)=floor(obj.similarity_sections(i,2));
                BoundingRect(3)=floor(obj.similarity_sections(i,3)-obj.similarity_sections(i,1));
                BoundingRect(4)=floor(obj.similarity_sections(i,4)-obj.similarity_sections(i,2));
                rectangle('Position',BoundingRect, 'EdgeColor','red');
                message = sprintf('Similarity = %d', floor(obj.similarity_sections(i,5))); 
                text(obj.similarity_sections(i,1)+15, obj.similarity_sections(i,2)+15, message, 'Color', 'r');
                %sprintf('%d', i); 
            end;
        end;
        if(New_Matlab)
            set(wait_label, 'Visible', 'off');
        end;
        set(sim_display, 'Visible', 'on');
       assignin ('base','SAT_score',obj.score);
 end
     


    function show_features(source,~)
        val = get(source,'Value');
        switch val
            case 1 
                imagesc(-1*obj.global_similarity.all');
                for i=1:obj.number_of_sections
                    if obj.similarity_sections(i,5)>0
                        BoundingRect(1)=floor(obj.similarity_sections(i,1));
                        BoundingRect(2)=floor(obj.similarity_sections(i,2));
                        BoundingRect(3)=floor(obj.similarity_sections(i,3)-obj.similarity_sections(i,1));
                        BoundingRect(4)=floor(obj.similarity_sections(i,4)-obj.similarity_sections(i,2));
                        rectangle('Position',BoundingRect, 'EdgeColor','red');
                        message = sprintf('Similarity = %d', floor(obj.similarity_sections(i,5))); 
                        text(obj.similarity_sections(i,1)+15, obj.similarity_sections(i,2)+15, message, 'Color', 'r');
                        sprintf('%d', i); 
                    end;
                end;


            case 2

                imagesc(obj.local_similarity.similarity');
                for i=1:obj.number_of_sections
                    if obj.similarity_sections(i,5)~=0
                        BoundingRect(1)=floor(obj.similarity_sections(i,1));
                        BoundingRect(2)=floor(obj.similarity_sections(i,2));
                        BoundingRect(3)=floor(obj.similarity_sections(i,3)-obj.similarity_sections(i,1));
                        BoundingRect(4)=floor(obj.similarity_sections(i,4)-obj.similarity_sections(i,2));
                        rectangle('Position',BoundingRect, 'EdgeColor','white');
                        message = sprintf('Similarity = %d', floor(obj.similarity_sections(i,5))); 
                        text(obj.similarity_sections(i,1)+15, obj.similarity_sections(i,2)+15, message, 'Color', 'w');
                        sprintf('%d', i); 
                    end;
                end;

            case 3 
                imagesc(-1.*obj.local_similarity.all');
            case 4 
               imagesc(-1.*obj.local_similarity.pitch');
            case 5  
                imagesc(-1.*obj.local_similarity.goodness');
            case 6  
                 imagesc(-1.*obj.local_similarity.FM');
            case 7
                 imagesc(-1.*obj.local_similarity.AM');
            case 8 
                 imagesc(-1.*obj.local_similarity.entropy');
            case 9 
               imagesc(-1.*obj.global_similarity.pitch');
            case 10  
                imagesc(-1.*obj.global_similarity.goodness');
            case 11  
                 imagesc(-1.*obj.global_similarity.FM');
            case 12
                 imagesc(-1.*obj.global_similarity.AM');
            case 13 
                 imagesc(-1.*obj.global_similarity.entropy')


        end;
     end
                

end