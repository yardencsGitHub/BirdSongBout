function [DATA, durations, gaps, phrase_idxs, syllables, file_numbers, file_day_indices,song_durations, file_date_times, song_start_offests, brainard_features, tchernichovski_features] = bsb_convert_annotation_to_syllable_strings(path_to_annotation_file,ignore_dates,ignore_entries,join_entries,include_zero,min_phrases,varargin)
% This script takes an annotation file and the required DATA structure to
% run Jeff Markowitz's PST
% Inputs:
%   path_to_annotation_file - Full or relative
%   ignore_dates - days of data to be ignored.
%   ignore_entries - A vector of label numbers to ignore completely. 
%   join_entries - A cell of vectors, each containing a >1 number of labels
%   to treat as belonging to the same state. The lists shouldn't overlap
%   (incl. with the ignored lables)
%   include_zero - should 0 be a label?
% 
% Optional field (default),value pairs:
%   onset_sym ('1') - set this character as the beginning of each song
%   offset_sym ('2') - set this character as the end of each song
%   orig_syls ([]) - determine which syllables to look for and ignore
%   others. WARNING: if the annotation file includes syllables with tags
%   that are not joined or ignored and not appearing in this vector then
%   the results will be ofsetted and corrupted.
%   MaxSep (0.5) - maximal phrase separation within a bout (sec)
%   calc_brainard ('') - calculate Michael Brainard stype per-syllable
%   acoustic features using the wav files in this folder (string)
%   calc_tchernichovski ('') - calculate Ofer Tchernichovski stype per-syllable
%   acoustic features using the wav files in this folder (string)
%
% Output:
%   DATA - a cell array of strings - one character per syllable
%   durations - a cell array of vectors - durations of all syllables
%   gaps - cell array of vectors - durations of all intersylabic gaps
%   phrase_idxs - cell array of vectors - phrae index of all syllables
%   syllables - vector - all syllables - the first 2 elements are the edge
%   symbols (if used)
%   file_numbers - vector - the file index (in the sequence of files) of each song
%   file_day_indices - vector - the day index in the sequence of days of
%   each file (no gaps because of dates skipped)
%   brainard\tchernichovski features - cell array of matrices - if
%   calculated (set 'calc_brainard' or 'calc_tchernichovski' to the path of the WAV files to
%   calculate) will include the matrix (feature x syllable) of median
%   feature value per syllable.
%   Brainard features calculated with Brainard_features.m (in
%   BirdSongBout/helpers/external):
%                           Fundamental Frequency - averaged at middle 80%
%                              of syllable (8msec windows, step = 2msec)
%                           Time to half-peak amplitude (smoothed rectified
%                             wav, using 2msec gaussian)
%                           Frequency slope. Frequency slope was defined as the mean derivative of
%                             fundamental frequency over the central 80% of the syllable
%                           Amplitude slope. Amplitude slope was defined as follows: Amplitude
%                             slope  (P2 - P1)/(P2 +P1), where P1 and P2 are the average amplitude of the first and second halves of the
%                             syllable, respectively.
%                           Spectral entropy
%                           Temporal Entropy
%                           Spectrotemporal entropy
%   Tchernichovski features are calculated with SAT_sound (in
%   BirdSongBout/helpers/external/SAT). The continuous variables are
%   interpolated to sampling at 1000Hz and the median value is taken for
%   each syllable. The features are:
%                     1: goodness      
%                     2: mean_frequency
%                     3: FM            
%                     4: pow1          
%                     5: peak1         
%                     6: pow2          
%                     7: peak2         
%                     8: pow3          
%                     9: peak3         
%                     10:pow4          
%                     11:peak4         
%                     12:amplitude     
%                     13:entropy       
%                     14:pitch         
%                     15:aperiodicity  
%                     16:AM            
AlphaNumeric = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz';
onset_sym = '1';
offset_sym = '2';
orig_syls = [];
MaxSep = 0.5; % maximal phrase separation within a bout (sec)
MaxSyllableSep = 0.45; % maximal within phrase gap (beyond which phrases will split)
calc_brainard = '';
calc_tchernichovski = '';
nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
		case 'maxsep'
			MaxSep=varargin{i+1};
        case 'maxsyllablesep'
			MaxSyllableSep=varargin{i+1};
        case 'onset_sym'
            onset_sym = varargin{i+1};
        case 'offset_sym'
            offset_sym = varargin{i+1};
        case 'syllables'
            orig_syls = varargin{i+1};
        case 'calc_brainard'
            calc_brainard = varargin{i+1};
        case 'calc_tchernichovski'
            calc_tchernichovski = varargin{i+1};
    end
