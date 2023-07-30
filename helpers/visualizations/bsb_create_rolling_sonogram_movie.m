function bsb_create_rolling_sonogram_movie(wav_filepath,varargin)
% This function takes an audio file and creates a movie of its sonogram
    dt = 1/30;
    window = 3;
    fmin = 500;
    fmax = 15000;
    fig_pos = [584   917   976   248];
    output_fullpath = 'test2.avi';
    nft = 512;

    nprm=length(varargin);
    for i_idx=1:2:nprm
        switch lower(varargin{i_idx})
            case 'dt'
                dt = varargin{i_idx+1};
            case 'window'
                window = varargin{i_idx+1};
            case 'fmin'
                fmin = varargin{i_idx+1};
            case 'fmax'
                fmax = varargin{i_idx+1};
            case 'fig_pos'
                fig_pos = varargin{i_idx+1};
            case 'output_fullpath'
                output_fullpath = varargin{i_idx+1};
            case 'nfft'
                nft = varargin{i_idx+1};
        end
    end

    [y,fs] = audioread(wav_filepath);
    [S,F,T] = mt_spectrogram(y,fs,1,'nfft',nft);
    power = log(abs(S)+quantile(S(:),0.9));
    cmin = quantile(power(:),0.00); cmax = quantile(power(:),1);
    
    v = VideoWriter(output_fullpath,'MPEG-4');
    open(v);
    figure('Position',fig_pos); 
    for t=0:dt:max(T)
        slice = get_slice(power,T,t,window);
        imagesc(slice((F>=fmin) & (F<=fmax),:)); axis xy; colormap(1-gray); caxis([cmin,cmax]);
        xticks([]); yticks([]);
        set(gca,'Position',[0 0 1 1]);
        frame = getframe(gcf);
        writeVideo(v,frame);
    end
    close(v);
  



    function S_slice = get_slice(inpS,T,tmin,window)
        idx = find((T>=tmin) & (T<tmin+window));
        S_slice = inpS(:,idx);
        if T(idx(end))-T(idx(1)) < window
            idx2add = round((window - (T(idx(end))-T(idx(1))))/(T(2)-T(1)));
            S_slice = [S_slice ones(size(inpS,1),idx2add)*min(inpS(:))];
        end
    end
    function [S,F,T,P] = mt_spectrogram(sig_in,samplerate,time_step_ms,varargin)
        spectrogram_type = 'tapered';
        switch spectrogram_type
            case 'regular'
                [S,F,T,P] = spectrogram(sig_in,220,220-44,512,samplerate);
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
                %fm = atan(max(dx(F>=settings_params.fmin))./max(dy(F>=settings_params.fmin))+eps);
                %P = repmat(cos(fm),length(F),1).*dx + repmat(sin(fm),length(F),1).*dy;
        end
    end
end

