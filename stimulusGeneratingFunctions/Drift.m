function stimulusInfo =  Drift(randMode, hz, screenRect, window, baseLineTime,driftTime,  directionsNum, spaceFreqPixels, tempFreq, gratingtex, repeats, photoDiodeRect)
% This function displays a dynamic grating.
%
% Inputs:
%
% Randomisation Mode; Screen refresh rate; Screen Size (as rect); Window
% Pointer; Baseline recording time; Drift time; Number of directions; the
% spatial frequency (in pixels) of the grating; Temporal frequency of the
% grating; gratingtex; number of repeats; lockout time (to prevent
% mistriggering); 'v' for verbose mode
%
%
% Ouput:
%   stimulusInfo
%       .experimentType         'D'
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
%                   .type           'Drift'
%                   .repeat         Which repetition, within the run, this
%                                      drift was in
%                   .num            Which number, within a repetition this
%                                      drift was
%                   .direction      In degrees, with 0 being upward movement, increasing CW
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

%---------------------------Initialisation--------------------------------
DG_SpatialPeriod = ceil(1/spaceFreqPixels);             % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * tempFreq / hz;    % How far to shift the grating in each frame
DG_DirectionFrames = round(driftTime * hz);             % How many frames are to be displayed for each direction

%Initialise the output variable
stimulusInfo.experimentType = 'D';
stimulusInfo.triggering = 'off';
stimulusInfo.baseLineTime = baseLineTime;
stimulusInfo.baseLineSFrames = baseLineTime*hz;
stimulusInfo.directionsNum = directionsNum;
stimulusInfo.repeats = repeats;

z = zeros(1, repeats * directionsNum);
stimulusInfo.stimuli = struct('type', z, 'repeat', z, 'num', z, 'direction', z, 'startTime', z, 'endTime', z);

% This switch structure preloads the stimuli struct with the desired
% directions
switch randMode
    
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
    case 3 % choose maximally different stimuli
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
for repeat = 1:repeats
    for d=1:directionsNum
        %Record absolute and relative stimulus start time
        stimulusInfo.stimuli((repeat-1)*directionsNum + d).startTime = toc;
        stimulusInfo.stimuli((repeat-1)*directionsNum + d).type='Drift';
        thisDirection = stimulusInfo.stimuli((repeat-1)*directionsNum + d).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
        for frameCount= 1:DG_DirectionFrames;
            %Define shifted srcRect that cuts out the properly shifted rectangular
            %area from the texture:
            xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
            srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
            
            %Draw grating texture, rotated by "angle":
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