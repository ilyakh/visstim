function [stimulusInfo] = setstimulusinfobasicparams(q)
%SETSTIMULUSINFOBASICPARAMS Sets up stimulusInfo variable with basic
%information copied from the set VisStimAlex parameters.
%
%Used by all stimulus scripts.
stimulusInfo.experimentType = q.experimentType;
stimulusInfo.triggering = q.triggering;
stimulusInfo.repeats = q.repeats;

if strcmp(q.triggering, 'off')
    stimulusInfo.baseLineTime = q.baseLineTime;
    stimulusInfo.baseLineSFrames = q.baseLineTime*q.hz;
end

if sum(strcmp(q.experimentType, {'D', 'HD', 'HDH', 'DH'}))
    stimulusInfo.directionsNum = q.directionsNum;
end
end

