function Ims = bsb_create_display_sonograms(WavPath,file_names,time_windows,output_folder,varargin)
% this script makes spectrograms for display
% Inputs:
%   WavPath (string) - path where the audio files live
%   file_names (cell array) - file names to show
%   time_windows (cell array) - each cell holds the start and stop times
%   output_folder (string) - path to output folder
% Field,Value optional inputs:
%   pixel_per_sec (integer) - resolution
%   GitHubFolder (string) - path to GitHub root
%   clipping
%   disp_band
pixel_per_sec = 1000;
clipping = [-2 2];
disp_band=[350 9e3];
GitHubFolder = '/Users/yardenc/Documents/GitHub/';

nparams = length(varargin);
for i=1:2:nparams
    switch lower(varargin{i})
        case 'pixel_per_sec'
		    pixel_per_sec=varargin{i+1};
        case 'clipping'
		    clipping=varargin{i+1};
        case 'disp_band'
		    disp_band=varargin{i+1};
        case 'githubfolder'
		    GitHubFolder=varargin{i+1};
    end
end

addpath(genpath(fullfile(GitHubFolder,'zftftb/')));
Ims = {};
for fnum = 1:numel(file_names)
    fname = fullfile(WavPath, file_names{fnum});
    [y,fs] = audioread(fname);
    %[S,F,T,P] =
    %spectrogram((y/(sqrt(mean(y.^2)))),440*2,2*(440-88),1024*1,fs);
    %%440,440-88  'len',16.7,'overlap',14
    [s,f,t]=zftftb_pretty_sonogram(y,fs,'len',26.7,'overlap',24,...
                'zeropad',0,'norm_amp',1,'clipping',clipping);
    startidx=max([find(f<=disp_band(1))]);
    stopidx=min([find(f>=disp_band(2))]);
    time_window = time_windows{fnum};
    first_time_idx = max([find(t <= time_window(1))]);
    last_time_idx = min([find(t >= time_window(2))]);

    im=s(startidx:stopidx,first_time_idx:last_time_idx)*64;
    im=flipdim(im,1);
    imwrite(uint8(63-im),colormap([ 'gray' '(63)']),fullfile(output_folder,[ file_names{fnum} '.gif']),'gif');
    Ims{fnum} = im;
    
end

