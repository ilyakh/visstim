function runbaselineuntriggered(q, stimulusInfo)
%RUNBASELINEUNTRIGGERED Displays a black screen during baseline. 
%
% For untriggered mode only; calculates number of frames by dead reckoning
% and displays for that amount of time.
% Only bother doing this if there IS a baseline requested
if q.baseLineTime
    for i = 1:floor(stimulusInfo.baseLineSFrames)
        Screen('FillRect', q.window, 0);
        Screen('Flip',q.window);
        %Quit only if 'esc' key was pressed
        [~, ~, keyCode] = KbCheck;
        if keyCode(KbName('escape')), error('escape'), end
    end
end

end

