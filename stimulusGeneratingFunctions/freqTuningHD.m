function stimulusInfo = freqTuningHD(q)
%HOLDDRIFT displays a stationary then drifting grating, for predefined
%times, for one direction but multiple spatial and temporal frequencies
%
% Inputs:
%
% q
%
% Ouput:
%   stimulusInfo
%       .experimentType         'HD'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .direction              direction used for stimulus
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .type                   'PreDriftHold' or 'Drift'
%                   .repeat                 Which repetition, within the
%                                           run, this drift was in
%                   .num                    Which number, within a repetition
%                                           this drift was
%                   .tempFreq
%                   .spaceFreq
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
%Initialise the output variable
stimulusInfo = setstimulusinfobasicparams(q);
stimulusInfo = setstimulusinfostimuli(stimulusInfo, q);


s=q.spaceFreqDeg;
sp=q.spaceFreqPixels;
t=q.tempFreq;
DG_SpatialPeriod=zeros(length(s), length(t)); DG_ShiftPerFrame=zeros(length(s), length(t));
for ii=1:length(s)
    for jj=1:length(t)
        q.spaceFreq=s(ii);
        q.spaceFreqPixels=sp(ii);
        q.tempFreq=t(jj);
        [DG_SpatialPeriod(ii, jj), DG_ShiftPerFrame(ii, jj)] = getDGparams(q);
    end
end

q.spaceFreqDeg=s;
q.spaceFreqPixels=sp;
q.tempFreq=t;
[sGrid, tGrid]=meshgrid(s, t);


%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic
runbaseline(q, stimulusInfo)
stimulusInfo.actualBaseLineTime = toc;

%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
try
    currentStimIndex = 0;       %keeps track of what index we are up to
    for repeat = 1:q.repeats
        for d=1:length(s)*length(t)
            
            currentStimIndex = currentStimIndex + 1;
            thisGratingTexTem=stimulusInfo.stimuli(currentStimIndex).num(1);
            thisGratingTexSp=stimulusInfo.stimuli(currentStimIndex).num(2);
            thisDirection = stimulusInfo.stimuli(currentStimIndex).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
            %PreDrift Hold
            srcRect=[0 0 q.screenRect(3)*2 q.screenRect(4)*2];
            stimulusInfo.stimuli(currentStimIndex).type = 'PreDriftHold';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for holdFrames = 1:round(q.preDriftHoldTime*q.hz)
                Screen('DrawTexture', q.window, q.gratingtex(thisGratingTexSp), srcRect, [], thisDirection);
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 255,q.photoDiodeRect )
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
            
            currentStimIndex = currentStimIndex + 1;
            
            %Drift
            stimulusInfo.stimuli(currentStimIndex).type = 'Drift';
            stimulusInfo.stimuli(currentStimIndex).startTime = toc;
            for frameCount= 1:round(q.driftTime * q.hz);
                % Define shifted srcRect that cuts out the properly shifted rectangular
                % area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame(thisGratingTexSp, thisGratingTexTem),...
                                    DG_SpatialPeriod(thisGratingTexSp, thisGratingTexTem));
                srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                
                % Draw grating texture, rotated by "angle":
                Screen('DrawTexture', q.window, q.gratingtex(thisGratingTexSp), srcRect, [], thisDirection);
                if q.photoDiodeRect(2)
                    Screen('FillRect', q.window, 0,q.photoDiodeRect )
                end
                Screen('Flip',q.window);
                stimulusInfo.stimuli(currentStimIndex).endTime = toc; %record actual time taken
            end
            %Quit only if 'esc' key was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escape'), end
        end
    end
catch err
    if ~strcmp(err.message, 'escape')
        rethrow(err)
    end
end
%Display a black screen at the end
Screen('FillRect', q.window, 0);
Screen('Flip',q.window);

end

