function [on_times,off_times] = GUI_syllable_envelope(signal,t,thr,min_gap,min_syl)
signal = reshape(signal,1,numel(signal));
dt = mean(diff(t));
% parameters

min_gap_bins = round(min_gap/dt);
%
x = [0 1*(signal > thr) 0];
loc_on = setdiff(find(diff(x) == 1),1);
loc_off = setdiff(find(diff(x) == -1),numel(signal)+1);
on_times = t(loc_on(loc_on < loc_off(1)));
off_times = [];
for cnt = 1:numel(loc_off)
    next_on = loc_on(min(find(loc_on > loc_off(cnt))));
    if ~isempty(next_on)
        if next_on - loc_off(cnt) > min_gap_bins
            off_times = [off_times t(loc_off(cnt))];
            on_times = [on_times t(next_on)];
        end
    else
       off_times = [off_times t(loc_off(cnt))];
    end
end

tmp_ons = on_times(on_times < off_times(end));
tmp_offs = off_times(off_times > on_times(1));
durations = tmp_offs - tmp_ons;
tmp_ons(durations > min_syl) = [];
tmp_offs(durations > min_syl) = [];
on_times = setdiff(on_times,tmp_ons);
off_times = setdiff(off_times,tmp_offs);

    
            

