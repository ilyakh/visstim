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
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum).type=[];
        
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
    case 'DH'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
        case 'HD'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*2).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/q.directionsNum;
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*2+2).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
        case 'HDH'
        %Preallocate
        stimulusInfo.stimuli = struct('type', [], 'repeat', [], 'num', [], 'direction', [], 'startTime', [], 'endTime', []);
        stimulusInfo.stimuli(q.repeats * q.directionsNum*3).type=[];
        
        % This switch structure preloads the stimuli struct with the desired
        % directions
        currentStimIndex = 0;
        switch q.randMode
            case 0 %Orderly progression of gratings
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = (d-1)*360/q.directionsNum; % just dump in the angles in order, starting from 0
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = (d-1)*360/q.directionsNum;
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = (d-1)*360/q.directionsNum;

                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 1 % Assign a pseudorandom order to be used in each repetition
                order = randperm(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);

                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 2 % Assign a new pseudorandom order for each repetition
                for repeat = 1:q.repeats
                    order = randperm(q.directionsNum);
                    directionsOrder = (order-1) * 360/q.directionsNum;
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
            case 3
                order = maximallyDifferentDirections(q.directionsNum);
                directionsOrder = (order-1) * 360/q.directionsNum;
                for repeat = 1:q.repeats
                    for d=1:q.directionsNum
                        stimulusInfo.stimuli(currentStimIndex*3+1).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+1).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+1).direction = directionsOrder(d); % assign the appropriate direction
                        stimulusInfo.stimuli(currentStimIndex*3+2).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+2).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+2).direction = directionsOrder(d);
                        stimulusInfo.stimuli(currentStimIndex*3+3).repeat = repeat;
                        stimulusInfo.stimuli(currentStimIndex*3+3).num = d;
                        stimulusInfo.stimuli(currentStimIndex*3+3).direction = directionsOrder(d);
                        
                        currentStimIndex = currentStimIndex + 1;
                    end
                end
        end
end

end

