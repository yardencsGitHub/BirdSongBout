function bsb_add_annotation_to_mat(DIR,annotation_file,template_file)
% This function adds the variable 'labels', containing the labeled time
% bins, to each spectrogram .mat file
cd(DIR);
if ~exist('annotated','dir')
    mkdir('annotated');
end
load(template_file);
syllables = [templates.wavs.segType];
load(annotation_file);
num_files = numel(keys);
for fnum = 1:num_files
    if ~isempty(elements{fnum}.segType)
        matfilename = [keys{fnum}(1:end-3) 'mat'];
        cd mat;
        load(matfilename);
        labels = zeros(size(t));
        for segnum = 1:numel(elements{fnum}.segFileStartTimes)
            if (elements{fnum}.segType(segnum) >= 0)
                labels((t >= elements{fnum}.segFileStartTimes(segnum)) & ...
                    (t <= elements{fnum}.segFileEndTimes(segnum))) = ...
                    find(syllables == elements{fnum}.segType(segnum));
            end
        end
        cd ..
        cd annotated
        save(matfilename,'labels','f','s','t'); %'-append');
        cd ..
    end
end
