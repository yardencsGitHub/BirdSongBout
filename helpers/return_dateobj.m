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