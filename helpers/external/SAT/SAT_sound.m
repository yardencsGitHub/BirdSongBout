classdef SAT_sound < handle % there will be only one copy of each SAT_sound
%                  Sound Analysis Tools
%
% This class performes Multitaper spectral analysis and computes acoustic features.
%% Simple usage:
% SAT % Open a GUI for everyting...
% % Open sound file, compute spectral derivatives, accoustic features, segmentation, optional GUI 
% mySound=SAT_sound(); % presents a file open dialog, then persents a GUI with results
% mySound=SAT_sound('file_name'); % analyzes the sound, then persents a GUI with results
% mySound=SAT_sound'file_name', 0); % no GUI option
% 
%%  Object properties:
% mySound.sound -- file_name, wave (sound data), fs = sampling rate 
% mySound.spectral_derivatives and mySound.sonogram are matrixes for sonogram display
% mySound.features include vectors of all acoustic features: amplitude, pitch, entropy, etc. 
% mySound.segmentation_feature is the feature vector used for segmentation
% mySound.signal is a binary segmentation vector
% mySound.num_slices = number of time slices = length of feature vectors 
%
%% Examples of more complex implementations and batchs:
%
% Example 1: find sound segments of a certain pitch
%
% global SAT_params; % make SAT parameters available to manipulate from workspace
% mySound=SAT_sound('example 1.wav',0); % process a zebra finch song, display nothing 
% SAT_params.segmentation_feature=SAT_params.pitch; % use pitch for segmentation
% SAT_params.segmentation_threshold = 3000; % we want to extract high pitch syllables 
% SAT_params.segmentation_threshold_direction=1; % 1=more than, -1=less than 
% SAT_params.segmentation_smooth=20; % smooth the pitch a little bit
% mySound.segment; % segment the sound according to pitch
% That's it!. Now say that you want to also filter by amplitude:
% mySound.signal(mySound.features.amplitude<0.3)=0; % filter out silences
% Let's look at the outcome:
% SAT_plot(mySound); % display the results (just for show)
%
% % Example 2: Batch 
% % Compute a histogram of feature distribution across subjects:
%
% a=dir('*.wav'); % Get file names from folder into array files
% files={a.name};
% recnum=1;
% filenum=1;
% results=zeros(5,50000); % 50,000 initial memory alocation to improve performance
% for i=1:length(files)
%    sound=SAT_sound(char(files(i)),0); % do not plot results
%    results(1,recnum:recnum+sound.num_slices-1)=1:sound.num_slices;
%    results(2,recnum:recnum+sound.num_slices-1)=filenum;
%    results(3,recnum:recnum+sound.num_slices-1)=sound.features.amplitude;
%    results(4,recnum:recnum+sound.num_slices-1)=sound.features.pitch;
%    results(5,recnum:recnum+sound.num_slices-1)=sound.features.entropy;
%    filenum=filenum+1;
% end;
% hist(results(5,:),100); % present histogram of Wiener entropy across animals
%%
    
    properties (SetAccess = public) 
        sound % structure with the raw data. Includes file_name, wave (data), fs (sampling rate)
        metadata % information about the sound (animal ID, DOB, experiment...
        sonogram % matrix containing the sonogram
        spectral_derivs % matrix containing the spectral derivatives
        features % structure with feature vectors: pitch, goodness, FM, AM, entropy.
        segmentation_feature % this is the feature vector for segmentation (can be manipulated)
        signal % a binary vector of the segmentation
        
    end;
    
    properties (SetAccess = private)
        num_slices % this is the number of FFT windows and length of feature vectors
        status % this var is reserved for the event listener, not yet implemented.  
    end
     
    methods

            function obj=SAT_sound(file_name, param)% constructor
                SAT_set_params(); % call this function to either retrive or create parameters for sepctral analysis
                obj.status=false; % this variable store the state of the object, not used yet
                if(~exist('file_name', 'var')) % if no file name is provided, open a dialog for opening a sound file
                    [name, path_name] = uigetfile('*.wav','Select a sound wav file'); 
                    file_name=[path_name name];
                end;
                obj.sound.file_name=file_name;
                [obj.sound.wave, obj.sound.fs]=audioread(file_name); % read the data from the sound file
                obj.calculate_features; % this is the main method for calculating all features.
                if(~exist('param', 'var')) % plot the sound and features by default
                   SAT_plot(obj);
                elseif (param==1) % plot sound and features if second parameter is 1.
                     SAT_plot(obj);
                end;
            end
          
            
            
            
            
            function calculate_features(obj)
                global SAT_params;
                obj.num_slices=1;
                freq_range=floor(SAT_params.FFT*SAT_params.Frequency_range/2); % with 1024 frequency range and 0.5 in SAT_params, range is 256
                tapers = dpss(SAT_params.FFT_size,1.5);
                size=length(obj.sound.wave);
                to_Hz=obj.sound.fs/SAT_params.FFT;
                obj.sonogram=zeros(freq_range, floor(size/SAT_params.FFT_step));
                time_deriv=zeros(freq_range, floor(size/SAT_params.FFT_step));
                freq_deriv=zeros(freq_range, floor(size/SAT_params.FFT_step));
                 
               % This code is by Jordan Matthew Moore:
                pad = zeros(1,SAT_params.FFT_size);
                wave_pad = [pad, obj.sound.wave(:,1)', pad];
                wave_smp = round(SAT_params.FFT_step/2)+1:SAT_params.FFT_step:size;
                for i = 1:length(wave_smp)
                    samps = floor(wave_smp(i)-(SAT_params.FFT_size/2)) + (0:SAT_params.FFT_size-1) + length(pad);
                    window = wave_pad(samps)';
               % replacing this code:
               % for i=1:SAT_params.FFT_step:size-(SAT_params.FFT_size+SAT_params.FFT_step-1)
               %     window=obj.sound.wave(i:i+SAT_params.FFT_size-1); 
                    window1=window.*tapers(:,1);
                    window2=window.*tapers(:,2);
                    % compute the cepstrum: 
                    if any(window1)
                        tmp=rceps(window1);
                    else
                        tmp=zeros(length(window1),1);
                    end
                    %tmp=rceps(window1);
                    obj.features.goodness(obj.num_slices)=max(tmp(25:floor(end/2)));
                    powSpect1=fft(window1,SAT_params.FFT);
                    powSpect2=fft(window2,SAT_params.FFT);
                    r1=abs(powSpect1(1:freq_range))+ abs(powSpect2(1:freq_range));
                    r1=r1.^2;
                    ind=1:freq_range;
                    tmp=sum(r1(10:freq_range)'.*ind(10:freq_range));
                    obj.features.mean_frequency(obj.num_slices)=to_Hz*tmp/sum(r1(10:freq_range));                    
                    obj.sonogram(:,obj.num_slices)=r1; % these are the power data, do log before showing sonogram                    
                    fReal1=real(powSpect1);
                    fImag1=imag(powSpect1);
                    fReal2=real(powSpect2);
                    fImag2=imag(powSpect2);
                    time_deriv(:,obj.num_slices) = (-fReal1(1:freq_range) .* fReal2(1:freq_range)) - (fImag1(1:freq_range) .* fImag2(1:freq_range));
                    freq_deriv(:,obj.num_slices) = (fImag1(1:freq_range) .* fReal2(1:freq_range)) - (fReal1(1:freq_range) .* fImag2(1:freq_range));
                    obj.num_slices=obj.num_slices+1;                    
                end;
                obj.num_slices=obj.num_slices-1; % the last increment in the loop has no values...  
                obj.signal=zeros(1, obj.num_slices); % signal is a binary segmentation vector, false = silence, true = sound. 
                obj.features.goodness(obj.num_slices)=0; % add one more value, to make the vector same size as all others...                
                obj.sonogram=obj.sonogram(:,1:obj.num_slices);   
                obj.features.FM = atan(max(time_deriv) ./ (max(freq_deriv))+0.1);
                cFM = cos(obj.features.FM);
		        sFM = sin(obj.features.FM);
                cc=repmat(cFM,freq_range,1);
                cs=repmat(sFM,freq_range,1);
                spectral_deriv = (time_deriv .* cs + freq_deriv .* cc);
                obj.spectral_derivs=spectral_deriv(:,1:obj.num_slices);
               
                
               %  calculate power in frequency bands
                %dev_power=sqrt(freq_deriv.^2 + time_deriv.^2); % here we use the derivative power instead of power spectrum
                [obj.features.pow1, obj.features.peak1]=max(spectral_deriv(5:floor(freq_range*0.25),1:obj.num_slices));
                obj.features.peak1=to_Hz.*(obj.features.peak1+5);
                [obj.features.pow2, obj.features.peak2]=max(spectral_deriv(floor(freq_range*0.25):floor(freq_range*0.5),1:obj.num_slices));
                obj.features.peak2=to_Hz.*(obj.features.peak2+(freq_range*0.25));
                [obj.features.pow3, obj.features.peak3]=max(spectral_deriv(floor(freq_range*0.5):floor(freq_range*0.75),1:obj.num_slices));
                obj.features.peak3=to_Hz.*(obj.features.peak3+(freq_range*0.5));
                [obj.features.pow4, obj.features.peak4] =max(spectral_deriv(floor(freq_range*0.75):freq_range,1:obj.num_slices));
                obj.features.peak4=to_Hz.*(obj.features.peak4+(freq_range*0.75));
                
               % compute Wiener entropy and amplitude
               m_SumLog=sum(log(obj.sonogram(10:freq_range,:))); % we ignore the power at low frequencies, starting at 10
               m_LogSum=sum(obj.sonogram(10:freq_range,:));
               obj.features.amplitude = 10*(log10(m_LogSum)+7);
               m_LogSum1 = log(m_LogSum / (freq_range-10));
               obj.features.entropy=(m_SumLog / (freq_range-10)) - m_LogSum1;
               
               % compute pitch 
               if SAT_params.pitch_method
                   P.minf0=300;  %   :    Hz - minimum expected F0 (default: 30 Hz)
                   P.maxf0=8000; %   :    Hz - maximum expected F0 (default: SR/(4*dsratio))
                   P.sr=obj.sound.fs;   %:	
                   P.hop=SAT_params.FFT_step; %       :      samples - interval between estimates (default: 32)
                   R=yin(obj.sound.wave,P);
                   obj.features.pitch=R.f0(1:obj.num_slices); 
                   obj.features.pitch= 440*(2.^obj.features.pitch); % convert from octave to Hz
                   obj.features.aperiodicity=R.ap(1:obj.num_slices);
                   obj.features.amplitude=sqrt(R.pwr(1:obj.num_slices)); 
                   obj.features.amplitude = log10(obj.features.amplitude + 1) * 10 ; 
               else
                  obj.features.pitch=obj.features.mean_frequency; 
                  obj.features.aperiodicity=obj.features.goodness;
                  
               end;

               % trim feature arrays to make them all equal
               obj.features.FM=obj.features.FM(1:obj.num_slices);
               
               obj.features.AM=sum(time_deriv);
               obj.features.AM=obj.features.AM(1:obj.num_slices);%./obj.features.amplitude 
               
               
               % remove NANs from the feature vectors
               obj.features.amplitude(isnan(obj.features.amplitude))=0;
               obj.features.pitch(isnan(obj.features.pitch))=0;
               obj.features.FM(isnan(obj.features.FM))=0;
               obj.features.AM(isnan(obj.features.AM))=0;
               obj.features.goodness(isnan(obj.features.goodness))=0;
               obj.features.entropy(isnan(obj.features.entropy))=0;
               obj.features.aperiodicity(isnan(obj.features.aperiodicity))=0;
               obj.features.mean_frequency(isnan(obj.features.mean_frequency))=0;
               
               obj.segment;
               % segment the signal:
               %max_amp=max(obj.features.amplitude);
               %min_amp=min(obj.features.amplitude);
               %thresh=0.1*(max_amp-min_amp)/(max_amp+min_amp);
               %obj.signal=zeros(1, obj.num_slices);
               %obj.signal(obj.features.amplitude>median(obj.features.amplitude))=1;
            end
            
            function segment(obj)
                 global SAT_params;
%                  max_amp=max(obj.features.amplitude);
%                  min_amp=min(obj.features.amplitude);
%                  thresh=0.01*SAT_params.segmentation_threshold*(max_amp-min_amp)/(max_amp+min_amp);
%                  obj.signal=zeros(1, obj.num_slices);
%                  obj.signal(obj.features.amplitude>thresh)=1;   
                 
                
                 % first set a pointer to the primiary segmentation features:
                 switch(SAT_params.segmentation_feature.index)
                     case SAT_params.amplitude.index
                         obj.segmentation_feature=obj.features.amplitude;
                     case SAT_params.pitch.index
                         obj.segmentation_feature=obj.features.pitch;
                     case SAT_params.FM.index
                         obj.segmentation_feature=obj.features.FM;
                     case SAT_params.AM.index
                         obj.segmentation_feature=obj.features.AM;
                     case SAT_params.goodness.index
                         obj.segmentation_feature=obj.features.goodness;
                     case SAT_params.entropy.index
                         obj.segmentation_feature=obj.features.entropy;
                     case SAT_params.mean_frequency.index
                         obj.segmentation_feature=obj.features.mean_frequency;
                     case SAT_params.aperiodicity.index
                         obj.segmentation_feature=obj.features.aperiodicity;       
                 end;
                 
                 % next smooth the segmentation feature
                 if SAT_params.segmentation_smooth
                    obj.segmentation_feature=smooth(obj.segmentation_feature,SAT_params.segmentation_smooth,'sgolay',2);
                 end;
                 obj.signal=zeros(1, obj.num_slices);
                 obj.signal(obj.segmentation_feature>SAT_params.segmentation_threshold)=1;   
                 
                 
%                
%                SAT_params.segmentation_secondary_feature=1; % amplitude, zero = don't use secondary feature
%                SAT_params.segmentation_threshold=1; 
%                SAT_params.segmentation_threshold_direction=1; % 1=more than, -1=less than 
%                SAT_params.segmentation_secondary_threshold=1; 
%                SAT_params.segmentation_secondary_threshold_direction=1; % 1=more than, -1=less than  
%                SAT_params.segmentation_smooth=50; % smooth over 50 samples, zero = don't smooth
%                SAT_params.segmentation_secondary_smooth=50; % smooth over 50 samples, zero= don't smooth
% 
%                  
                 
            end
 
    end
   
end

