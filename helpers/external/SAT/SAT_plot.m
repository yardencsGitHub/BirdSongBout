 function SAT_plot(obj)
 % This is a GUI for SAT_sound, for more information type help SAT_sound
        global SAT_params;
        %global segmentation_slider;
        n_derivs=1;
        n_sonogram=2;
        display=n_sonogram;
        f = figure('pos',[10,300,1200,500]);
        h1 = subplot(2,1,1);
        freq_range=floor(SAT_params.FFT*SAT_params.Frequency_range/2); % with 1024 frequency range and 0.5 in SAT_params, range is 256
        to_Hz=obj.sound.fs/SAT_params.FFT;
        F=1:to_Hz:obj.sound.fs/2;
        derivs=obj.spectral_derivs;
        derivs(derivs<-0.1)=-0.1;
        derivs(derivs>0.1)=0.1;
        
       % This code is by Jordan Matthew Moore
        n_samps = length(obj.sound.wave);
        wave_smp = round(SAT_params.FFT_step/2)+1:SAT_params.FFT_step:n_samps;
        T = (wave_smp/obj.sound.fs); % sonogram pixel centers (sec)
       % replacing this code:
       % sample_dur=1/obj.sound.fs;
       % FFT_slice=sample_dur*SAT_params.FFT_step; % this gives us the duration of each FFT 'slice' in the sonogram
       % duration=FFT_slice*obj.num_slices;
       % tt=0:FFT_slice:duration+10; 
       % T=tt(1:obj.num_slices);
        surf(T,F(1:freq_range),log(obj.sonogram(1:freq_range,1:obj.num_slices)),'edgecolor','none'); axis tight;
        colormap(jet);    
        view(0,90);
        xlabel('Time (Seconds)'); ylabel('Hz');

        h2=subplot(2,1,2);
        %plot(T,obj.features.amplitude);
        %xlim([0,length(obj.features.amplitude)]);

        linkaxes([h1,h2],'x');
        % Create pop-up menu for sonogram choices
        uicontrol('Style', 'popup',...
               'String', {'sonogram','derivatives'},...
               'Position', [20 430 100 50],...
               'Callback', @setmap);   

        % Create pop-up menu for features
         % 1 amplitude, 2 pitch, 3 aper, 4 fm , 5 am,  6 goodness, 7 entropy, 8 mean fequency   
       disp_feature=uicontrol('Style', 'popup',...
               'String', {'Amplitude','Pitch','Aperiodicity','Frequency Modulation', 'Amplitude Modulation',...
               'Goodness of pitch', 'Wiener entropy','Mean Frequency','Frequency bands','User defined'},'Position', [1 210 160 50],'Callback', @setfeature);  
       set(disp_feature,'Value',SAT_params.segmentation_feature.index);


       % Create slider for display contrast
        uicontrol('Style', 'slider','Min',1,'Max',100,'Value',50,'Position', [80 300 20 140],'Callback', @contrast); 

        % Create slider for segmentation
        segmentation_slider=uicontrol('Style', 'slider','Min',1,'Max',100,'Value',50,'Position', [100 60 20 170],'Callback', @segmentation); 
        set(segmentation_slider,'Min', min(obj.segmentation_feature));
        set(segmentation_slider,'Max', max(obj.segmentation_feature));
        vl=SAT_params.segmentation_threshold;
        if vl>min(obj.segmentation_feature) && vl< max(obj.segmentation_feature)
            set(segmentation_slider,'Value',vl);
        else set(segmentation_slider,'Value',median(obj.segmentation_feature));
        end;
        segmentation_label=uicontrol('Style','text', 'Position',[40 80 50 20],'String',round(vl*100)/100);


        % Add a text uicontrol to label the slider.
        uicontrol('Style','text','Position',[155 465 600 20],'String',obj.sound.file_name);

        % Make figure visble after adding all components
        set(f,'Visible','on'); % For R2014a and earlier
        %f.Visible = 'on'; % This code uses dot notation to set properties. Dot notation runs in R2014b and later.


        % Create checkbox for smoothing or not
        smooth_cb=uicontrol('style','checkbox','units','pixels','position',[100 1 150 40],'string','smooth feature','Callback', @smooth_feature);
        set(smooth_cb,'Value',1);
         function smooth_feature(source,~)
            vl=get(source,'Value');
            if(vl)
                SAT_params.segmentation_smooth=floor(get(smooth, 'Value'));
                set(smooth,'Visible','on');

            else 
                SAT_params.segmentation_smooth=0;
                set(smooth,'Visible','off');
            end;
            save('SAT_params.mat','SAT_params');
         end

     % create a slider for smoothing amount:
        smooth=uicontrol('Style', 'slider','Min',0,'Max',200,'Value',50, 'Position', [205 7 130 20], 'Callback', @set_smooth);
        smooth_label=uicontrol('Style','text', 'Position',[335 7 40 20],'String',50);
        function set_smooth(~,~)
            x=floor(get(smooth, 'Value'));
            SAT_params.segmentation_smooth = x; 
            smooth_label.String=SAT_params.segmentation_smooth;
            save('SAT_params.mat','SAT_params');
        end

     % create radio group for segmentation direction > or < threshold
        bg = uibuttongroup('Visible','off','Position',[0 0 .08 .12]);%,'Callback',@bselection);%, 'SelectionChangedFcn',@bselection);
        set(bg,'SelectionChangeFcn',@bselection);
        more_than = uicontrol(bg,'Style','radiobutton',  'String','more >','Position',[10 5 100 30], 'HandleVisibility','off');
        uicontrol(bg,'Style','radiobutton', 'String','less <', 'Position',[10 30 100 30],  'HandleVisibility','off');
        set(bg,'Visible', 'on');
        function bselection(~,~)
            if get(bg,'SelectedObject')==more_than
                SAT_params.segmentation_threshold_direction=1;
            else 
                SAT_params.segmentation_threshold_direction=0;
            end; 
        end


        % set the segmentation slider:
