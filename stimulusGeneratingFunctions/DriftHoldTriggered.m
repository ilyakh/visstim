function stimulusInfo = DriftHoldTriggered(randMode, hz, screenRect, window,driftTime,  directionsNum, spaceFreqPixels, tempFreq, gratingtex, repeats, inputLine, inputPort, deviceName, photoDiodeRect)
%DRIFTHOLDTRIGGERED displays a moving grating for a defined time period,
%then holds this grating until a trigger
%
% Inputs:
%
% Randomisation Mode; Screen refresh rate; Screen Size (as rect); Window
% Pointer; Drift time; Number of directions; the spatial frequency (in
% pixels) of the grating; Temporal frequency of the grating; gratingtex;
% number of repeats; DIO input line; DIO input port; lockout time (to
% prevent mistriggering);'v' for verbose mode
%
% Unlike the untriggered version of this function, postdrift hold time and
% baseline time are determined by triggers therefore there is no need to
% input these parameters
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
%                   .type                   'Drift' or 'PostDriftHold'
%                   .repeat                 Which repetition, within the
%                                           run, this drift was in
%                   .num                    Which number, within a repetition
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
%
%---------------------------Initialisation--------------------------------
%Initialise NI card
dio = digitalio('nidaq', deviceName);
input = addline(dio, inputLine, inputPort, 'in');

DG_SpatialPeriod = ceil(1/spaceFreqPixels);             % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * tempFreq / hz;    % How far to shift the grating in each frame


%Initialise the output variable
stimulusInfo.experimentType = 'DH';
stimulusInfo.triggering = 'on';
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

% Display a black screen
Screen('FillRect', window, 0);
Screen('Flip',window);

% Hold until trigger to begin
while ~getvalue(input)
    %Quit only if 'esc' key was pressed, advance if 't' was pressed
    [keyDown, ~, keyCode] = KbCheck;
    if keyDown
        if find(keyCode) == 27, return, end
        if find(keyCode) == 84,
            %wait for keypress to end (=key up) before breaking
            while KbCheck
            end
            break
        end
    end
end
stimulusInfo.actualBaseLineTime = toc;

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
            %Quit only if 'esc' key was pressed, advance if 't' was pressed
            [keyDown, ~, keyCode] = KbCheck;
            if keyDown
                if find(keyCode) == 27, return, end
                if find(keyCode) == 84,
                    %wait for keypress to end (=key up) before breaking
                    while KbCheck
                    end
                    break
                end
            end
            
        end
        
        currentStimIndex = currentStimIndex + 1;
        
        %PostDrift Hold - until terminated by a trigger
        %Record absolute and relative start time
        %n.b. unlike the DriftOnly function, this does NOT require a
        %lockout time as the predrift and drift are essentially a lockout -
        %a definable time during which a trigger has no effect
        stimulusInfo.stimuli(currentStimIndex).type = 'PostDriftHold';
        stimulusInfo.stimuli(currentStimIndex).startTime = toc;
        while ~getvalue(input)
            Screen('DrawTexture', window, gratingtex, srcRect, [], thisDirection);
            if photoDiodeRect(2)
                Screen('FillRect', window, 0,photoDiodeRect )
            end
            Screen('Flip',window);
            stimulusInfo.stimuli(currentStimIndex).endTime = toc;
            
            %Quit only if 'esc' key was pressed
            %Quit only if 'esc' key was pressed, advance if 't' was pressed
            [keyDown, ~, keyCode] = KbCheck;
            if keyDown
                if find(keyCode) == 27, return, end
                if find(keyCode) == 84,
                    %wait for keypress to end (=key up) before breaking
                    while KbCheck
                    end
                    break
                end
            end
            
        end
    end
end

%Display a black screen at the end
Screen('FillRect', window, 0);
Screen('Flip',window);

end

