function new_phrases = bsb_deal_with_time_gaps(phrases,max_phrase_gap)
% This function takes the struct 'phrases' and adds a -1000,1000 to the
% beginning and end as well as to mark any gap larger than max_phrase_gap
    if numel(phrases.phraseType) == 0
        new_phrases = phrases;
        return;
    end
    new_phrases.phraseType = [-1000; phrases.phraseType(1)];
    new_phrases.phraseFileStartTimes = [phrases.phraseFileStartTimes(1) - 1, ...
        phrases.phraseFileStartTimes(1)];
    new_phrases.phraseFileEndTimes = [phrases.phraseFileStartTimes(1) - 0.001, ...
        phrases.phraseFileEndTimes(1)];
    
    for temp_cnt = 2:numel(phrases.phraseType)
        curr_gap = (phrases.phraseFileStartTimes(temp_cnt) - phrases.phraseFileEndTimes(temp_cnt-1));
        if (curr_gap > max_phrase_gap) 
            new_phrases.phraseType = [new_phrases.phraseType; 1000; -1000];
            new_phrases.phraseFileStartTimes = [new_phrases.phraseFileStartTimes phrases.phraseFileEndTimes(temp_cnt - 1)+0.001 ...
                phrases.phraseFileStartTimes(temp_cnt) - min(0.005,curr_gap/10)];
            new_phrases.phraseFileEndTimes = [new_phrases.phraseFileEndTimes phrases.phraseFileEndTimes(temp_cnt - 1)+min(0.005,curr_gap/10) ...
                phrases.phraseFileStartTimes(temp_cnt) - 0.001];
        end
        new_phrases.phraseType = [new_phrases.phraseType; phrases.phraseType(temp_cnt)];
        new_phrases.phraseFileStartTimes = [new_phrases.phraseFileStartTimes phrases.phraseFileStartTimes(temp_cnt)];
        new_phrases.phraseFileEndTimes = [new_phrases.phraseFileEndTimes phrases.phraseFileEndTimes(temp_cnt)];
               
    end
    new_phrases.phraseType = [new_phrases.phraseType; 1000];
    new_phrases.phraseFileStartTimes = [new_phrases.phraseFileStartTimes phrases.phraseFileEndTimes(end) + 0.001];
    new_phrases.phraseFileEndTimes = [new_phrases.phraseFileEndTimes phrases.phraseFileEndTimes(end) + 1];
end 