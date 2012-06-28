function stimulusInfo = DriftTriggered(RandMode, hz, screenRect, window, directionsNum, spaceFreqPixels, tempFreq, gratingtex, repeats, inputLine, inputPort, deviceName, photoDiodeRect)
% This function displays a dynamic grating that changes on a trigger.
%
% Inputs:
%
% Randomisation Mode; Screen refresh rate; Screen Size (as rect); Window
% Pointer; Number of directions; the spatial frequency (in pixels) of the
% grating; Temporal frequency of the grating; gratingtex; number of
% repeats; input Line; input Port, trigger lock out time; 'v' for verbose
% mode
%
% Unlike the untriggered version of this function, drift time is determined
% by triggers therefore there is no need to input drift time or baseline
% time
%
%
% Ouput:
%   stimulusInfo
%       .experimentType         'D'
%       .triggering             'on'
%       .directionsNum          Number of different directions displayed
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .type               'Drift'
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


%---------------------------Initialisation---------------------------------
%Initialise NI card
dio = digitalio('nidaq', deviceName);
input = addline(dio, inputLine, inputPort, 'in');

DG_SpatialPeriod = ceil(1/spaceFreqPixels);              % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * tempFreq / hz;    % How far to shift the grating in each frame

%Initialise the output variable
stimulusInfo.experimentType = 'D';
stimulusInfo.triggering = 'on';
stimulusInfo.directionsNum = directionsNum;
stimulusInfo.repeats = repeats;

z = zeros(1, repeats * directionsNum);
stimulusInfo.stimuli = struct('type', z, 'repeat', z, 'num', z, 'direction', z, 'startTime', z, 'endTime', z);

% This switch structure preloads the stimuli struct with the desired
% directions
switch RandMode
    
    case 0 %Orderly progression of gratings
        for repeat = 1:repeats
            for d=1:directionsNum
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).repeat = repeat;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).num = d;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).direction = (d-1)*360/directionsNum; % just dump in the angles in order, starting from 0
            end
        end
    case 1 % Assign a pseudorandom order to be used in each repetition
        order = randperm(directionsNum);
        directionsOrder = (order-1) * 360/directionsNum;
        for repeat = 1:repeats
            for d=1:directionsNum
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).repeat = repeat;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).num = d;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
            end
        end
    case 2 % Assign a new pseudorandom order for each repetition
        for repeat = 1:repeats
            order = randperm(directionsNum);
            directionsOrder = (order-1) * 360/directionsNum;
            for d=1:directionsNum
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).repeat = repeat;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).num = d;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
            end
        end
    case 3
        order = maximallyDifferentDirections(directionsNum);
        directionsOrder = (order-1) * 360/directionsNum;
        for repeat = 1:repeats
            for d=1:directionsNum
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).repeat = repeat;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).num = d;
                stimulusInfo.stimuli((repeat -1)*directionsNum + d).direction = directionsOrder(d); % assign the appropriate direction
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
for repeat = 1:repeats
    for d=1:directionsNum
        %Record absolute and relative stimulus start time
        stimulusInfo.stimuli((repeat-1)*directionsNum + d).startTime = toc;
        stimulusInfo.stimuli((repeat-1)*directionsNum + d).type = 'Drift';
        thisDirection = stimulusInfo.stimuli((repeat-1)*directionsNum + d).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
        frameCount = 0;
        % Loop while value is high, in case there is trigger overrun from a
        % previous trigger. Then loop while value is low - so until the
        % next trigger
        while getvalue(input)
            frameCount = frameCount + 1;
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
            srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
            % Draw grating texture, rotated by "angle":
            Screen('DrawTexture', window, gratingtex, srcRect, [], thisDirection);
            if photoDiodeRect(2)
                if frameCount == 1
                    Screen('FillRect', window, 255,photoDiodeRect )
                else
                    Screen('FillRect', window, 0,photoDiodeRect )
                end
            end
            Screen('Flip',window);
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
        while ~getvalue(input)
            frameCount = frameCount + 1;
            % Define shifted srcRect that cuts out the properly shifted rectangular
            % area from the texture:
            xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
            srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
            % Draw grating texture, rotated by "angle":
            Screen('DrawTexture', window, gratingtex, srcRect, [], thisDirection);
            if photoDiodeRect(2)
                if frameCount == 1
                    Screen('FillRect', window, 255,photoDiodeRect )
                else
                    Screen('FillRect', window, 0,photoDiodeRect )
                end
            end
            Screen('Flip',window);
            %Record measured stimulus display time
            stimulusInfo.stimuli((repeat-1)*directionsNum + d).endTime = toc;
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

