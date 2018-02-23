function move_and_convert_boom_to_tweet(birdname,source_dir,target_dir)
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
            tokens = regexp(fname,'_','split');
            tokens = regexp(tokens{2},'-','split');
            tokens = regexp(tokens{1},'\.','split');

            target_fname = [birdname '_' sprintf('%04d',file_cnt) '_' char(join(tokens(2:6),'_')) '.wav'];
            copyfile(fullfile(source_dir,dirs(dirnum).name,'chop_data','wav',fname),...
                fullfile(target_dir,target_fname));
            file_cnt = file_cnt + 1;
            
        end
    catch em
        display(['problems with folder: '  dirs(dirnum).name]);
    end
end