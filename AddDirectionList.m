
    directions = zeros(2, size(stimulusInfo.stimuli, 2));
    for i = 1:size(stimulusInfo.stimuli, 2)
        directions(1, i) = stimulusInfo.stimuli(i).direction;
        if strcmp(stimulusInfo.stimuli(1, i).type,'Drift')
            directions(2, i) = 1;
        else
            directions(2, i) = 0;
        end
    end
    stimulusInfo.directions = directions;