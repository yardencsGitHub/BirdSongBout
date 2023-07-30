function bsb_manually_prune_song_nosong_files(DIR,firstfilenum)
% This script gets a directory DIR that has only subdirectories with date names as produced by 'zftftb_song_chop.m'
% Each date folder in the format yyyy-mm-dd must have the subfolder
% 'chop_data' that has the subfolders 'wav' and 'gif'
% These folders have the audio and spectrogram files with the same name.

% The script allows going over the folders, and manually deciding which
% files to delete.

% The script allows to stop and continue from a file number 'firstfilenum'

d = dir(DIR);
d = d([d.isdir] == 1);
d = d(cellfun(@numel,{d.name}) == 10);
% check folders are dates
try 
    cellfun(@datenum,{d.name});
catch em
    disp('Some folders are not named by dates');
    return;
end
uiwait(msgbox(sprintf('Use keyboard to determine for each file: \n d - delete. \n b - back. \n Any other key for keeping. \n Use q - quit to stop.')));
currfile = 1; k = '@';
tot_dirnum = numel(d); dirnum = 1;
while dirnum <= tot_dirnum 
    basedir = fullfile(DIR,d(dirnum).name,'chop_data');
    if ~exist(fullfile(basedir,'wav')) && ~exist(fullfile(basedir,'gif'))
        disp(['Some subfolders of ' DIR ' or ' basedir ' are missing']);
        continue;
    end
    disp(['Working on directory: ' d(dirnum).name]);
    files = dir(fullfile(basedir,'gif'));
    files = files([files.isdir] ~= 1);
    tot_filenum = numel(files); 
    if k == 'b'
        filenum = tot_filenum;
    else
        filenum = 1;
    end
    while filenum <= tot_filenum
        [fpath,fname,ext] = fileparts(files(filenum).name);
        if ~strcmp(ext,'.gif') &&  ~strcmp(ext,'.jpg')
            disp(['File type of ' files(filenum).name ' is wrong.']);
            continue;
        end
        if (currfile < firstfilenum)
            currfile = currfile + 1;
            filenum = filenum + 1;
            continue;
        end
        fh = figure; ax = axes(fh);
        [I,map] = imread(fullfile(basedir,'gif',files(filenum).name));
        imshow(fullfile(basedir,'gif',files(filenum).name)); %colormap(gca,map);
        title(['File number: ' num2str(currfile)],'FontSize',14); drawnow;
        pause(0.1);
        set(fh,'CurrentCharacter','@'); 
        while 1
            w = waitforbuttonpress;
            k=get(fh,'CurrentCharacter');
            if k~='@' % has it changed from the dummy character?
                break;
            end
        end
        if k == 'd'
            answer = questdlg('Delete file?');
            if strcmp(answer,'Yes')
                delete(fullfile(basedir,'gif',files(filenum).name));
                delete(fullfile(basedir,'wav',[files(filenum).name(1:end-3) 'wav']));
                delete(fullfile(basedir,'idx',[files(filenum).name(1:end-3) 'mat']));
                files(filenum) = [];
                tot_filenum = tot_filenum - 1;
                hgclose(fh);
                continue;
            end
        end
        if k == 'q'
            disp(['Stopping at file number ' num2str(currfile)]);
            hgclose(fh);
            return;
        end
        if k == 'b'
            if filenum > 1
                filenum = filenum - 1;
                currfile = currfile - 1;
                hgclose(fh);
                continue;
            elseif dirnum > 1
                dirnum = dirnum - 2;
                currfile = currfile - 1;
                filenum = inf;
                hgclose(fh);
                continue;
            end
            hgclose(fh);
            continue;
        end
        hgclose(fh);
        currfile = currfile + 1;
        filenum = filenum + 1;
    end
    dirnum = dirnum + 1;
end
            
        
    
    