end

if ~exist(path_to_annotation_file)
    DATA = [];
    file_numbers = [];
    display(['Could not open annotation file: ' path_to_annotation_file])
    return;
end

flag = 0;
join_entries = join_entries(:);
if ~isempty(join_entries)
    for i = 1:numel(join_entries)
        if ~isempty(intersect(join_entries{i},ignore_entries))
            flag = 1;
        end
        for j = i+1:numel(join_entries)
            if  ~isempty(intersect(join_entries{i},join_entries{j}))
                flag = 1;
            end
        end
    end
end
   
if flag == 1
    resmat = [];
    state_labels = [];
    disp('join or ignore lists overlap')
    return;
end
if ~isempty(calc_brainard)
    if exist(calc_brainard)
        wav_folder = calc_brainard;
    else
        calc_brainard = '';
    end
end
if ~isempty(calc_tchernichovski)
    if exist(calc_tchernichovski)
        wav_folder = calc_tchernichovski;
    else
        calc_tchernichovski = '';
    end
end
load(path_to_annotation_file);

if isempty(orig_syls)
    syllables = [];
    for fnum = 1:numel(keys)  
        syllables = unique([syllables unique(elements{fnum}.segType)']);
    end
    syllables = setdiff(syllables,ignore_entries);
    if (include_zero == 0)
        syllables = setdiff(syllables,0);
    end
    for i = 1:numel(join_entries)
        syllables = setdiff(syllables,join_entries{i}(2:end));
    end
else
    syllables = orig_syls;
end
edge_syms = [];
if ~isempty(onset_sym) 
    edge_syms = [-1000];
end
if ~isempty(offset_sym) 
    edge_syms = [edge_syms 1000];
end

syllables = [edge_syms syllables];
AlphaNumeric = [onset_sym offset_sym AlphaNumeric];

DATA = {}; durations = {}; gaps = {}; phrase_idxs = {}; brainard_features = {}; tchernichovski_features = {};
actual_syllables = [];
file_date_nums = [];
file_numbers = [];
song_durations = []; file_date_times=[]; song_start_offests=[];
% Main loop: Go over all files
for fnum = 1:numel(keys)
    disp([fnum numel(keys)])
    curr_date_num = return_date_num(keys{fnum});
    if ~isempty(ignore_dates)
        if ismember(return_date_num(keys{fnum}),datenum(ignore_dates))
            '4';
            continue;
        end
    end
    element = elements{fnum};
    locs = find(ismember(element.segType,ignore_entries));
    element.segAbsStartTimes(locs) = [];
    element.segFileStartTimes(locs) = [];
    element.segFileEndTimes(locs) = [];
    element.segType(locs) = [];  
    for i = 1:numel(join_entries)
        locs = find(ismember(element.segType,join_entries{i}));
        element.segType(locs) = join_entries{i}(1);
    end
    % if needed to calculate features
    if ~isempty(calc_tchernichovski)
        wav_fname = fullfile(wav_folder,keys{fnum});
        tch_features = calculate_tch_features(wav_fname,element);
    end
    if ~isempty(calc_brainard)
        wav_fname = fullfile(wav_folder,keys{fnum});
        try
            br_features = calculate_br_features(wav_fname,element);
        catch emm
            '*';
        end
    end
    % Now calculate all data per songs
    try
        phrases = bsb_return_phrase_times(element,'max_separation',MaxSyllableSep);
        curr_mids = (element.segFileEndTimes + element.segFileStartTimes)/2;
        curr_durations = (element.segFileEndTimes - element.segFileStartTimes);
        curr_gaps = (element.segFileStartTimes(2:end) - element.segFileEndTimes(1:end-1));
        
        currsyls = [-1000 phrases.phraseType(1)];
        curr_song_onset = phrases.phraseFileStartTimes(1);
        locs = find(curr_mids > phrases.phraseFileStartTimes(1) & curr_mids < phrases.phraseFileEndTimes(1));
        currDATA = [repmat(AlphaNumeric(syllables == phrases.phraseType(1)),1,numel(locs))];
        if ~ismember(phrases.phraseType(1),syllables)
            warning(['Syllable number ' num2str(phrases.phraseType(1)) ' does not exist in valid syllables. Results may be corrupt']);
        end
        curr_idxs = ones(1,numel(locs));
        curr_locs = [locs];
        curr_phrase_idx = 1;
        curr_song_datetime = get_date_from_file_name(keys{fnum}); % This function is specific to one file name format.
        % Consider using bsb_extrat_date_string_trom_filename in the future
        for phrasenum = 1:numel(phrases.phraseType)-1
            if (phrases.phraseFileStartTimes(phrasenum + 1) -  phrases.phraseFileEndTimes(phrasenum) <= MaxSep)
                locs = find(curr_mids > phrases.phraseFileStartTimes(phrasenum + 1) & curr_mids < phrases.phraseFileEndTimes(phrasenum + 1));
                currDATA = [currDATA repmat(AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1)),1,numel(locs))];
                if ~ismember(phrases.phraseType(phrasenum + 1),syllables)
                    warning(['Syllable number ' num2str(phrases.phraseType(phrasenum + 1)) ' does not exist in valid syllables. Results may be corrupt']);
                end
                currsyls = [currsyls phrases.phraseType(phrasenum + 1)];
                curr_idxs = [curr_idxs ones(1,numel(locs))*(curr_phrase_idx + 1)];
                curr_phrase_idx = curr_phrase_idx + 1;
                curr_locs = [curr_locs locs];
            else
                if (numel(unique(curr_idxs)) >= min_phrases)
                    DATA = {DATA{:} [onset_sym currDATA offset_sym]};
                    file_numbers = [file_numbers fnum];
                    file_date_nums = [file_date_nums; curr_date_num];
                    actual_syllables = unique(union(actual_syllables,unique([currsyls 1000])));
                    durations = {durations{:} curr_durations(curr_locs)}; 
                    gaps = {gaps{:} curr_gaps(curr_locs(1:end-1))}; 
                    phrase_idxs = {phrase_idxs{:} curr_idxs};
                    song_durations = [song_durations phrases.phraseFileEndTimes(phrasenum) - curr_song_onset];
                    file_date_times = [file_date_times curr_song_datetime];
                    song_start_offests = [song_start_offests curr_song_onset];
                    if ~isempty(calc_tchernichovski)
                        tchernichovski_features = {tchernichovski_features{:} tch_features(:,curr_locs)};
                    end
                    if ~isempty(calc_brainard)
                        brainard_features = {brainard_features{:} br_features(:,curr_locs)};
                    end
                end
                locs = find(curr_mids > phrases.phraseFileStartTimes(phrasenum + 1) & curr_mids < phrases.phraseFileEndTimes(phrasenum + 1));
                currDATA = [repmat(AlphaNumeric(syllables == phrases.phraseType(phrasenum + 1)),1,numel(locs))];
                curr_idxs = [ones(1,numel(locs))];
                curr_phrase_idx = 1;
                curr_locs = [locs];
                currsyls = [-1000 phrases.phraseType(phrasenum + 1)];
                curr_song_onset = phrases.phraseFileStartTimes(phrasenum + 1);
            end  
        end
        if (numel(unique(curr_idxs)) >= min_phrases)
            DATA = {DATA{:} [onset_sym currDATA offset_sym]};
            file_numbers = [file_numbers fnum];
            file_date_nums = [file_date_nums; curr_date_num];
            actual_syllables = unique(union(actual_syllables,unique([currsyls 1000])));
            durations = {durations{:} curr_durations(curr_locs)}; 
            gaps = {gaps{:} curr_gaps(curr_locs(1:end-1))}; 
            phrase_idxs = {phrase_idxs{:} curr_idxs};
            song_durations = [song_durations phrases.phraseFileEndTimes(end) - curr_song_onset];
            file_date_times = [file_date_times curr_song_datetime];
            song_start_offests = [song_start_offests curr_song_onset];
            if ~isempty(calc_tchernichovski)
                tchernichovski_features = {tchernichovski_features{:} tch_features(:,curr_locs)};
            end
            if ~isempty(calc_brainard)
                brainard_features = {brainard_features{:} br_features(:,curr_locs)};
            end
        end
        if numel(brainard_features{1}) == 1
            '*';
        end
    catch em
        '8';
    end
