function [stimulusInfo] = setstimulusinfobasicparams(q)
%SETSTIMULUSINFOBASICPARAMS Sets up stimulusInfo variable with basic
%information copied from the set VisStimAlex parameters.
%
%Used by all stimulus scripts.
stimulusInfo.experimentType = q.experimentType;
stimulusInfo.triggering = q.triggering;

if strcmp(q.triggering, 'off')
    stimulusInfo.baseLineTime = q.baseLineTime;
    stimulusInfo.baseLineSFrames = q.baseLineTime*q.hz;
end

switch q.experimentType
    case {'D', 'HD', 'HDH', 'DH'}
        stimulusInfo.directionsNum = q.directionsNum;
        stimulusInfo.repeats = q.repeats;
    case'Ret'
        stimulusInfo.nPatches = q.patchGridDimensions(1)*q.patchGridDimensions(2);
        stimulusInfo.patchGridX=q.patchGridX;
        stimulusInfo.patchGridY=q.patchGridY;
        stimulusInfo.repeats = q.repeats;
    case 'spn'
        stimulusInfo.spnSpotSize=q.spnSpotSize;
        stimulusInfo.meanSpots=q.meanSpots;
        stimulusInfo.stdSpots=q.stdSpots;
        stimulusInfo.spotTime=q.spotTime;
        stimulusInfo.nStimFrames=q.nStimFrames;
        stimulusInfo.spotSizeDegrees=atand(q.screenWidthCm/2/q.mouseDistanceCm)/q.screenRect(3)*q.spnSpotSize;
end

end