%                 set(segmentation_slider,'Min',min(obj.features.amplitude));
%                 set(segmentation_slider,'Max',max(obj.features.amplitude));
%                 set(segmentation_slider,'Value',median(obj.features.amplitude)); 
%                 SAT_params.segmentation_feature=SAT_params.amplitude;
        redo_segmentation=false;
        segmentation(segmentation_slider);
        redo_segmentation=true;


        function setmap(source,~)
            f = subplot(2,1,1);
            val = get(source,'Value');
            if(val==2)
                display=n_derivs;
                surf(T,F(1:freq_range),derivs(1:freq_range,1:obj.num_slices),'edgecolor','none'); axis tight; 
                colormap(gray);    
                view(0,90);
                xlabel('Time (Seconds)'); ylabel('Hz');  
            else
                display=n_sonogram;
                surf(T,F(1:freq_range),log(obj.sonogram(1:freq_range,1:obj.num_slices)),'edgecolor','none'); axis tight;
                colormap(jet);    
                view(0,90);
                xlabel('Time (Seconds)'); ylabel('Hz');
            end;
        end


        function setfeature(source,~) % 1 amplitude, 2 am, 3 aperio, 4 fm, 5 bands, 6 goodness 7 mean fr, 8 pitch, 9 ent, 10 custom
                                     % 1 amplitude, 2 pitch, 3 aper, 4 fm , 5 am,  6 goodness, 7 entropy, 8 mean fequency   
            f = subplot(2,1,2);
            %x_max=length(obj.features.amplitude);
            val = get(source,'Value');
            cla;
            switch val
                case 1 
                    SAT_params.segmentation_feature=SAT_params.amplitude;
                    plot(T,obj.features.amplitude); 
                    ylim([min(obj.features.amplitude),max(obj.features.amplitude)]);
                    set(segmentation_slider,'Min',min(obj.features.amplitude));
                    set(segmentation_slider,'Max',max(obj.features.amplitude));
                    set(segmentation_slider,'Value',median(obj.features.amplitude)); 

                case 2 
                    SAT_params.segmentation_feature=SAT_params.pitch;
                    plot(T,obj.features.pitch); 
                    ylim([min(obj.features.pitch),max(obj.features.pitch)]);
                    set(segmentation_slider,'Min',min(obj.features.pitch));
                    set(segmentation_slider,'Max',max(obj.features.pitch));
                    set(segmentation_slider,'Value',median(obj.features.pitch))

                case 3 
                    SAT_params.segmentation_feature=SAT_params.aperiodicity;
                    plot(T,obj.features.aperiodicity); 
                    ylim([min(obj.features.aperiodicity),max(obj.features.aperiodicity)]);
                    set(segmentation_slider,'Min',min(obj.features.aperiodicity));
                    set(segmentation_slider,'Max',max(obj.features.aperiodicity));
                    set(segmentation_slider,'Value',median(obj.features.aperiodicity));

                case 4  
                    SAT_params.segmentation_feature=SAT_params.FM;
                    plot(T,obj.features.FM);
                    ylim([min(obj.features.FM),max(obj.features.FM)]);
                    set(segmentation_slider,'Min',min(obj.features.FM));
                    set(segmentation_slider,'Max',max(obj.features.FM));
                    set(segmentation_slider,'Value',median(obj.features.FM))

                case 5 
                    SAT_params.segmentation_feature=SAT_params.AM;
                    plot(T,obj.features.AM); 
                    ylim([min(obj.features.AM),max(obj.features.AM)]);
                    set(segmentation_slider,'Min',min(obj.features.AM));
                    set(segmentation_slider,'Max',max(obj.features.AM));
                    set(segmentation_slider,'Value',median(obj.features.AM));

                case 6  
                     SAT_params.segmentation_feature=SAT_params.goodness;
                     plot(T,obj.features.goodness); 
                     ylim([min(obj.features.goodness),max(obj.features.goodness)]);
                     set(segmentation_slider,'Min',min(obj.features.goodness));
                     set(segmentation_slider,'Max',max(obj.features.goodness));
                     set(segmentation_slider,'Value',median(obj.features.goodness));

                case 7
                    SAT_params.segmentation_feature=SAT_params.entropy;
                    plot(T,obj.features.entropy); 
                    ylim([min(obj.features.entropy),max(obj.features.entropy)]);
                    set(segmentation_slider,'Min',min(obj.features.entropy));
                    set(segmentation_slider,'Max',max(obj.features.entropy));
                    set(segmentation_slider,'Value',median(obj.features.entropy))


                case 8 
                    SAT_params.segmentation_feature=SAT_params.mean_frequency;
                     plot(T,obj.features.mean_frequency);
                     ylim([min(obj.features.mean_frequency),max(obj.features.mean_frequency)]);
                     set(segmentation_slider,'Min',min(obj.features.mean_frequency));
                     set(segmentation_slider,'Max',max(obj.features.mean_frequency));
                     set(segmentation_slider,'Value',median(obj.features.mean_frequency));

                case 9 % frequency bands: I added 0.01 to log to prevent log zero... 
                    %x=1:length(obj.features.amplitude);
                    scatter(T,obj.features.peak1, 6,log( 0.01+obj.features.pow1));
                    hold on; scatter(T,obj.features.peak2, 6, log(0.01+obj.features.pow2));
                    hold on;scatter(T,obj.features.peak3, 6, log(0.01+obj.features.pow3));
                    hold on;scatter(T,obj.features.peak4, 6, log(0.01+obj.features.pow4));
                    ylim([0,max(obj.features.peak4)]);
                    % what should we do with segmentation here?

                case 10 % custom
                    plot(T,obj.signal,'.r','MarkerSize',20); 
                    ylim([0,1]);

            end;
        end


        function contrast(source,~)
            f = subplot(2,1,1);
            val = get(source,'Value');
            val=1/val;
            if display==n_derivs
             derivs=obj.spectral_derivs;
             derivs(derivs<-val)=-val;
             derivs(derivs>val)=val;
             surf(T,F(1:freq_range),derivs(1:freq_range,1:obj.num_slices),'edgecolor','none'); axis tight; 
             colormap(gray);  
            else
                val = get(source,'Value');
                val=100-val;
                tmp=log(obj.sonogram(1:freq_range,1:obj.num_slices));
                mx=max(max(tmp));
                vl=mx*val/100;
                tmp(tmp>vl)=vl;
                surf(T,F(1:freq_range),tmp,'edgecolor','none'); axis tight;
                colormap(jet);  

            end;
             view(0,90);
             xlabel('Time (Seconds)'); ylabel('Hz'); 
        end



        function segmentation(source,~)
            f = subplot(2,1,2);
            SAT_params.segmentation_threshold = get(source,'Value');
            set(segmentation_label,'String',round(SAT_params.segmentation_threshold*100)/100);
            if(redo_segmentation)
                obj.segment;
            end;
            disp=obj.signal;
            mn=min(obj.segmentation_feature);
            mx=max(obj.segmentation_feature);
            ylim([mn,mx]);
            if SAT_params.segmentation_threshold_direction
                disp(:)=mn;
                disp(obj.signal==1)=mx;
            else 
                disp(:)=mx;
                disp(obj.signal==1)=mn;
            end;
            cla;
            plot(T, obj.segmentation_feature); 
            hold on;
            plot(T, disp,'.r','MarkerSize',20);
            save('SAT_params.mat','SAT_params');
        end
 end
               
                
                
             