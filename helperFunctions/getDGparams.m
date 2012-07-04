function [ DG_SpatialPeriod,  DG_ShiftPerFrame, DG_DirectionFrames] = getDGparams(q)
%GETDGPARAMS Calculates drifting grating parameters, used by all DG stimuli
DG_SpatialPeriod = ceil(1/q.spaceFreqPixels);             % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * q.tempFreq / q.hz;    % How far to shift the grating in each frame
DG_DirectionFrames = round(q.driftTime * q.hz);             % How many frames are to be displayed for each direction
end

