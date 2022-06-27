 function SAT()
 % This is a GUI for all Sound Analysis Tools
 % For more information type help SAT_sound or help SAT_similarity
        global SAT_params sound1 sound2;
        SAT_set_params(); % call this function to either retrive or create parameters
        %# create tabbed GUI if Matlab version is 2015 or higher
        hFig = figure('Menubar','none','Name','Sound Analysis Tools','NumberTitle','off');
        %hFig.Position=[1 1 600 280];
        
        
tabs=false;        
vr=version;
if vr(1)=='8' && str2double(vr(3))>5
    tabs=true;
    hFig.Position=[1 1 600 280];
    warning('off', 'MATLAB:uitabgroup:OldVersion');
    tgroup = uitabgroup('Parent', hFig);
    hTabs(1) = uitab('Parent', tgroup, 'Title', 'Explore & Score');
    hTabs(2) = uitab('Parent', tgroup, 'Title', 'Similarity Measurements');
    hTabs(3) = uitab('Parent', tgroup, 'Title', 'Plots and Statistics');
    hTabs(4) = uitab('Parent', tgroup, 'Title', 'Batch');
    tgroup.SelectedTab = hTabs(1); 
else 
    set(hFig, 'Position',[1 1 900 280]);
    
end;

       

        
%         
%         hTabGroup = uitabgroup('Parent',hFig);
%         warning(s);
%         hTabs(1) = uitab('Parent',hTabGroup, 'Title','Explore & Score');
%         hTabs(2) = uitab('Parent',hTabGroup, 'Title','Similarity Measurements');
%         hTabs(3) = uitab('Parent',hTabGroup, 'Title','Plots and Statistics');
%         hTabs(4) = uitab('Parent',hTabGroup, 'Title','Batch');
%         set(hTabGroup, 'SelectedTab',hTabs(1));

        %# populate main tab
        %credits
        if(tabs)
            uicontrol('Style','text','Parent',hTabs(1), 'Position',[1 1 500 20],'String','Algorithms: Ofer Tchernichovski & Partha P. Mitra     Contact: Tchernichovski@gmail.com');
        else
             uicontrol('Style','text', 'Position',[1 1 500 20],'String','Algorithms: Ofer Tchernichovski & Partha P. Mitra     Contact: Tchernichovski@gmail.com');

        end;
        
        % Create sliders for Frequency analysis tab:
          if(tabs)
             FFTsize=uicontrol('Style', 'slider','Min',100,'Max',1000,'Value',800,'Parent',hTabs(1), 'Position', [130 100 140 20], 'Callback', @FFT_window); 
             uicontrol('Style','text','Parent',hTabs(1), 'Position',[1 100 130 20],'String','FFT Data Window');
             x=get(FFTsize,'Value');
             FFTsize_Lable=uicontrol('Style','text','Parent',hTabs(1), 'Position',[270 100 40 20],'String',x);
          else
             FFTsize=uicontrol('Style', 'slider','Min',100,'Max',1000,'Value',800, 'Position', [130 100 140 20], 'Callback', @FFT_window); 
             uicontrol('Style','text', 'Position',[1 100 130 20],'String','FFT Data Window');
             x=get(FFTsize,'Value');
             FFTsize_Lable=uicontrol('Style','text','Position',[270 100 40 20],'String',x);
          end;
         
         % slider for FFT step:
          if(tabs)
              FFTstep=uicontrol('Style', 'slider','Min',1,'Max',1000,'Value',40,'Parent',hTabs(1), 'Position', [130 70 140 20], 'Callback', @FFT_step); 
              uicontrol('Style','text','Parent',hTabs(1), 'Position',[1 70 130 20],'String','FFT step');
              x=get(FFTstep,'Value');
              FFTstep_Lable=uicontrol('Style','text','Parent',hTabs(1), 'Position',[270 70 40 20],'String',x);
          else 
               FFTstep=uicontrol('Style', 'slider','Min',1,'Max',1000,'Value',40, 'Position', [130 70 140 20], 'Callback', @FFT_step); 
              uicontrol('Style','text','Position',[1 70 130 20],'String','FFT step');
              x=get(FFTstep,'Value');
              FFTstep_Lable=uicontrol('Style','text', 'Position',[270 70 40 20],'String',x);
          end;
         
         % slider for frequency ranged analyzed (lower ratio from the entire range)
         if(tabs)
             Frequency_range=uicontrol('Style', 'slider','Min',0.1,'Max',1,'Value',0.5,'Parent',hTabs(1), 'Position', [130 40 140 20], 'Callback', @Freq_range); 
             uicontrol('Style','text','Parent',hTabs(1), 'Position',[1 40 130 20],'String','Frequency range');
             x=get(Frequency_range,'Value');
             Frequency_range_Lable=uicontrol('Style','text','Parent',hTabs(1), 'Position',[270 40 40 20],'String',x);
         else
             Frequency_range=uicontrol('Style', 'slider','Min',0.1,'Max',1,'Value',0.5, 'Position', [130 40 140 20], 'Callback', @Freq_range); 
             uicontrol('Style','text', 'Position',[1 40 130 20],'String','Frequency range');
             x=get(Frequency_range,'Value');
             Frequency_range_Lable=uicontrol('Style','text', 'Position',[270 40 40 20],'String',x);

         end;
         
        % create radio group for pitch calculation method
         if(tabs)
            bg = uibuttongroup('Visible','off','Parent',hTabs(1),'Position',[0.7 0.2 .3 .3], 'SelectionChangedFcn',@bselection);
         else 
            bg = uibuttongroup('Visible','off','Position',[0.7 0.2 .3 .3]);
        end;
        pitch_method = uicontrol(bg,'Style','radiobutton',  'String','Pitch = Mean frequency','Position',[10 5 140 30], 'HandleVisibility','off');
        yin_method=uicontrol(bg,'Style','radiobutton', 'String','Pitch = YIN (better)', 'Position',[10 30 140 30],  'HandleVisibility','off'); 
        if SAT_params.pitch_method
             set(bg, 'SelectedObject',yin_method);
        else set(bg, 'SelectedObject',pitch_method);
        end;
        set(bg,'Visible', 'on');
        function bselection(~,~)
            if bg.SelectedObject==pitch_method
                SAT_params.pitch_method=0;
            else 
                SAT_params.pitch_method=1;
                if(~exist('yin.m','file'))
                    msgbox('YIN is not accessible. You might need to install or set path to YIN. See in https://github.com/lemonzi/matlab/blob/master/yin');
                end;
            end; 
            save('SAT_params.mat','SAT_params');
        end
         
         
         
         % GUI elements in Similarity tab 
         % Create pop-up menu for method
         if(tabs)
             sim_method=uicontrol('Style', 'popup','String', {'Blur (fast)','time course (accurate)'},'Parent',hTabs(2),'Position', [100 160 160 60],'Callback', @similarity_method); 
             uicontrol('Style','text','Parent',hTabs(2), 'Position',[30 195 60 25],'String','Method');
         else 
             sim_method=uicontrol('Style', 'popup','String', {'Blur (fast)','time course (accurate)'},'Position', [500 160 160 60],'Callback', @similarity_method); 
             uicontrol('Style','text', 'Position',[430 195 60 25],'String','Method');
         end;
         
         function similarity_method(source,~)
            vl=get(source,'Value');
            SAT_params.similarity_method=vl-1;
            save('SAT_params.mat','SAT_params');
         end
       
         % create a slider for similarity interval:
          if(tabs)
            interval=uicontrol('Style', 'slider','Min',10,'Max',200,'Value',70, 'Parent',hTabs(2), 'Position', [100 160 130 20], 'Callback', @set_interval); 
            uicontrol('Style','text','Parent',hTabs(2), 'Position',[30 160 60 20],'String','Interval');
            x=get(interval,'Value');
            interval_label=uicontrol('Style','text','Parent',hTabs(2), 'Position',[230 160 40 20],'String',x);
          else
            interval=uicontrol('Style', 'slider','Min',10,'Max',200,'Value',70,  'Position', [500 160 130 20], 'Callback', @set_interval); 
            uicontrol('Style','text', 'Position',[430 160 60 20],'String','Interval');
            x=get(interval,'Value');
            interval_label=uicontrol('Style','text', 'Position',[630 160 40 20],'String',x);
          end;
         
         function set_interval(~,~)
            SAT_params.similarity_interval = floor(get(interval, 'Value')); 
            interval_label.String=SAT_params.similarity_interval;
            save('SAT_params.mat','SAT_params');
         end
     
     % create a slider for similarity threshold according to MADs:
         if(tabs)
             thresh=uicontrol('Style', 'slider','Min',0,'Max',100,'Value',20, 'Parent',hTabs(2), 'Position', [100 130 130 20], 'Callback', @set_thresh); 
             uicontrol('Style','text','Parent',hTabs(2), 'Position',[30 130 60 30],'String','Theshold (MADs):');
             x=floor(get(thresh,'Value'));
             x=x/10;
             thresh_label=uicontrol('Style','text','Parent',hTabs(2), 'Position',[230 130 40 20],'String',x);
         else
             thresh=uicontrol('Style', 'slider','Min',0,'Max',100,'Value',20,  'Position', [500 130 130 20], 'Callback', @set_thresh); 
             uicontrol('Style','text', 'Position',[30 530 60 30],'String','Theshold (MADs):');
             x=floor(get(thresh,'Value'));
             x=x/10;
             thresh_label=uicontrol('Style','text', 'Position',[630 130 40 20],'String',x);

         end; 
         
         function set_thresh(~,~)
            SAT_params.similarity_threshold = get(thresh, 'Value')/10; 
            thresh_label.String=SAT_params.similarity_threshold;
            save('SAT_params.mat','SAT_params');
         end
     
     % create a slider for how much off diagonal slope is allowed in a similarity section
         if(tabs)
             timewarp=uicontrol('Style', 'slider','Min',0.5,'Max',1,'Value',0.9, 'Parent',hTabs(2), 'Position', [100 110 130 20], 'Callback', @set_warp); 
             uicontrol('Style','text','Parent',hTabs(2), 'Position',[10 110 80 20],'String','time warp');
             x=get(timewarp,'Value');
             warp_label=uicontrol('Style','text','Parent',hTabs(2), 'Position',[230 110 40 20],'String',x);
         else
             timewarp=uicontrol('Style', 'slider','Min',0.5,'Max',1,'Value',0.9,  'Position', [500 110 130 20], 'Callback', @set_warp); 
             uicontrol('Style','text', 'Position',[410 110 80 20],'String','time warp');
             x=get(timewarp,'Value');
             warp_label=uicontrol('Style','text', 'Position',[630 110 40 20],'String',x);
 
         end;
         function set_warp(~,~)
            SAT_params.time_warping_tolerance = (get(timewarp, 'Value')); 
            warp_label.String=round(SAT_params.time_warping_tolerance,2);
            save('SAT_params.mat','SAT_params');
         end
     
     % create a slider for SAT_params.similarity_section_min_dur=10; % minimum duration for similarity section in ms
          if(tabs)
            min_section=uicontrol('Style', 'slider','Min',1,'Max',100,'Value',10, 'Parent',hTabs(2), 'Position', [100 90 130 20], 'Callback', @set_min_section); 
            uicontrol('Style','text','Parent',hTabs(2), 'Position',[10 90 80 20], 'String', 'min section');
            x=get(min_section,'Value');
            min_section_label=uicontrol('Style','text','Parent',hTabs(2), 'Position',[230 90 40 20],'String',x);
          else
            min_section=uicontrol('Style', 'slider','Min',1,'Max',100,'Value',10, 'Position', [500 90 130 20], 'Callback', @set_min_section); 
            uicontrol('Style','text','Position',[410 90 80 20], 'String', 'min section');
            x=get(min_section,'Value');
            min_section_label=uicontrol('Style','text', 'Position',[630 90 40 20],'String',x);
  
          end;
         function set_min_section(~,~)
            SAT_params.similarity_section_min_dur = (get(min_section, 'Value')); 
            min_section_label.String=floor(SAT_params.similarity_section_min_dur);
            save('SAT_params.mat','SAT_params');
         end
     
     % create a slider for SAT_params.accuracy_jitter=5; % set a range for finding the best match, default +/- 5 windows (10ms)
         if(tabs)
             accuracy_jitter=uicontrol('Style', 'slider','Min',1,'Max',50,'Value',5, 'Parent',hTabs(2), 'Position', [100 70 130 20], 'Callback', @set_jitter); 
             uicontrol('Style','text','Parent',hTabs(2), 'Position',[10 70 90 20],'String', 'accuracy jitter');
             x=get(accuracy_jitter,'Value');
             jitter_label=uicontrol('Style','text','Parent',hTabs(2), 'Position',[230 70 40 20],'String',x);
         else
             accuracy_jitter=uicontrol('Style', 'slider','Min',1,'Max',50,'Value',5,  'Position', [500 70 130 20], 'Callback', @set_jitter); 
             uicontrol('Style','text', 'Position',[410 70 90 20],'String', 'accuracy jitter');
             x=get(accuracy_jitter,'Value');
             jitter_label=uicontrol('Style','text','Position',[630 70 40 20],'String',x);

         end;
         function set_jitter(~,~)
            SAT_params.accuracy_jitter = (get(accuracy_jitter, 'Value')); 
            jitter_label.String=floor(SAT_params.accuracy_jitter);
            save('SAT_params.mat','SAT_params');
         end
     
     
         % Create checkbox for calculating similarity sections through silences or not
         if(tabs)
             calc_silence=uicontrol('style','checkbox','units','pixels','Parent',hTabs(2),'position',[100 10 130 40],'string','calc through silences','Callback', @clc_silence);
             uicontrol('Style','text','Parent',hTabs(3), 'Position',[200 200 100 20], 'String', 'Under Construction');
             uicontrol('Style','text','Parent',hTabs(4), 'Position',[200 100 200 50], 'String', 'Under Construction, but see documentation for template code');
         else
             calc_silence=uicontrol('style','checkbox','units','pixels','position',[700 10 130 40],'string','calc through silences','Callback', @clc_silence);

         end;
         function clc_silence(source,~)
            vl=get(source,'Value');
            SAT_params.calc_silence=vl;
            save('SAT_params.mat','SAT_params');
         end
        
        
        if(tabs)
            Open_sound1=uicontrol('Style','pushbutton', 'String','Load Sound 1', 'Parent',hTabs(1), 'Callback',@loadSound1Callback);
            Open_sound1.Position=[20 180 90 40];
            Open_sound2=uicontrol('Style','pushbutton', 'String','Load Sound 2', 'Parent',hTabs(1), 'Callback',@loadSound2Callback);
            Open_sound2.Position=[120 180 90 40];
            Similarity=uicontrol('Style','pushbutton', 'String','Similarity', 'Parent',hTabs(1), 'Callback',@SimilarityCallback);
            Similarity.Position=[220 180 90 40];
        else
            Open_sound1=uicontrol('Style','pushbutton', 'String','Load Sound 1',  'Callback',@loadSound1Callback);
            set(Open_sound1,'Position',[20 180 90 40]);
            Open_sound2=uicontrol('Style','pushbutton', 'String','Load Sound 2', 'Callback',@loadSound2Callback);
            set(Open_sound2,'Position',[120 180 90 40]);
            Similarity=uicontrol('Style','pushbutton', 'String','Similarity', 'Callback',@SimilarityCallback);
            set(Similarity,'Position',[220 180 90 40]);
        end;

        
        
        
