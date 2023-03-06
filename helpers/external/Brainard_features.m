function [features] = Brainard_features(y,fs,varargin)
% Will calculate the following features for audio signals with more than
% 350 samples (~8msec in 44100 Hz sampling rate)
% will calc amplitude trace by smoothing rectivied signal with 3.1msec
% gaussian window with width (sigma) of 2msec 

if numel(y) < 240 
    features = -1;
    disp('Not enough samples. min. is 240.');
    return;
end

dt=1/fs; %time bin

% Create a gaussian window of size ~3msec and width 2msec
L = floor(0.00313*fs); % so that it's 150 in fs=48k
sigma = 0.002*fs;
alpha = (L-1)/2/sigma;
g = gausswin(150,alpha); g=g/sum(g);

rect_y = conv(y.^2,g,'same'); % smoothed rectified signal

win_size = floor(0.008*fs);
step_size = floor(0.002*fs);

% Calculate FF (Fundamental frequency) trace

FF=[];
curr = 1;
while 1
    if curr+win_size+step_size-1 > numel(y)
        currwin = curr:numel(y);
    else
        currwin = curr:(curr+win_size-1);
    end
    a = xcorr(y(currwin),y(currwin)); %acorr(y(currwin));
    a = a(numel(currwin)+1:end);
    a = [a(1)+1;a];
    a_peaks = find(a(2:end-1) > a(1:end-2) & a(2:end-1) > a(3:end));
    try
        FF = [FF;1/((a_peaks(1))*dt)];
    catch em
        '3';
    end
    curr = curr+step_size;
    if curr+win_size >= numel(y)
        break;
    end
end
if ~isempty(FF)
    if numel(FF) > 1
        features.FF = mean(FF(ceil(numel(FF)*0.1):floor(numel(FF)*0.9)));
    else
        features.FF = FF;
    end
else
    features.FF = nan;
    disp('Could not calculate FF');
end

% Time to half peak amplitude
loc_half_peak = min(find(rect_y >= max(rect_y)/2));
features.time_to_half_peak = loc_half_peak*dt; 

% Frequency slope:
if numel(FF)>1
    if numel(FF)>2
        features.FF_slope = mean(diff(FF(ceil(numel(FF)*0.1):floor(numel(FF)*0.9))));
    else
        features.FF_slope = FF(2)-FF(1);
    end
else
    features.FF_slope = nan;
end

% Amplitude slope
P1 = mean(rect_y(ceil(numel(y)*0.1):floor(numel(y)*0.5))); 
P2 = mean(rect_y(ceil(numel(y)*0.5):floor(numel(y)*0.9)));
features.Amplitude_Slope = (P1-P2)/(P1+P2);

% spectral entropy
try
    [Pxx,F] = pwelch(y(ceil(numel(y)*0.1):floor(numel(y)*0.9)),0.005*fs,0.0025*fs);
catch em
    [Pxx,F] = pwelch(y(ceil(numel(y)*0.1):floor(numel(y)*0.9)),0.0035*fs,0.002*fs);
end
Pxx = Pxx/sum(Pxx);
features.Spectral_Entropy = -sum(log(Pxx).*Pxx)/log(2);
% temporal entropy (use 30 bins)
Pa = hist(rect_y(ceil(numel(y)*0.1):floor(numel(y)*0.9)),30);
Pa = Pa/sum(Pa);
features.Temporal_Entropy = -sum(log(Pa).*Pa)/log(2);
% spectrotemporal entropy

% spectrogram
try
    [S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),win_size,win_size-step_size,512,fs);
    Ps = abs(S(F>500 & F<10000,T>dt*numel(y)*0.1 & T<dt*numel(y)*0.9)); Ps = Ps/sum(Ps(:));
    features.SpectroTemporal_Entropy = -sum(log(Ps(:)).*Ps(:))/log(2);
catch em
    [S,F,T,P] = spectrogram((y/(sqrt(mean(y.^2)))),floor(0.005*fs),floor(0.005*fs)-step_size,512,fs);
    Ps = abs(S(F>500 & F<10000,T>dt*numel(y)*0.1 & T<dt*numel(y)*0.9)); Ps = Ps/sum(Ps(:));
    features.SpectroTemporal_Entropy = -sum(log(Ps(:)).*Ps(:))/log(2);
end