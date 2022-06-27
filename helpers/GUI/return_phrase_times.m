function res = return_phrase_times(element,varargin)
    max_separation = 0.25;
    nparams=length(varargin);
    for i=1:2:nparams
        switch lower(varargin{i})
            case 'max_separation'
                max_separation = varargin{i+1};
        end
    end
    t_onset = [];
    t_offset = [];
    segtypes = [];
    if numel(element.segType) ~=0
        t_onset = element.segFileStartTimes(1);
        %t_offset = element.segFileEndTimes(1);
        segtypes = element.segType(1);
        
        for segnum = 2:numel(element.segType)
            if (element.segType(segnum-1) ~= element.segType(segnum)) || ...
                    ((element.segFileStartTimes(segnum)-element.segFileEndTimes(segnum-1)) > max_separation)
                t_onset = [t_onset; element.segFileStartTimes(segnum)];
                t_offset = [t_offset; element.segFileEndTimes(segnum-1)];
                segtypes = [segtypes; element.segType(segnum)];
            end
        end
        t_offset = [t_offset; element.segFileEndTimes(end)];
    end
    res.phraseFileStartTimes = t_onset;
    res.phraseFileEndTimes = t_offset;
    res.phraseType = segtypes;
    
    