end
actual_syllables = unique(actual_syllables);
no_show_syllables = setdiff(syllables,actual_syllables);
syllables(ismember(syllables,no_show_syllables)) = [];
unique_file_date_nums = unique(file_date_nums);
file_day_indices = [];
for fnum = 1:numel(file_date_nums)
    file_day_indices = [file_day_indices; find(unique_file_date_nums == file_date_nums(fnum))];
end
end
function res = return_date_num(filestr)
    tokens = regexp(filestr,'_','split');
    res = datenum(char(join(tokens(3:5),'_')));
end

function d = get_date_from_file_name(filename,varargin)
    d='';
    sep = '_';
    date_idx = 3:8;
    return_datetime = 1;
    nparams = numel(varargin);
    for i=1:2:nparams
        switch lower(varargin{i})
            case 'sep'
			    sep=varargin{i+1};
            case 'date_idx'
			    date_idx=varargin{i+1};
            case 'return_datetime'
			    return_datetime=varargin{i+1};
        end
    end
    tokens = split(filename,sep);
    last_string = split(tokens{date_idx(6)},'.');
    last_string = last_string{1};
    if return_datetime == 1
        switch length(date_idx)
            case 6
                d = datetime(str2num(tokens{date_idx(1)}),...
                    str2num(tokens{date_idx(2)}),...
                    str2num(tokens{date_idx(3)}),...
                    str2num(tokens{date_idx(4)}),...
                    str2num(tokens{date_idx(5)}),...
                    str2num(last_string));
            case 5
                d = datetime(str2num(tokens{date_idx(1)}),...
                    str2num(tokens{date_idx(2)}),...
                    str2num(tokens{date_idx(3)}),...
                    str2num(tokens{date_idx(4)}),...
                    str2num(last_string),...
                    str2num(00));
            otherwise
                disp('Error in date format');
                d = 0;
        end
    else
        d = char(join(tokens(date_idx),'_'));
    end

