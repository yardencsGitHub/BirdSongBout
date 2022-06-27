classdef SAT_similarity < handle % there will be only one copy of each SAT_sound
%% Sound Analysis Tools similarity measurements
% Usage:
% sound1=SAT_sound('sound file name 1'); 
% sound2=SAT_sound('sound file name 2');
% and then either
% sim=SAT_similarity(sound1, sound2); % this option will present a GUI
% or
% sim=SAT_similarity(sound1, sound2, 0); % no GUI
% adjust parameters if desired, e.g
% global SAT_params; % make SAT parameters available to manipulate from workspace
% SAT_params.similarity_threshold=2.5; % Set Median Absolute Deviations (MAD)threshold for similarity measurements 
% sim.calculate_similarity;
% sim.score; % show the score
%ans = 
%    similarity: 79.4118
%      accuracy: 68.6902
%%

    properties (SetAccess = public) 
        score % a vector with similarity score values
        similarity_sections % a vector with similarity sections
        number_of_sections % number of similarity sections
        local_similarity % an array of local (pixel by pixel) similarity matrices for each feature
        global_similarity % an array of wider (usually 70ms long windows) similarity matrices for each feature  
        sound1
        sound2 
    end;
    
    properties (SetAccess = private)
        status=false % false = similarity not yet computed
        
    end
     
    methods

            function obj=SAT_similarity(x,y, param)% constructor, x and y are two SATp_sound objects
                obj.sound1=x;
                obj.sound2=y;
                if(~exist('param', 'var')) % plot the sound and features by default
                   SAT_similarity_plot(obj);
                elseif (param==1) % plot sound and features if second parameter is 1.
                   SAT_similarity_plot(obj);
                end;
            end;
            
            function calculate_similarity(obj)
                
                global SAT_params;
                frames_x=length(obj.sound1.signal);
                frames_y=length(obj.sound2.signal);
                % Define local and global matrixes here...
                Local_pitch=zeros(frames_x,frames_y);
                Local_goodness=zeros(frames_x,frames_y);
                Local_entropy=zeros(frames_x,frames_y);
                Local_FM=zeros(frames_x,frames_y);
                Local_AM=zeros(frames_x,frames_y);
                Local=zeros(frames_x,frames_y);
                similarity=zeros(frames_x,frames_y);
                Global_pitch=zeros(frames_x,frames_y);
                Global_goodness=zeros(frames_x,frames_y);
                Global_FM=zeros(frames_x,frames_y);
                Global_AM=zeros(frames_x,frames_y);
                Global_entropy=zeros(frames_x,frames_y);
                Glob=zeros(frames_x,frames_y);
                threshold_matrix=zeros(frames_x,frames_y);
                calc_the_distances(); % calculate a matrix of Euclidean distances across features upon overalping intervals
                Compute_Similarity_Sections(); % this function find boundaries and local scores of similarity sections
                Trim_Similarity_Sections(); % this funtion trim similarity section using hirarchial approach
                recalc_Similarity(); % now we calculate the final similarity of each section
                calc_Linearity(); % finaly, examine how similairty sections are organized sequentially
                CalculateResults();


                function calc_the_distances() 
                    % scale the features 
                    Local_pitch_Scaled1=(obj.sound1.features.pitch-SAT_params.pitch.Median)/SAT_params.pitch.MAD;
                    Local_pitch_Scaled2=(obj.sound2.features.pitch-SAT_params.pitch.Median)/SAT_params.pitch.MAD;
                    Local_goodness_Scaled1=(obj.sound1.features.goodness-SAT_params.goodness.Median)/SAT_params.goodness.MAD;
                    Local_goodness_Scaled2=(obj.sound2.features.goodness-SAT_params.goodness.Median)/SAT_params.goodness.MAD;
                    Local_FM_Scaled1=(obj.sound1.features.FM-SAT_params.FM.Median)/SAT_params.FM.MAD;
                    Local_FM_Scaled2=(obj.sound2.features.FM-SAT_params.FM.Median)/SAT_params.FM.MAD;
                    Local_AM_Scaled1=(obj.sound1.features.AM-SAT_params.AM.Median)/SAT_params.AM.MAD;
                    Local_AM_Scaled2=(obj.sound2.features.AM-SAT_params.AM.Median)/SAT_params.AM.MAD;
                    Local_entropy_Scaled1=(obj.sound1.features.entropy-SAT_params.entropy.Median)/SAT_params.entropy.MAD;
                    Local_entropy_Scaled2=(obj.sound2.features.entropy-SAT_params.entropy.Median)/SAT_params.entropy.MAD;
                    
                    % Calculate local distances across all features, not scaled
                    Local_pitch=pdist2(Local_pitch_Scaled1',Local_pitch_Scaled2');
                    Local_goodness=pdist2(Local_goodness_Scaled1',Local_goodness_Scaled2');
                    Local_entropy=pdist2(Local_entropy_Scaled1',Local_entropy_Scaled2');
                    Local_FM=pdist2(Local_FM_Scaled1',Local_FM_Scaled2');
                    Local_AM=pdist2(Local_AM_Scaled1',Local_AM_Scaled2');

                    % add them up to create an overall local distance matrix, Local:
                    Local=(Local_pitch + Local_goodness + Local_FM + Local_AM + Local_entropy)/5;
                    % Compute p values into Sim[][], which is the pooled features euclidean matrix in p-value units
                    similarity=2*normcdf(-abs(Local),0,1); % this is the p value that the MADs are different 1=similar
                    
                    % Calculate global features: use the local distance
                    Global_pitch=zeros(frames_x,frames_y);  
                    Global_goodness=zeros(frames_x,frames_y);  
                    Global_entropy=zeros(frames_x,frames_y);  
                    Global_FM=zeros(frames_x,frames_y);  
                    Global_AM=zeros(frames_x,frames_y);  
                    Glob=zeros(frames_x,frames_y); 
                    interval=SAT_params.similarity_interval;
                    interval05=1+floor(interval/2);
                    %blur method:
                    if SAT_params.similarity_method==0
                         h = fspecial('gaussian',interval,4);
                         Global_pitch = conv2(Local_pitch,h,'same');
                         Global_goodness= conv2(Local_goodness,h,'same');
                         Global_entropy= conv2(Local_entropy,h,'same');
                         Global_FM= conv2(Local_FM,h,'same');
                         Global_AM= conv2(Local_AM,h,'same');
                         Glob=(Global_pitch+Global_goodness+Global_entropy+Global_FM+Global_AM)/5;  
                    % time course method:
                    else
                        for i=interval05:frames_x-interval05
                             for j=interval05:frames_y-interval05               
                                for k=-interval05+1:interval05-1 % for 70ms
                                      ind1=i+k; ind2=j+k; 
                                      Global_pitch(i,j)=Global_pitch(i,j)+Local_pitch(ind1,ind2);
                                      Global_goodness(i,j)=Global_goodness(i,j)+Local_goodness(ind1,ind2);
                                      Global_entropy(i,j)=Global_entropy(i,j)+Local_entropy(ind1,ind2);
                                      Global_FM(i,j)=Global_FM(i,j)+Local_FM(ind1,ind2);
                                      Global_AM(i,j)=Global_AM(i,j)+Local_AM(ind1,ind2);
                                end; 
                                     Glob(i,j)=Global_pitch(i,j)+Global_goodness(i,j)+Global_entropy(i,j)+Global_FM(i,j)+Global_AM(i,j);
                                     Glob(i,j)=Glob(i,j)/(interval*5);
                             end;
                        end;
                    end;
                    mx=max(max(Glob));
                    Glob(1:interval05,:)=mx;
                    Glob(:,1:interval05)=mx;
                    Glob(end-interval05:end,:)=mx;
                    Glob(:,end-interval05:end)=mx;
                    mx=max(max(Global_pitch));
                    Global_pitch(1:interval05,:)=mx;
                    Global_pitch(:,1:interval05)=mx;
                    Global_pitch(end-interval05:end,:)=mx;
                    Global_pitch(:,end-interval05:end)=mx;
                    mx=max(max(Global_goodness));
                    Global_goodness(1:interval05,:)=mx;
                    Global_goodness(:,1:interval05)=mx;
                    Global_goodness(end-interval05:end,:)=mx;
                    Global_goodness(:,end-interval05:end)=mx;
                    mx=max(max(Global_entropy));
                    Global_entropy(1:interval05,:)=mx;
                    Global_entropy(:,1:interval05)=mx;
                    Global_entropy(end-interval05:end,:)=mx;
                    Global_entropy(:,end-interval05:end)=mx;
                    mx=max(max(Global_FM));
                    Global_FM(1:interval05,:)=mx;
                    Global_FM(:,1:interval05)=mx;
                    Global_FM(end-interval05:end,:)=mx;
                    Global_FM(:,end-interval05:end)=mx;
                    mx=max(max(Global_AM));
                    Global_AM(1:interval05,:)=mx;
                    Global_AM(:,1:interval05)=mx;
                    Global_AM(end-interval05:end,:)=mx;
                    Global_AM(:,end-interval05:end)=mx;
                    %assignin ('base','Glob',Glob);
                end
                
   
            
                function Compute_Similarity_Sections()
                   
                   % set a threshold similarity matrix according to MAD  
                    threshold_matrix=Glob;
                    threshold_matrix(Glob<SAT_params.similarity_threshold)=1;
                    threshold_matrix(Glob>=SAT_params.similarity_threshold)=0;
                    % trim edges to avoid artifacts:
                    edge=5+floor(SAT_params.similarity_interval/2);
                    threshold_matrix(1:edge,:)=0;
                    threshold_matrix(:,1:edge)=0;
                    threshold_matrix(end-edge:end,:)=0;
                    threshold_matrix(:,end-edge:end)=0;
                    %trim no signal sections unless the mode is 'calc through silences':
                    if(~SAT_params.calc_silence) % do not incude silences in similarity sections
                        threshold_matrix((obj.sound1.signal==0),:)=0;
                        threshold_matrix(:,(obj.sound2.signal==0))=0;
                    end;
                    % now we compute the blobs in the similarity matrix (similarity sections):
                    [labeledImage, numberOfBlobs] = bwlabel(threshold_matrix);
                    similarity_section = regionprops(labeledImage, 'area', 'Centroid','BoundingBox'); % Get blob properties.  
                    allAreas = [similarity_section.Area]; % Get areas
                    
                    % set obj.similarity_sections fields: 1:Xs, 2:Ys, 3:Xe, 4:Ye, 5:similarity
                    obj.similarity_sections=zeros(200,5); % this is the upper bound of number of sections we allow
                    section_index=1;
                    for k = 1 : numberOfBlobs           % Loop through all blobs. 
                         if allAreas(k)>100 % 
                              % we now fix the coordinates (x->y, and Xs, Ys, Xe, Ye
                             obj.similarity_sections(section_index,1)=floor(similarity_section(k).BoundingBox(2));
                             obj.similarity_sections(section_index,2)=floor(similarity_section(k).BoundingBox(1));
                             obj.similarity_sections(section_index,3)=floor(similarity_section(k).BoundingBox(2)+similarity_section(k).BoundingBox(4));
                             obj.similarity_sections(section_index,4)=floor(similarity_section(k).BoundingBox(1)+similarity_section(k).BoundingBox(3));
                             
                             % simple names for boundaries:
                             xs=obj.similarity_sections(section_index,1);
                             xe=obj.similarity_sections(section_index,3);
                             ys=obj.similarity_sections(section_index,2);
                             ye=obj.similarity_sections(section_index,4);

                             %first adjust these sections boundaries according to the time warping tolerance, so that your sections are more squarish

                             % then calculate the slope of each section
                             slope=(xe-xs)/(ye-ys);
                             band=2*SAT_params.accuracy_jitter; 
                             similarity_ymax=obj.sound2.num_slices;
                             accur=0;
                             j=1;
                             for i=xs:xe
                                 y_target=floor(ys+(j*slope));
                                 y_min=floor(max(1,y_target-band));
                                 y_max=floor(min(similarity_ymax,y_target+band));
                                 tmp=max(similarity(i,y_min:y_max));
                                 if(tmp>0)
                                     accur=accur+tmp;%max(similarity(i,y_min:y_max));
                                 end;
                                 j=j+1;
                             end
                             if(accur)
                                 obj.similarity_sections(section_index,5)=accur;
                             else 
                                 obj.similarity_sections(section_index,5)=0;
                             end;
                             
                              
                             
                             obj.similarity_sections(section_index,5)=sum(diag(similarity(...
                                obj.similarity_sections(section_index,1):obj.similarity_sections(section_index,3),...
                                obj.similarity_sections(section_index,2):obj.similarity_sections(section_index,4))));

                             section_index=section_index+1;
                         else similarity_section(k).Area=0;
                         end;
                    end; 
                    obj.number_of_sections=section_index;
                    obj.similarity_sections=obj.similarity_sections(1:obj.number_of_sections,:);
                    
                end
              
                
                function Trim_Similarity_Sections()
                    %figure; plot(obj.similarity_sections(:,5),'.r');
                    for j=1:obj.number_of_sections
                        obj.similarity_sections=sortrows(obj.similarity_sections,-5); % sort by area (5) largest to smallest
                        obj.similarity_sections(1,5)= obj.similarity_sections(1,5).*-1; % this will ensure we will not consider it again
                        for i=2:obj.number_of_sections
                            if obj.similarity_sections(i,5)>0     
                                XsSup = obj.similarity_sections(1,1);
                                XeSup = obj.similarity_sections(1,3);
                                YsSup = obj.similarity_sections(1,2);
                                YeSup = obj.similarity_sections(1,4);
                                XsInf_ref= obj.similarity_sections(i,1); 
                                XsInf = XsInf_ref;
                                XeInf_ref= obj.similarity_sections(i,3); 
                                XeInf = XeInf_ref;
                                YsInf_ref= obj.similarity_sections(i,2); 
                                YsInf = YsInf_ref;
                                YeInf_ref= obj.similarity_sections(i,4); 
                                YeInf = YeInf_ref;

                                if XeInf > XsSup && XsInf < XeSup % there is an overlap on the X
                                    if (XsInf < XsSup && XeInf > XeSup) || (XsInf > XsSup && XeInf < XeSup)  % kill this section
                                        obj.similarity_sections(i,5) = 0;
                                    elseif XsInf > XsSup 
                                        obj.similarity_sections(i,1) = XeSup;
                                        obj.similarity_sections(i,2) = YsInf +((YeInf - YsInf) .* (XeSup - XsInf) ./ (XeInf - XsInf)); 
                                        % correct for Y
                                        old_duration = XeInf - XsInf;
                                        XsInf = XeSup;
                                        YsInf = obj.similarity_sections(i,2);
                                        new_duration = XeInf - XsInf;
                                        obj.similarity_sections(i,5)  = obj.similarity_sections(i,5) .* (new_duration / old_duration);
                                    else 
                                        obj.similarity_sections(i,3) = XsSup;
                                        obj.similarity_sections(i,4) = YsInf + ((YeInf - YsInf) * (XsSup - XsInf) / (XeInf - XsInf)); 
                                        % correct for Y
                                        old_duration = XeInf - XsInf;
                                        XeInf = XsSup;
                                        YeInf = obj.similarity_sections(i,4);
                                        new_duration = XeInf - XsInf;
                                        obj.similarity_sections(i,5) = obj.similarity_sections(i,5) .* (new_duration / old_duration);
                                    end;
                                end;

                                if obj.similarity_sections(i,5)~=0 && YeInf > YsSup && YsInf < YeSup % there is an overlap on the Y
                                        if ((YsInf < YsSup && YeInf > YeSup) || (YsInf > YsSup && YeInf < YeSup))  % kill this section
                                            obj.similarity_sections(i,5) = 0;
                                        elseif YsInf > YsSup 
                                            old_duration = obj.similarity_sections(i,4) - obj.similarity_sections(i,2);
                                            obj.similarity_sections(i,2) = YeSup;
                                            new_duration = obj.similarity_sections(i,4) - obj.similarity_sections(i,2);
                                            obj.similarity_sections(i,1) = XsInf + ((XeInf - XsInf) .* (YeSup - YsInf) / (YeInf - YsInf)); % correct for X
                                            obj.similarity_sections(i,5) = obj.similarity_sections(i,5) .* (new_duration / old_duration);
                                        else 
                                            old_duration = obj.similarity_sections(i,4) - obj.similarity_sections(i,2);
                                            obj.similarity_sections(i,4) = YsSup;
                                            new_duration = obj.similarity_sections(i,4)- obj.similarity_sections(i,2);
                                            obj.similarity_sections(i,3) = XsInf + ((XeInf - XsInf) .* (YsSup - YsInf) / (YeInf - YsInf)); % correct for X
                                            obj.similarity_sections(i,5) = obj.similarity_sections(i,5) .* (new_duration / old_duration);
                                        end;
                                end;
                                % eliminate areas that are less than 5ms long
                                if obj.similarity_sections(i,3) - obj.similarity_sections(i,1) < 3 || obj.similarity_sections(i,4) - obj.similarity_sections(i,2) < 3 % kill this section
                                        obj.similarity_sections(i,5) = 0;
                                end;  
                            end;
                        end;
                    end;
                    obj.similarity_sections=sortrows(obj.similarity_sections,-5); % sort by area (5) largest to smallest
                    %assignin ('base','sections',obj.similarity_sections);
                    
                end
                
            
            
                function recalc_Similarity()
                    for i=1:obj.number_of_sections
                        if obj.similarity_sections(i,5)~=0 
                           % simple names for boundaries:
                            xs=obj.similarity_sections(i,1);
                            xe=obj.similarity_sections(i,3);
                            ys=obj.similarity_sections(i,2);
                            ye=obj.similarity_sections(i,4);
                            
                           % Adjust boundaries  based on time warping tolerance:
                           xSize=xe-xs;
                           ySize=ye-ys;
                           ratio=min(xSize,ySize)/max(xSize,ySize);
                           if ratio<SAT_params.time_warping_tolerance; % 0.9 by default
                               if xSize>ySize
                                   xe=xs+ySize+floor(ySize*(1-SAT_params.time_warping_tolerance));
                                   obj.similarity_sections(i,3)=xe;
                               else 
                                   ye=ys+xSize+floor(xSize*(1-SAT_params.time_warping_tolerance));
                                   obj.similarity_sections(i,4)=ye;
                               end;
                           end;
                           
                            
                           % Recalculate accuracy
                            accur=0;
                            if obj.similarity_sections(i,5)<0 && xe-xs > SAT_params.similarity_section_min_dur % these are the winning sections:
                                 slope=(xe-xs)/(ye-ys);
                                 band=SAT_params.accuracy_jitter; 
                                 similarity_ymax=obj.sound2.num_slices;
                                 accur=0;
                                 j=1;
                                 for k=floor(xs):floor(xe)
                                     y_target=floor(ys+(j*slope));
                                     y_min=max(floor(max(1,y_target-band)),1);
                                     y_max=floor(min(similarity_ymax,y_target+band)); 
                                     tmp=max(similarity(k,y_min:y_max));
                                     if(tmp>0)
                                        accur=accur+tmp;
                                     end;
                                     j=j+1;
                                 end
                                 if(accur)
                                     obj.similarity_sections(i,5)=accur;
                                 end;
                                else obj.similarity_sections(i,5)=accur*-1; % accur*-1;  %   label trimmed section as negatives
                            end;
                        end;
                    end;
                end
            
                
                
            
                function calc_Linearity()
                
                end
            
            
                
                function CalculateResults()
                    obj.local_similarity.all=Local; 
                    obj.local_similarity.similarity=threshold_matrix;
                    obj.local_similarity.pval=similarity;
                    obj.local_similarity.pitch=Local_pitch;
                    obj.local_similarity.goodness=Local_goodness;
                    obj.local_similarity.entropy=Local_entropy;
                    obj.local_similarity.FM=Local_FM;
                    obj.local_similarity.AM=Local_AM;
                    obj.global_similarity.all=Glob; 
                    obj.global_similarity.pitch=Global_pitch;
                    obj.global_similarity.goodness=Global_goodness;
                    obj.global_similarity.entropy=Global_entropy;
                    obj.global_similarity.FM=Global_FM;
                    obj.global_similarity.AM=Global_AM;
                    
                    %calculate similarity measures:
                    % first find number of eligible slices in tutor song, sound 1
                    if SAT_params.calc_silence % include silences in the similarity sections
                        ref=length(obj.sound1.signal); % should be equal to num slices   
                    else % include only number of slices with vocal sounds
                        ref=sum(obj.sound1.signal); % signal is zeros and ones, so only vocal sounds are considered
                    end;
                    sections_passed=obj.similarity_sections(obj.similarity_sections(:,5)>0,:); % these are the passed sections
                    dur_passed=sum(sections_passed(:,3)-sections_passed(:,1)); % duration of passed sections on the tutor side
                    sim_passed=sum(sections_passed(:,5));
                    obj.score.similarity=100*dur_passed/ref;
                    obj.score.accuracy=100*sqrt(sim_passed/ref);
                end   
            end

        
    end % end Methods
end

