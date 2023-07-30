function new_keys = bsb_repair_duplicate_keys(input_keys, input_elements, num_header_chars, min_gap, time_buffer)
% Author: Yarden, January 2022
% 
% This function repairs the file name cell array 'keys' of the 'Tweet'
% (birdID_counter_year_month_day_hour_minute_second.wav)
% format in the case consecutive files have the same name (except the
% counter). This may happen because of the old chop code (written by Jeff
% markowitz) that created chunks without a new time stamp in the file name.
% 
% The code assumes all file names have the same length.
%
% Inputs:
%   - input_keys, input_elemets: the annotation cell arrays
%   - num_header_chars: The number of characters before the time stamp
%   starts (= length of BirdID + length of counter + 2)
%   - min_gap: minimal gap between songs in seconds.
%   - time buffer: in seconds, how much more time to add to the gap (should
%   be small .. say 0.1)
%
% Output: 
%   - new_keys: the fixed keys.
%
%   Example: new_keys = repair_duplicate_keys(keys, elements, 13, 1, 0.1);
%   Assumes there are 13 charachters in file names before the time stamp.
%   Imposes gap of 1 sec between songs and 0.1 sec. buffer.

new_keys = input_keys(1);    
curr_time_stamp = input_keys{1}(num_header_chars+1:end);
curr_time_addition = 0;
for key_indx = 2:numel(input_keys)
    if strcmp(input_keys{key_indx}(num_header_chars+1:end),curr_time_stamp)
        last_song_duration = input_elements{key_indx - 1}.segFileEndTimes(end);
        curr_time_addition = curr_time_addition + last_song_duration + min_gap + time_buffer;
        % get the file time from its name
        if key_indx == 2874
            's';
        end
        tokens = split(input_keys{key_indx},'.');
        tokens = split(tokens{1},'_');
        if numel(tokens) == 7
            tokens{8} = '00'; % some (old) annotation files do not have the seconds recorded in the file name 
        end
        % update the file time (in seconds)
        file_time = str2num(tokens{6})*3600 + str2num(tokens{7})*60 + str2num(tokens{8});
        new_file_time = file_time + curr_time_addition;
        % calculate the new time stamp hours, minutes, seconds
        add_hours = floor(new_file_time/3600);
        add_minutes = floor((new_file_time - 3600*add_hours)/60);
        add_seconds = floor((new_file_time - 3600*add_hours - 60*add_minutes));
        % update keys
        tokens{6} = sprintf('%02d',add_hours);
        tokens{7} = sprintf('%02d',add_minutes);
        tokens{8} = sprintf('%02d',add_seconds);
        new_filename = join(tokens,'_'); new_filename = [new_filename{1} '.wav'];
        new_keys(key_indx) = {new_filename};
    else % if the entry is not a duplicate
        curr_time_stamp = input_keys{key_indx}(num_header_chars+1:end);
        curr_time_addition = 0;
        new_keys(key_indx) = input_keys(key_indx);
    end
end