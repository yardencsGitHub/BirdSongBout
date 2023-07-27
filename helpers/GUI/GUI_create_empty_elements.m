function [keys, elements, templates] = GUI_create_empty_elements(DIR,bird_exper_name,exper)
    % creates the basic structures for annotating all wav files in DIR
    % input the bird's name in bird_exper_name
    elements = {};
    d = dir([DIR '/*.wav']);
    keys = {d.name};
    if isempty(exper)
        exper = struct('birdname',bird_exper_name,'expername','Recording from Canary',...
                'desiredInSampRate',48000,'audioCh',0','sigCh',[],'datecreated',date,'researcher','YC');
    end
    ord = [];
    
    for cnt = 1:numel(keys)
        tokens = regexp(keys{cnt},'_','split');
        ord = [ord; str2num(tokens{2})];
        base_struct = struct('exper',exper, ...
                             'filenum',sprintf('%04d',cnt), ...
                             'segAbsStartTimes',[], ...
                             'segFileStartTimes',[], ...
                             'segFileEndTimes',[], ...
                             'segType',[], ...
                             'fs',exper.desiredInSampRate, ...
                             'drugstatus', 'No Drug', ...
                             'directstatus', 'Undirected');
         elements = {elements{:} base_struct};
    end
    [locs,indx] = sort(ord);
    elements = elements(indx);
    keys = keys(indx);
    
    templates.wavs(1).filename = '';
    templates.wavs(1).startTime = 0;
    templates.wavs(1).endTime = 0;
    templates.wavs(1).fs = exper.desiredInSampRate;
    templates.wavs(1).wav = [];
    templates.wavs(1).segType = 1;
end