%         uicontrol('Style','popupmenu', 'String','r|g|b','Parent',hTabs(2), 'Callback',@popupCallback);
%         hAx = axes('Parent',hTabs(3));
%         hLine = plot(NaN, NaN, 'Parent',hAx, 'Color','r');
         
        % open the previous settings
        if(exist('SAT_params.mat','file'))
            load('SAT_params.mat');
            % update the GUI to reflect the save parameter values: 
            x=SAT_params.FFT_size;
            set(FFTsize,'Value',x);
            set(FFTsize_Lable,'String',x);
            
            x=SAT_params.FFT_step;
            set(FFTstep,'Value',x);
            set(FFTstep_Lable,'String',x);
            
            x=SAT_params.Frequency_range;
            set(Frequency_range,'Value',x);
            set(Frequency_range_Lable,'String',x);
            
            x=1+SAT_params.similarity_method;
            set(sim_method,'Value',x);
            
            x=SAT_params.similarity_threshold;
            set(thresh,'Value',x*10);
            set(thresh_label,'String',x);
            
            x=SAT_params.similarity_interval;
            set(interval,'Value',x);
            set(interval_label,'String',x);
            
            x=SAT_params.calc_silence;
            set(calc_silence,'Value',x);
            
            

        end;

       
        function loadSound1Callback(~,~)    
            sound1=SAT_sound();
            assignin ('base','sound1',sound1);
        end
    
        function loadSound2Callback(~,~)    
            sound2=SAT_sound();
            assignin ('base','sound2',sound2);
        end
    
    function SimilarityCallback(~,~)    
            SAT_similarity(sound1, sound2);     
        end
         
            %# load data
%             [fName,pName] = uigetfile('*.mat', 'Load data');
%             if pName == 0, return; end
%             data = load(fullfile(pName,fName), '-mat', 'X');

            %# plot
%            set(hLine, 'XData',data.X(:,1), 'YData',data.X(:,2));

            %# swithc to plot tab
 %           set(hTabGroup, 'SelectedTab',hTabs(3));
 %           drawnow
       

    
    % set FFT_window
        function FFT_window(~,~)
          x=floor(get(FFTsize,'Value'));
          set(FFTsize_Lable,'String',x);
          SAT_params.FFT_size=x;
          save('SAT_params.mat','SAT_params');
        end
    
     % set FFT_step
        function FFT_step(~,~)
          x=floor(get(FFTstep,'Value'));
          set(FFTstep_Lable,'String',x);
          SAT_params.FFT_step=x;
          save('SAT_params.mat','SAT_params');
        end
    
    % set frequency range
        function Freq_range(~,~)
          x=get(Frequency_range,'Value');
          set(Frequency_range_Lable,'String',x);
          SAT_params.Frequency_range=x;
          save('SAT_params.mat','SAT_params');
        end
    
    end
    