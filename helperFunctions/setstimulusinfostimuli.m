function stimulusInfo = setstimulusinfostimuli(stimulusInfo, q)
%SETSTIMULUSINFOSTIMULI Adds stimuli struct to the stimulusInfo struct.

switch q.experimentType
    case 'Flip'
        %Preallocate
        stimulusInfo.stimuli = struct('state', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats*2).state =[];
        for i =1:2:length(stimulusInfo.stimuli)
            stimulusInfo.stimuli(i).state = 'white';
            stimulusInfo.stimuli(i+1).state = 'black';
        end
    case 'D'
        %Preallocate
        stimulusInfo.stimuli(q.repeats * q.directionsNum)=[];
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);

        % This switch structure preloads the stimuli struct with the desired
        % directions
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
            case 3 % choose maximally different stimuli
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).repeat = repeat;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).num = d;
                        stimulusInfo.stimuli((repeat -1)*q.directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
                    end
                end
        end

end

end