end
% function d = get_date_from_file_name(filename,varargin)
%     d='';
%     sep = '_';
%     date_idx = 3:5;
%     nparams = numel(varargin);
%     for i=1:2:nparams
%         switch lower(varargin{i})
%             case 'sep'
% 			    sep=varargin{i+1};
%             case 'date_idx'
% 			    date_idx=varargin{i+1};
%         end
%     end
%     tokens = split(filename,sep);
%     d = char(join(tokens(date_idx),'_'));
% 
% end

function br_features = calculate_br_features(wav_fname,element)
    [y,fs] = audioread(wav_fname); time_steps_y = ([1:numel(y)]-0.5) * (1/fs);
    br_features = zeros(7,numel(element.segType));
    for segnum = 1:numel(element.segType)
        try 
            bf = Brainard_features(y((time_steps_y >= element.segFileStartTimes(segnum)) & (time_steps_y <= element.segFileEndTimes(segnum))),fs);
            br_features(:,segnum) = [bf.FF; bf.time_to_half_peak; bf.FF_slope; bf.Amplitude_Slope; bf.Spectral_Entropy; bf.Temporal_Entropy; bf.SpectroTemporal_Entropy];
        catch em
            disp('*');
            curr_data_points = y((time_steps_y >= element.segFileStartTimes(segnum)) & (time_steps_y <= element.segFileEndTimes(segnum)));
            curr_n_datapoints = numel(curr_data_points);
            curr_data_points = [curr_data_points; zeros(240-curr_n_datapoints,1)];
            bf = Brainard_features(curr_data_points,fs);
            br_features(:,segnum) = [bf.FF; bf.time_to_half_peak; bf.FF_slope; bf.Amplitude_Slope; bf.Spectral_Entropy; bf.Temporal_Entropy; bf.SpectroTemporal_Entropy];
        end
    end
