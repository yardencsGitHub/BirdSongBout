function [datename, dateobj] = bsb_extrat_date_string_trom_filename(filename,filename_expression)
% This function allows extracting the date and time encoded in file names.

% Inputs:
%   filename (string): the file name that contains the date and time
%   filename_expression (string): a mask string containing indicators for
%   the positions of the required information in 'filename'. These
%   indicators must be yyyy,MM,dd,HH,mm,ss for the
%   year,month,day,hour,minute, and second.

% example use: 
%    bsb_extrat_date_string_trom_filename('llb11_00224_2018_05_04_12_51_23.wav',...
%                                         'xxxxxxxxxxxxyyyyxMMxddxHHxmm_ssxxxx')

% Outputs:
%   datename (string): The datetime formatted as a '-' separated string 
%                      (e.g. 2018-05-04-12-51-23 for the above example)
%   dateobj (datetime object): Matlab's datetime object for above details

        year_idx = regexp(filename_expression,'yyyy');
        if numel(year_idx) ~= 1
            disp('error in year formatting');
            datename = [];
            return;
        else 
            year_idx = year_idx:(year_idx+3);
        end
    
        month_idx = regexp(filename_expression,'MM');
        if numel(month_idx) ~= 1
            disp('error in month formatting');
            datename = [];
            return;
        else 
            month_idx = month_idx:(month_idx+1);
        end
    
        day_idx = regexp(filename_expression,'dd');
        if numel(day_idx) ~= 1
            disp('error in day formatting');
            datename = [];
            return;
        else 
            day_idx = day_idx:(day_idx+1);
        end
    
        hour_idx = regexp(filename_expression,'HH');
        if numel(hour_idx) ~= 1
            disp('error in hour formatting');
            datename = [];
            return;
        else 
            hour_idx = hour_idx:(hour_idx+1);
        end
    
        minute_idx = regexp(filename_expression,'mm');
        if numel(minute_idx) ~= 1
            disp('error in minute formatting');
            datename = [];
            return;
        else 
            minute_idx = minute_idx:(minute_idx+1);
        end
    
        second_idx = regexp(filename_expression,'ss');
        if numel(second_idx) ~= 1
            disp('error in second formatting');
            datename = [];
            return;
        else 
            second_idx = second_idx:(second_idx+1);
        end

        date_string = [filename([year_idx month_idx day_idx hour_idx minute_idx second_idx])];
        dateobj = datetime(date_string,'InputFormat','yyyyMMddHHmmss');

        datename = datestr(dateobj,'yyyy-mm-dd-HH-MM-ss');
    end