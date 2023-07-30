function tot = bsb_hmm_segment_syllables(s,labels,fbins)
% This script takes the spectrogram s (time x freq) and an indexing vector
% 'labels'
% (integers, e.g. annotating the timebins in diff. phrases) and returns a vector of 0s,1s for silence and audition segments
% the input 'fbins' = [bin_min bin_max] holds the min (max) frequency bins to sum the spectrogram.

% The states are estimated using a 2-state HMM with gaussian emissions

    nstates = 2;
    dlabels = find(diff([0 labels 0]) ~= 0);
    tot = zeros(1,size(s,2));
    for loc = 1:numel(dlabels)-1
        if (labels(dlabels(loc)) ~= 0)
            warncnt = 0; 
            lastwarn('');
            while warncnt < 10
                sig = sum(s(fbins(1):fbins(2),dlabels(loc):dlabels(loc+1)-1)).^(1/3);
                sig = sig-min(sig);
                sig = sig+randn(size(sig))*1e-2;
                [model, loglikHist] = hmmFit(sig, nstates,'student');             
                map_path = hmmMap(model, sig)-1;
                if mean(sig(map_path==1)) < mean(sig(map_path==0))
                    map_path = 1-map_path;
                end
                if ~any(map_path == 1)
                    map_path = ones(size(map_path));
                end
                [msgstr, msgid] = lastwarn;
                if isempty(msgid)
                    break;
                else
                    warncnt = warncnt + 1;
                end
            end

            tot(dlabels(loc):dlabels(loc+1)-1) = map_path;
        end

    end


%%% option to create images to test results    
%     sig = sum(s(5:100,:));
%     figure; h1 = subplot(2,1,1); plot(sig); hold on; plot(tot*10);
%     axis tight
%     h2 = subplot(2,1,2); imagesc(s);
%     linkaxes([h1,h2],'x')

