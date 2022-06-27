function SAT_set_params()
% Here we define all the parameters used by SAT objects and functions
% Including a mechanisms for saving and retreiving the parameters
% SAT_params is the single structure used for all the parameters
global SAT_params;

persistent params_defined;
if isempty(params_defined) % ensures that this function is called only once 
   params_defined=true; % this params will not be stored, it is only to ensure function is called once. 
   
    if(exist('SAT_params.mat','file'))
            load('SAT_params.mat');
    else
   
       % Set params factory default values: 
       % Frequency analysis parameters:
       SAT_params.FFT=1024; % DO NOT CHANGE, Alter FFT_size instead. This is the FFT window, which determine frequency resolution
       SAT_params.FFT_size=400; % number of data samples we FFT, padded with zero to FFT_analysis 
       SAT_params.FFT_step=40; 
       SAT_params.Frequency_range=0.5;%0.5; % by default we look at the lower half of the power spectrum. 
                                      % For example, with a sound file sampled at 44,100Hz and Frequency_range=0.5 the analyis range is from 0 to about 11kHz 

       
                                      
       % Features computation and exclusion options
       SAT_params.pitch_method=0; % 0 = mean frequency; 1 = Yin algorithm
                                      
                                      
       % Features enumeration and normalization values, default is zebra finch normalization:
       % Amplitude normalization 
       SAT_params.amplitude.index=1;
       SAT_params.amplitude.Median=1;
       SAT_params.amplitude.MAD=1;
       % pitch (notice that normalization should be adjusted to the  pitch calcuation method
       SAT_params.pitch.index=2;
       SAT_params.pitch.Median=688;
       SAT_params.pitch.MAD=200;
       % aperiodicity is a YIN feature, should be adjusted when using alternative methods
       SAT_params.aperiodicity.index=3;
       SAT_params.aperiodicity.Median=1;
       SAT_params.aperiodicity.MAD=1;
       % frequency modulation
       SAT_params.FM.index=4;
       SAT_params.FM.Median=0.64;
       SAT_params.FM.MAD=0.34;
       % amplitude modulation 
       SAT_params.AM.index=5;
       SAT_params.AM.Median=0;
       SAT_params.AM.MAD=2.1;
       % Goodness of pitch
       SAT_params.goodness.index=6;
       SAT_params.goodness.Median=0.1;
       SAT_params.goodness.MAD=0.12;
       % Wiener entropy
       SAT_params.entropy.index=7;
       SAT_params.entropy.Median=-1.8;
       SAT_params.entropy.MAD=0.94;
       % mean frequency
       SAT_params.mean_frequency.index=8;
       SAT_params.mean_frequency.Median=4000; % place holder...
       SAT_params.mean_frequency.MAD=500; % place holder... 
       

       % Segmentation params:
       SAT_params.segmentation_feature=SAT_params.amplitude;
       SAT_params.segmentation_secondary_feature=0; % zero = don't use secondary feature
       SAT_params.segmentation_threshold=0.2; 
       SAT_params.segmentation_threshold_direction=1; % 1=more than, -1=less than 
       SAT_params.segmentation_secondary_threshold=1; 
       SAT_params.segmentation_secondary_threshold_direction=1; % 1=more than, -1=less than  
       SAT_params.segmentation_smooth=50; % smooth over 50 samples, zero = don't smooth
       SAT_params.segmentation_secondary_smooth=50; % smooth over 50 samples, zero= don't smooth


       % similarity measurements params:
       SAT_params.similarity_threshold=2; % Median Absolute deviations threshold for similarity measurements 
       SAT_params.time_warping_tolerance=0.9; % how much off diagonal slope is allowed in a similarity section
       SAT_params.similarity_interval=70; % this is the interval for computing global similarity
       SAT_params.similarity_section_min_dur=10; % minimum duration for similarity section in ms
       SAT_params.accuracy_jitter=5; % set a range for finding the best match, default +/- 5 windows (10ms)
       SAT_params.calc_silence=false; % if true than calc similarity sections through silence intervals
       SAT_params.similarity_method=1; % 0 = blur (fast), 1 = time course (slow but more accurate)
    end;
end



