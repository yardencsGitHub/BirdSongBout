function bsb_move_and_convert_wavfiles_to_tweet(birdname,source_dir,target_dir,name_expression,num_counter_digits,varargin)
%%
% This script assumes that the folder 'source_dir' has wav files
% with the names that match recording dates.
% The script copies the files to the folder 'target_dir' and change the
% names to meet the TweetVision format:
% birdname_serial#_yyyy_mm_dd_hr_mn
%%
shift_digits = 0;
minute_place = 1;
year_prefix = '20';
nparams=length(varargin);
for i=1:2:nparams
	switch lower(varargin{i})
        case 'shift_digits'
			shift_digits=varargin{i+1};
        case 'minute_place'
			minute_place=varargin{i+1};
        case 'year_prefix'
            year_prefix=varargin{i+1};
    end
end
FILES = dir(fullfile(source_dir,'*.wav'));
file_cnt = 1;

try
    for fnum = 1:numel(FILES)
        fname = FILES(fnum).name;
 
        [~, dateobj] = bsb_extrat_date_string_trom_filename(fname,name_expression,'minute_place',...
            minute_place,'year_prefix',year_prefix);
%             if isempty(datetime_tokenizer_func)
%                 tokens = regexp(fname,'_','split');
%                 tokens = regexp(tokens{2},'-','split');
%                 tokens = regexp(tokens{1},'\.','split');
%                 tokens = tokens(2:6);
%             else
%                 tokens = datetime_tokenizer_func(fname);
%             end
        target_fname = [birdname '_' sprintf(['%0' num2str(num_counter_digits) 'd'],file_cnt) '_' datestr(dateobj,'yyyy_mm_dd_HH_MM_ss') '.wav'];
        copyfile(fullfile(source_dir,fname),...
            fullfile(target_dir,target_fname));
        file_cnt = file_cnt + 1;
        
    end
catch em
    display(['problems with folder: '  dirs(dirnum).name]);
end



end

