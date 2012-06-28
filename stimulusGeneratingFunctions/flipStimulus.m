
function stimulusInfo = flipStimulus(window, hz, baseLineTime, repeats, flipTime)
% function FLIPSTIMULUS flashes a white screen then a black screen for
% maximal stimulation. For use in testing or trying to evoke big responses
%
% Inputs:
%
%   window    a handle to the current window
%   hz        the screen refresh rate
%   baseLineTime    how long to record baseline activity for (in seconds)
%   repeats     how many cycles of white then black to display
%   flipTime        how long to hold each state for (in seconds)
%
% Output:
%
%  stimulusInfo
%       .experimentType         'Flip'
%       .triggering             'off'
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .repeats
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * 2 - a complete list of states
%                   .state                  'white' or 'black'
%                   .startTime              relative time, in seconds, since
%                                           the start of the experiment, that
%                                           the state started to be shown
%                   .endTime                relative time, in seconds, since
%                                           the start of the experiment,
%                                           that the state stopped being
%                                           shown
%
%

%---------------------------Initialisation--------------------------------
% Initialise the output variable
stimulusInfo.experimentType = 'Flip';
stimulusInfo.triggering = 'off';
stimulusInfo.baseLineTime = baseLineTime;
stimulusInfo.baseLineSFrames = baseLineTime*hz;
stimulusInfo.repeats = repeats;

z = zeros(1, repeats * 2);
stimulusInfo.stimuli = struct('state', z, 'startTime', z, 'endTime', z);


%-------------------------------------------------------------------------

%Start the clock & record absolute clock start time
stimulusInfo.experimentStartTime = now;
tic;
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

for i = 1:repeats * 2
    switch mod(i, 2)
        case 1
            stimulusInfo.stimuli(i).state = 'white';
        case 0
            stimulusInfo.stimuli(i).state = 'black';
    end
    stimulusInfo.stimuli(i).startTime = toc;
    %Display the screen
    for j = 1:(flipTime*hz)
        Screen('FillRect', window, 255*(mod(i, 2)));
        Screen('Flip',window);
        stimulusInfo.stimuli(i).endTime = toc;
    end
    
    %Quit only if 'esc' key was pressed
    [~, ~, keyCode] = KbCheck;
    if find(keyCode) == 27, return, end
end
