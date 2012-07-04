function [stimulusInfo] = setstimulusinfobasicparams(q)
%SETSTIMULUSINFOBASICPARAMS Sets up stimulusInfo variable with basic
%information copied from the set VisStimAlex parameters.
%
%Used by all stimulus scripts.
stimulusInfo.experimentType = q.experimentType;
stimulusInfo.triggering = q.triggering;
stimulusInfo.directionsNum = q.directionsNum;
stimulusInfo.repeats = q.repeats;

if strcmp(q.triggering, 'off')
    stimulusInfo.baseLineTime = q.baseLineTime;
    stimulusInfo.baseLineSFrames = q.baseLineTime*q.hz;
end
end

