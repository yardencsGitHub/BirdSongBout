function time = GUI_getFileTime(filename)
if strcmp(filename(end-2:end),'mat')
    filename = filename(1:end-4);
end
strparts = regexp(filename,'_', 'split');

y = str2double(strparts{3});
m = str2double(strparts{4});
d = str2double(strparts{5});
th = str2double(strparts{6});
tm = str2double(strparts{7});
try
    ts = strparts{8};
    ts =  str2double(ts(1:end-4));
catch em
    ts = 0;
end

time = datenum(y,m,d,th,tm,ts);
