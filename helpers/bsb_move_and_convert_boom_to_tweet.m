function bsb_move_and_convert_boom_to_tweet(birdname,source_dir,target_dir,name_expression,num_counter_digits)
%%
% This script assumes that the folder 'source_dir' has a set of subfolders
% with the names that match recording dates. These subfolders must be in
% the expected structure of the extraction from the BoomRecorder file
% system:
%    - Each subfolder has the name that match the date yyyy-mm-dd
%    - Each subfolder has the subfolder 'chop_data' that contains the
%    subfolder 'wav'
%    - The subfolder 'wav' has only audio files with names:
% channel_ChN.yyyy.mm.dd.hr.mn-fxx.y_chunk_n where ChN,xx,y are numbers
% The script copies the files to the folder 'target_dir' and change the
% names to meet the TweetVision format:
% birdname_serial#_yyyy_mm_dd_hr_mn
%%
dirs = dir(source_dir);
file_cnt = 1;
for dirnum = 1:numel(dirs)
    try
        datenum(dirs(dirnum).name);
        
        FILES = dir(fullfile(source_dir,dirs(dirnum).name,'chop_data','wav','*.wav'));
        for fnum = 1:numel(FILES)
            fname = FILES(fnum).name;
            dateobj = return_dateobj(fname,name_expression);
%             if isempty(datetime_tokenizer_func)
%                 tokens = regexp(fname,'_','split');
%                 tokens = regexp(tokens{2},'-','split');
%                 tokens = regexp(tokens{1},'\.','split');
%                 tokens = tokens(2:6);
%             else
%                 tokens = datetime_tokenizer_func(fname);
%             end
            target_fname = [birdname '_' sprintf(['%0' num2str(num_counter_digits) 'd'],file_cnt) '_' datestr(dateobj,'yyyy_mm_dd_HH_MM_ss') '.wav'];
            copyfile(fullfile(source_dir,dirs(dirnum).name,'chop_data','wav',fname),...
                fullfile(target_dir,target_fname));
            file_cnt = file_cnt + 1;
            
        end
    catch em
        display(['problems with folder: '  dirs(dirnum).name]);
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
end