end

function tch_features = calculate_tch_features(wav_fname,element)
    try
        currSound=SAT_sound(wav_fname,0); fs = currSound.sound.fs; T_sound = (1/fs)*numel(currSound.sound.wave);
    catch em
        'err';
    end
    dt_features = T_sound / currSound.num_slices;
    t_in = ([1:currSound.num_slices]-0.5) * dt_features;
    t_out = [0.0005:0.001:T_sound];
    feature_names = fields(currSound.features)';
    currSound.features.goodness = interp1(t_in,currSound.features.goodness,t_out,'linear','extrap');
    currSound.features.mean_frequency = interp1(t_in,currSound.features.mean_frequency,t_out,'linear','extrap');
    currSound.features.FM = interp1(t_in,currSound.features.FM,t_out,'linear','extrap');
    currSound.features.pow1 = interp1(t_in,currSound.features.pow1,t_out,'linear','extrap');
    currSound.features.peak1 = interp1(t_in,currSound.features.peak1,t_out,'linear','extrap');
    currSound.features.pow2 = interp1(t_in,currSound.features.pow2,t_out,'linear','extrap');
    currSound.features.peak2 = interp1(t_in,currSound.features.peak2,t_out,'linear','extrap');
    currSound.features.pow3 = interp1(t_in,currSound.features.pow3,t_out,'linear','extrap');
    currSound.features.peak3 = interp1(t_in,currSound.features.peak3,t_out,'linear','extrap');
    currSound.features.pow4 = interp1(t_in,currSound.features.pow4,t_out,'linear','extrap');
    currSound.features.peak4 = interp1(t_in,currSound.features.peak4,t_out,'linear','extrap');
    currSound.features.amplitude = interp1(t_in,currSound.features.amplitude,t_out,'linear','extrap');
    currSound.features.entropy = interp1(t_in,currSound.features.entropy,t_out,'linear','extrap');
    currSound.features.pitch = interp1(t_in,currSound.features.pitch,t_out,'linear','extrap');
    currSound.features.aperiodicity = interp1(t_in,currSound.features.aperiodicity,t_out,'linear','extrap');
    currSound.features.AM = interp1(t_in,currSound.features.AM,t_out,'linear','extrap');
    tch_features = zeros(16,numel(element.segType));
    for segnum = 1:numel(element.segType)
        for f_num = 1:numel(feature_names)
            tch_features(f_num,segnum) = eval(['nanmedian(currSound.features.' feature_names{f_num} '((t_out >= element.segFileStartTimes(segnum)) & (t_out <= element.segFileEndTimes(segnum))))']);
        end
    end
end

