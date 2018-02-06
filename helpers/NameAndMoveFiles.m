%% Name and Move song files 
TargetDir = '/Users/yardenc/Documents/Experiments/CanaryBoutAnnotation';

BaseDir = '/Volumes/stone_age/canary_syntax_data/CLEAN/Liz/';

cd(BaseDir);
d=dir; d=d([d.isdir]);
BirdsDirs = {d(3:end).name};
n_birds = numel(BirdsDirs);
% skipped = [18    71    72    73   170   208   209   298   314   315   316];
% skipped = [18    71    72    73   170   209   210   300   316   317   318];
   
%%
for birdnum = 1:n_birds
    file_cnt = 1;
    extra_files_cnt = 330;
    cd(TargetDir);
    birdname = BirdsDirs{birdnum};
    if ~exist(birdname,'dir')
        mkdir(birdname);
    end
    cd(BaseDir);
    cd(BirdsDirs{birdnum});
    d=dir; d={d.name};
    d=d{cellfun(@(z)ismember('&',z),d)};
    
    
    BOUTstat = fullfile(BaseDir,BirdsDirs{birdnum},d,'stats',[d '.mat']);
    load(BOUTstat);
    tokens = regexp(BOUT{1}.filenames{1},'/','split');
    dirname = 'start'; %tokens{1};
    syl_str = {};
    phrase_boundaries = {};
    sono_t = [];
    for bout_cnt = 1:numel(BOUT)
        
        tokens = regexp(BOUT{bout_cnt}.filenames{1},'/','split');
        if ~strcmp(tokens{1},dirname)
            dirname = tokens{1};
            source_file = fullfile(BaseDir,BirdsDirs{birdnum},d,dirname,'canary_singing.wav');
            [y,fs] = audioread(source_file);           
            
        end
        
        sonogram_width=BOUT{bout_cnt}.sonogram_width;
        son_to_vec=(length(y)-512)/sonogram_width;
%         if ismember(bout_cnt,skipped)
%             son_to_vec = 512;
%         end
        
        extract=round(BOUT{bout_cnt}.coordinates(:,1)*son_to_vec); ex1 = extract(1);
        extract=round(BOUT{bout_cnt}.coordinates(:,end)*son_to_vec); ex2 = extract(2);
        boundaries = round(BOUT{bout_cnt}.coordinates*son_to_vec) - ex1 +1;
        %phrase_boundaries = {phrase_boundaries{:} boundaries};
        try
            sound_segment=y(ex1:ex2);
            %if ismember(bout_cnt,skipped)
                target_file = fullfile(TargetDir,birdname,[birdname '_' sprintf('%04d',file_cnt) '_' datestr(BOUT{bout_cnt}.datenum,'yyyy_mm_dd_HH_MM') '.wav']);
                fnames = [fnames; target_file];
                audiowrite(target_file,sound_segment,fs);
                
                syl_str = {syl_str{:} BOUT{bout_cnt}.string};
                phrase_boundaries = {phrase_boundaries{:} boundaries};
            %end
            file_cnt = file_cnt + 1;
            
                
            
            sono_t =[sono_t; son_to_vec file_cnt bout_cnt];
        catch em
            display(bout_cnt);
        end
    end
    %save(fullfile(TargetDir,birdname,'tags_extra'),'syl_str','phrase_boundaries');
    cd(BaseDir);
end