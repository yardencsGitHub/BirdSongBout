
%%
BASEDIR = '/Volumes/quetzalcoatl/Documents/Bird Screening/lrb853_15/';
cd(BASEDIR);
DIRS = dir;
DIRS = DIRS(4:end);
dates=[];
numfiles=[];
durations_mn = [];
durations_sd = [];
for dirnum = 1:numel(DIRS)
    display([dirnum numel(DIRS)]);
    dates = [dates; datenum(DIRS(dirnum).name)];
    cd([BASEDIR DIRS(dirnum).name '/chop_data/wav']);
    file_list = dir('*.wav');
    numfiles = [numfiles; numel(file_list)];
    durations = [];
    for filenum = 1:numel(file_list)
        [a,f] = audioread(file_list(filenum).name);
        durations = [durations; numel(a)/f];
    end
    durations_mn = [durations_mn; mean(durations)];
    durations_sd = [durations_sd; std(durations)];
end

%%
days = dates-min(dates);
figure;
subplot(3,1,1);
plot(days(31:end)-days(31),numfiles(31:end));
ylabel('# files');
set(gca,'XTick',[]);
set(gca,'FontSize',24)
subplot(3,1,[2 3]);
errorbar(days(31:end)-days(31),durations_mn(31:end),durations_sd(31:end));
xlabel('Day #')
ylabel('File durations (sec)')
set(gca,'FontSize',24)