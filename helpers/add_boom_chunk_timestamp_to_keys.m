function new_keys = add_boom_chunk_timestamp_to_keys(input_keys, input_elements, num_header_chars, path_to_boom, path_to_wav_files, path_to_output)
% Author: Yarden, January 2022
% 
% This function repairs the file name cell array 'keys' of the 'Tweet'
% (birdID_counter_year_month_day_hour_minute_second.wav)
% format. This is because of the old chop code (written by Jeff
% markowitz) that created chunks without a new time stamp in the file name.
% Chunk time stamps were originally saved in the 'idx' folder of the
% chopped audio. This code adds those relative time stamps to the audio
% file names and the keys structure
% 
% The code assumes all file names have the same length.
%
% Inputs:
%   - input_keys, input_elemets: the annotation cell arrays
%   - num_header_chars: The number of characters before the time stamp
%   starts (= length of BirdID + length of counter + 2)
%   - path_to_boom: where the original files exist.
%   - path_to_wav_files: Where the Tweet audio files that need repair
%   exist.
%   - path_to_output: Where the new audio files will be stored
%
% Output: 
%   - new_keys: the fixed keys.
%
