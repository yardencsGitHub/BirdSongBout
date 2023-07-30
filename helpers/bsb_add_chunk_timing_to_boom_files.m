function bsb_add_chunk_timing_to_boom_files(DIR,filename_expression)
% This script gets a directory DIR that has only subdirectories with date names as produced by 'zftftb_song_chop.m'
% Each date folder in the format yyyy-mm-dd must have the subfolder
% 'chop_data' that has the subfolders 'wav', 'idx', and 'gif'
% These folders have the audio and spectrogram files with the same name.

% The script goes over the folders and adds the chunk timing to the file
% names. This prevents duplicate file names as well as preserves the true
% start times for all songs.


daily_dirs = dir(DIR);
daily_dirs = daily_dirs([daily_dirs.isdir] == 1);
daily_dirs = daily_dirs(cellfun(@numel,{daily_dirs.name}) == 10);
% check folders are dates
try 
    cellfun(@datenum,{daily_dirs.name});
catch em
    disp('Some folders are not named by dates');
    return;
end

tot_dirnum = numel(daily_dirs); 
for dirnum = 1:tot_dirnum 
    try
        datenum(daily_dirs(dirnum).name);
        
        FILES = dir(fullfile(DIR,daily_dirs(dirnum).name,'chop_data','wav','*.wav'));
        for fnum = 1:numel(FILES)
            [filepath,filename,ext] = fileparts(FILES(fnum).name);
            curr_file_datetime = return_dateobj(filename,filename_expression);
            load(fullfile(DIR,daily_dirs(dirnum).name,'chop_data','idx',[filename '.mat']),'chunk_idx');
            new_file_datetime = curr_file_datetime + seconds(chunk_idx(1));
            new_filename = return_newname(filename,new_file_datetime,filename_expression);
            if ~strcmp(filename,new_filename)
                movefile(fullfile(DIR,daily_dirs(dirnum).name,'chop_data','wav',[filename '.wav']),...
                    fullfile(DIR,daily_dirs(dirnum).name,'chop_data','wav',[new_filename '.wav']));
                movefile(fullfile(DIR,daily_dirs(dirnum).name,'chop_data','gif',[filename '.gif']),...
                    fullfile(DIR,daily_dirs(dirnum).name,'chop_data','gif',[new_filename '.gif']));
                movefile(fullfile(DIR,daily_dirs(dirnum).name,'chop_data','idx',[filename '.mat']),...
                    fullfile(DIR,daily_dirs(dirnum).name,'chop_data','idx',[new_filename '.mat']));
            end
        end

    catch em
        '8'
    end

end

    function dateobj = return_dateobj(input_str,filename_expression)
        year_idx = regexp(filename_expression,'yyyy');
        if numel(year_idx) ~= 1
            disp('error in year formatting');
            dateobj = [];
            return;
        else 
            year_idx = year_idx:(year_idx+3);
        end
    
        month_idx = regexp(filename_expression,'MM');
        if numel(month_idx) ~= 1
            disp('error in month formatting');
            dateobj = [];
            return;
        else 
            month_idx = month_idx:(month_idx+1);
        end
    
        day_idx = regexp(filename_expression,'dd');
        if numel(day_idx) ~= 1
            disp('error in day formatting');
            dateobj = [];
            return;
        else 
            day_idx = day_idx:(day_idx+1);
        end
    
        hour_idx = regexp(filename_expression,'HH');
        if numel(hour_idx) ~= 1
            disp('error in hour formatting');
            dateobj = [];
            return;
        else 
            hour_idx = hour_idx:(hour_idx+1);
        end
    
        minute_idx = regexp(filename_expression,'mm');
        if numel(minute_idx) ~= 1
            disp('error in minute formatting');
            dateobj = [];
            return;
        else 
            minute_idx = minute_idx:(minute_idx+1);
        end
    
        second_idx = regexp(filename_expression,'ss');
        if numel(second_idx) ~= 1
            disp('error in second formatting');
            dateobj = [];
            return;
        else 
            second_idx = second_idx:(second_idx+1);
        end
        date_string = [input_str([year_idx month_idx day_idx hour_idx minute_idx second_idx])];
        dateobj = datetime(date_string,'InputFormat','yyyyMMddHHmmss');
    end

    function newname = return_newname(old_filename,input_dateobj,filename_expression)
        year_idx = regexp(filename_expression,'yyyy');
        if numel(year_idx) ~= 1
            disp('error in year formatting');
            dateobj = [];
            return;
        else 
            year_idx = year_idx:(year_idx+3);
        end
    
        month_idx = regexp(filename_expression,'MM');
        if numel(month_idx) ~= 1
            disp('error in month formatting');
            dateobj = [];
            return;
        else 
            month_idx = month_idx:(month_idx+1);
        end
    
        day_idx = regexp(filename_expression,'dd');
        if numel(day_idx) ~= 1
            disp('error in day formatting');
            dateobj = [];
            return;
        else 
            day_idx = day_idx:(day_idx+1);
        end
    
        hour_idx = regexp(filename_expression,'HH');
        if numel(hour_idx) ~= 1
            disp('error in hour formatting');
            dateobj = [];
            return;
        else 
            hour_idx = hour_idx:(hour_idx+1);
        end
    
        minute_idx = regexp(filename_expression,'mm');
        if numel(minute_idx) ~= 1
            disp('error in minute formatting');
            dateobj = [];
            return;
        else 
            minute_idx = minute_idx:(minute_idx+1);
        end
    
        second_idx = regexp(filename_expression,'ss');
        if numel(second_idx) ~= 1
            disp('error in second formatting');
            dateobj = [];
            return;
        else 
            second_idx = second_idx:(second_idx+1);
        end
        
        year_str = sprintf('%04d',input_dateobj.Year);
        month_str = sprintf('%02d',input_dateobj.Month);
        day_str = sprintf('%02d',input_dateobj.Day);
        hour_str = sprintf('%02d',input_dateobj.Hour);
        minute_str = sprintf('%02d',input_dateobj.Minute);
        second_str = sprintf('%02d',floor(input_dateobj.Second));
        
        newname = old_filename;
        newname(year_idx) = year_str;
        newname(month_idx) = month_str;
        newname(day_idx) = day_str;
        newname(hour_idx) = hour_str;
        newname(minute_idx) = minute_str;
        newname(second_idx) = second_str;

    end
end
