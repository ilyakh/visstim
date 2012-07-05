function runbaseline(q, stimulusInfo)
%RUNBASELINE Displays a black screen during baseline. 
%
% For both triggere AND untriggered mode 
%
% Untriggered: calculates number of frames by dead reckoning
% and displays for that amount of time.
% Only bother doing this if there IS a baseline requested
%
% Triggered mode: displays a black screen, until trigger
switch q.triggering
    case 'off'
        if q.baseLineTime
            for i = 1:floor(stimulusInfo.baseLineSFrames)
                Screen('FillRect', q.window, 0);
                Screen('Flip',q.window);
                %Quit only if 'esc' key was pressed
                [~, ~, keyCode] = KbCheck;
                if keyCode(KbName('escape')), error('escapeBsl'), end
            end
        end
    case 'on'
        % Display a black screen
        Screen('FillRect', q.window, 0);
        Screen('Flip',q.window);
        
        while ~getvalue(q.input)
            %Quit only if 'esc' key was pressed, advance if 't' was pressed
            [~, ~, keyCode] = KbCheck;
            if keyCode(KbName('escape')), error('escapeBsl'), end
            if keyCode(KbName('t')) 
                %wait for keypress to end (=key up) before breaking
                while KbCheck
                end
                break
            end
        end
end
end


