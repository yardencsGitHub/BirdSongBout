function bsb_create_spectrograms_from_wavs(params)
% This script takes a parameters structure and creates gif and mat
% spectrograms under the folders 'gif' and 'mat'. 
% The list of wav files to convert is a cell array
% 'wavs' in the parameters file created by ...GitHub/BirdSongBout/helpers/create_parameter_file_for_annotation_pipeline.m 
keysinfile = 'wavs_list';
DIR = params.workDIR;
GitHubDir = params.GitHubDir;
wavs = params.wavs;
%% repositories
addpath(genpath(fullfile(GitHubDir,'zftftb')),'-end');
%% Create spectrogram image data
% create spectrograms
% save gif,mat,
if ~exist(fullfile(DIR,'gif'),'dir')
	mkdir(fullfile(DIR,'gif'));
end
if ~exist(fullfile(DIR,'mat'),'dir')
	mkdir(fullfile(DIR,'mat'));
end

clipping=[-2 2];
disp_band=[1 9e3];
colors='hot';
Nwavs = numel(wavs);
for file_cnt = 1:numel(wavs)
    
    wavname =  [wavs{file_cnt}(1:end-3) 'wav'];
    display(wavname)
    outname = wavname(1:end-4);
    [signal,fs] = audioread(wavname);
    [s,f,t]=zftftb_pretty_sonogram(signal,fs,'len',16.7,'overlap',14,...
                'zeropad',0,'norm_amp',1,'clipping',clipping);
    
    startidx=max([find(f<=disp_band(1))]);
    stopidx=min([find(f>=disp_band(2))]);

    im=s(startidx:stopidx,:)*62;
    im=flipdim(im,1);

    imwrite(uint8(im),colormap([ colors '(63)']),fullfile(DIR,'gif',[ outname '.gif']),'gif');
    save(fullfile(DIR,'mat',[ outname '.mat']),'f','t','s');
    disp([Nwavs file_cnt])
end
    

