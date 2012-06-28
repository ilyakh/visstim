function stimulusInfo = DriftHold(randMode, hz, screenRect, window, baseLineTime,driftTime, postDriftHoldTime,  directionsNum, spaceFreqPixels, tempFreq, gratingtex, repeats, photoDiodeRect)
% DRIFTHOLD Displays a moving grating followed by static grating for
% defined time period
%
% Inputs:
%
% Randomisation Mode; Screen refresh rate; Screen Size (as rect); Window 
% Pointer; Baseline recording time; Drift time; postDrift hold time; Number
% of directions; the spatial frequency (in pixels) of the grating; Temporal
% frequency of the grating; gratingtex; number of repeats; lockout time 
% (to prevent mistriggering);'v' for verbose mode
%
%
% Ouput: 
%   stimulusInfo
%       .experimentType         'DH'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed
%       .repeats           
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .repeat              Which repetition, within the
%                                           run, this drift was in
%                   .num           Which number, within a repetition
%                                           this drift was
%                   .direction              In degrees, with 0 being upward movement, increasing CW     
%                   .startTime      Relative time, in seconds, since the
%                                      start of the experiment, that the
%                                      state started to be shown
%                   .endTime        Relative time, in seconds, since the
%                                      start of the experiment, that the
%                                      state stopped being shown
%
%  The following are added to stimulusInfo by the VisStim program itself,
%  after it is returned:
%       .temporalFreq           the grating temporal frequency
%       .spatialFreq            the grating spatial frequency
% (it's just easier that way. Think of them as outputs.)

DG_SpatialPeriod = ceil(1/spaceFreqPixels);             % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * tempFreq / hz;    % How far to shift the grating in each frame

%Initialise the output variable
stimulusInfo.experimentType = 'DH';
stimulusInfo.triggering = 'off';
stimulusInfo.baseLineTime = baseLineTime;
stimulusInfo.baseLineSFrames = baseLineTime*hz;
stimulusInfo.directionsNum = directionsNum;
stimulusInfo.repeats = repeats;

z = zeros(1, repeats * directionsNum*2);            % There will be 2 states for each orientation, of which there are
                                                        % directionsNum * repeats
stimulusInfo.stimuli = struct('type', z, 'repeat', z, 'num', z, 'direction', z, 'startTime', z, 'endTime', z);

% This switch structure preloads the stimuli struct with the desired
% directions
currentStimIndex = 0;
switch randMode
    
    case 0 %Orderly progression of gratings
        for repeat = 1:repeats
            for d=1:directionsNum
                stimulusInfo.stimuli(currentStimIndex*2+1).repeat = repeat;
                stimulusInfo.stimuli(currentStimIndex*2+1).num = d;
                stimulusInfo.stimuli(currentStimIndex*2+1).direction = (d-1)*360/directionsNum; % just dump in the angles in order, starting from 0
                stimulusInfo.stimuli(currentStimIndex*2+2).repeat = repeat;
                stimulusInfo.stimuli(currentStimIndex*2+2).num = d;
                stimulusInfo.stimuli(currentStimIndex*2+2).direction = (d-1)*360/directionsNum;
               
                currentStimIndex = currentStimIndex + 1;
            end
        end
    case 1 % Assign a pseudorandom order to be used in each repetition
        order = randperm(directionsNum);
        directionsOrder = (order-1) * 360/directionsNum;
        for repeat = 1:repeats
            for d=1:directionsNum
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
        for repeat = 1:repeats
            order = randperm(directionsNum);
            directionsOrder = (order-1) * 360/directionsNum;
            for d=1:directionsNum
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
        order = maximallyDifferentDirections(directionsNum);
        directionsOrder = (order-1) * 360/directionsNum;
        for repeat = 1:repeats
            for d=1:directionsNum
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

%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic

% During baseline, display a black screen
% Only bother doing this if there IS a baseline requested
if baseLineTime
    for i = 1:floor(stimulusInfo.baseLineSFrames)
        Screen('FillRect', window, 0);
        Screen('Flip',window);
        %Quit only if 'esc' key was pressed
        [~, ~, keyCode] = KbCheck;
        if find(keyCode) == 27, return, end
    end
    stimulusInfo.actualBaseLineTime = toc;
end

%The Display Loop - Displays the grating at predefined orientations from
%the switch structure

currentStimIndex = 0;       %keeps track of what index we are up to
for repeat = 1:repeats
    for d=1:directionsNum
        
        currentStimIndex = currentStimIndex + 1;
        thisDirection = stimulusInfo.stimuli(currentStimIndex).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
        
        %Drift
        stimulusInfo.stimuli(currentStimIndex).type = 'Drift';
        stimulusInfo.stimuli(currentStimIndex).startTime = toc;
        for frameCount= 1:round(driftTime * hz);
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
            srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
            
            % Draw grating texture, rotated by "angle":
            Screen('DrawTexture', window, gratingtex, srcRect, [], thisDirection);
            if photoDiodeRect(2)
                Screen('FillRect', window, 255,photoDiodeRect )
            end
            Screen('Flip',window);
            stimulusInfo.stimuli(currentStimIndex).endTime = toc;
        end
        %Quit only if 'esc' key was pressed
        [~, ~, keyCode] = KbCheck;
        if find(keyCode) == 27, return, end
        
        currentStimIndex = currentStimIndex + 1;
        
        %PostDrift Hold
        %Record absolute and relative start time
        stimulusInfo.stimuli(currentStimIndex).type = 'PostDriftHold';
        stimulusInfo.stimuli(currentStimIndex).startTime = toc;
        for holdFrames = 1:round(postDriftHoldTime*hz)
            Screen('DrawTexture', window, gratingtex, srcRect, [], thisDirection);
            if photoDiodeRect(2)
                Screen('FillRect', window, 0,photoDiodeRect )
            end
            Screen('Flip',window);
            stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
        end
        %Quit only if 'esc' key was pressed
        [~, ~, keyCode] = KbCheck;
        if find(keyCode) == 27, return, end
    end
end

%Display a black screen at the end
Screen('FillRect', window, 0);
Screen('Flip',window);

end
