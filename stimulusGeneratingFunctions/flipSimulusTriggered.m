function stimulusInfo = flipSimulusTriggered(window, repeats, inputLine, inputPort, deviceName)
% function FLIPSTIMULUS flashes a white screen then a black screen for
% maximal stimulation. For use in testing or trying to evoke big responses
%
% n.b. as this is a triggered function, it does not need a baseline time or
% flipTime, as this is provided by the trigger. Black and white are the
% same duration, so here a 'cycle' is ONE state - black or white. Therefore
% the trigger frequency on the imaging computer corresponds to how long any
% ONE state will be displayed for.
%
% Inputs:
%
%   window    a handle to the current window
%   repeats     how many cycles of white then black to display
%   inputLine       which line to use on the NI card
%   inputPort       which port to use on the NI card
%
% Outputs:
%
%  stimulusInfo
%       .experimentType         'Flip'
%       .triggering             'on'
%       .repeats
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m  struct array:
%           m = repeat * 2 - a complete list of states
%                   .state                  'white' or 'black'
%                   .startTime              relative time, in seconds, since
%                                           the start of the experiment, that
%                                           the state started to be shown
%                   .endTime                relative time, in seconds, since
%                                           the start of the experiment,
%                                           that the state stopped being
%                                           shown

%----------------------Initialisations-------------------------------------
% Initialise National Instrument card for triggering
dio = digitalio('nidaq', deviceName);
input = addline(dio, inputLine, inputPort, 'in');


% Initialise the output variable
stimulusInfo.experimentType = 'Flip';
stimulusInfo.triggering = 'on';
stimulusInfo.repeats = repeats;

z = zeros(1, repeats * 2);
stimulusInfo.stimuli = struct('state', z, 'startTime', z, 'endTime', z);

%--------------------------------------------------------------------------

% start experiment clock
stimulusInfo.experimentStartTime = now;
tic


% During baseline, display a black screen
% Wait for trigger. Allow the user to terminate the test

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


for i = 1:repeats*2
    
    %Assign stimulus state label
    switch mod(i, 2)
        case 1
            stimulusInfo.stimuli(i).state = 'white';
        case 0
            stimulusInfo.stimuli(i).state = 'black';
    end
    
    stimulusInfo.stimuli(i).startTime = toc;
    
    % Loop until the input is low (i.e. the previous trigger has ended)
    % then loop till it's high (a new trigger)
    
    Screen('FillRect', window, (255*mod(i, 2)));
    while getvalue(input)
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
        Screen('Flip',window);
        stimulusInfo.stimuli(i).endTime = toc;
        
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

