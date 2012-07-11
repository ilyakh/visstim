function stimulusInfo =  RetinotopyDrift(q)
% This function displays a drifting retinotopy stimulus, untriggered
%
% Inputs:
%
%   q - structure with all parameters entered in to or calculated in
%   VisStimAlex
%
% Ouput:
%   stimulusInfo
%       .experimentType         'Ret'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed in each patch
%       .repeats                Number of cycles of ALL patches
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .patchGridDimensions    a copy of patchGridDimensions - the number
%                                  of divisions ([x y])
%       .stimuli                a 1 x m struct array:
%               m = repeat * directions * patchGrid_x*patchGrid_y - a complete list of states
%                   .type               'Drift'
%                   .repeat             Which repetition, within the run, this
%                                           drift was in
%                   .patch              The number of the patch - in order
%                                           from top left, rows first 
%                   .num                Which number, within a repetition this
%                                           drift was
%                   .direction          In degrees, with 0 being upward movement, increasing CW
%                   .startTime          Relative time, in seconds, since the
%                                           start of the experiment, that the
%                                           state started to be shown
%                   .endTime            Relative time, in seconds, since the
%                                           start of the experiment, that the
%                                           state stopped being shown
%
%  The following are added to stimulusInfo by the VisStim program itself,
%  after it is returned:
%       .temporalFreq           the grating temporal frequency
%       .spatialFreq            the grating spatial frequency
% (it's just easier that way. Think of them as outputs.)

%% ---------------------------Initialisation--------------------------------
DG_SpatialPeriod = ceil(1/q.spaceFreqPixels);             % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * q.tempFreq / q.hz;    % How far to shift the grating in each frame
DG_DirectionFrames = round(q.driftTime * q.hz);             % How many frames are to be displayed for each direction

%Initialise the output variable
stimulusInfo.experimentType = 'Ret';
stimulusInfo.triggering = 'off';
stimulusInfo.baseLineTime = q.baseLineTime;
stimulusInfo.baseLineSFrames = q.baseLineTime*q.hz;
stimulusInfo.directionsNum = q.directionsNum;
stimulusInfo.repeats = q.repeats;

nPatches = q.patchGridDimensions(1)*q.patchGridDimensions(2);

z = zeros(1, q.repeats * q.directionsNum * nPatches);
stimulusInfo.stimuli = struct('type', z, 'repeat', z, 'patch', z, 'num', z, 'direction', z, 'startTime', z, 'endTime', z);
%% Stimulus Generation
% This switch structure preloads patch identity
        patches = zeros(nPatches*q.repeats, 1);
switch q.retinotopyRandMode
    case 0 %orderly progression of patches
         for i = 1:q.repeats
            patches(((i-1)*nPatches +1): i*nPatches) = 1:nPatches;
         end
    case 1 %pseudorandom repeated
        O=randperm(nPatches);
         for i = 1:q.repeats
            patches(((i-1)*nPatches +1): i*nPatches)= O;
         end
    case 2 %pseudorandom
        patches = zeros(nPatches*q.repeats, 1);
        for i = 1:q.repeats
            patches(((i-1)*nPatches +1): i*nPatches) = randperm(nPatches);
        end
    case 3
        for i = 1:q.repeats
            patches(((i-1)*nPatches +1): i*nPatches) = maximallyDifferentDirections(nPatches);
        end
end
patches =imresize(patches, [length(patches)*q.directionsNum, 1], 'nearest'); % duplicate for all directions
% This switch structure preloads direction identity
dirsN=zeros(q.directionsNum*nPatches*q.repeats, 1);
switch q.randMode
    case 0 %orderly progression of directions
        d=1:q.directionsNum;
        for i=1:q.directionsNum:length(dirsN)
            dirsN(i:i+q.directionsNum-1) = d;
        end
    case 1 %pseudorandom repeated
        d= randperm(q.directionsNum);
        for i=1:q.directionsNum:length(dirsN)
            dirsN(i:i+q.directionsNum-1) = d;
        end
    case 2 %pseudorandom
        for i=1:q.directionsNum:length(dirsN)
            d= randperm(q.directionsNum);
            dirsN(i:i+q.directionsNum-1) = d;
        end
    case 3 %max diff
        d= maximallyDifferentDirections(q.directionsNum);
        for i=1:q.directionsNum:length(dirsN)
            dirsN(i:i+q.directionsNum-1) = d;
        end
end
directions = (dirsN-1)*(360/q.directionsNum);

 % and assign
 idx = 0;
 for repeat = 1:q.repeats
     for patch=1:nPatches
         for d=1:q.directionsNum
             idx=idx+1;
             stimulusInfo.stimuli(idx).repeat = repeat;
             stimulusInfo.stimuli(idx).patch = patches(idx);
             stimulusInfo.stimuli(idx).num = d;
             stimulusInfo.stimuli(idx).direction = directions(idx); % just dump in the angles in order, starting from 0
         end
     end
 end
 %% Patch Overlay Generation
 %calculate patch grid
 
 [py, px]=meshgrid(linspace(0, 1, q.patchGridDimensions(2)+1), linspace(0, 1, q.patchGridDimensions(1)+1));
 px=px(1:end-1, 1:end-1).*q.screenRect(3);
 py=py(1:end-1, 1:end-1).*q.screenRect(4);
 stepSz=[px(2, 1) py(1, 2)];
 
 %enable alpha blending and create masks
 Screen('BlendFunction', q.window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 mask=ones(q.screenRect(3), q.screenRect(4), 2) * 128; %unused luminance channel - fill with grey
 mask(:,:,2)=255; %default alpha channel to max(opaque)
 
 masktex=zeros(nPatches, 1); %array of handles
 
 for i = 1:nPatches
     tmp =mask;
     minX=round(px(i)); if minX ==0; minX=1; end
     minY=round(py(i)); if minY ==0; minY =1; end
     maxX=round(px(i)+stepSz(1));
     maxY=round(py(i)+stepSz(2));
     tmp(minX:maxX, minY:maxY, 2)=0;
     tmpT(:,:,1) = tmp(:,:,1)';
     tmpT(:,:,2) = tmp(:,:,2)';
     masktex(i)=Screen('MakeTexture', q.window, tmpT);
 end
 clear tmp
 %% Stimulus Execution
 %grey background
 Screen('Rect', q.window);
   
%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic

% During baseline, display a black screen
% Only bother doing this if there IS a baseline requested
if q.baseLineTime
    for i = 1:floor(stimulusInfo.baseLineSFrames)
        Screen('FillRect', q.window, 0);
        Screen('Flip',q.window);
        %Quit only if 'esc' key was pressed
        [~, ~, keyCode] = KbCheck;
        if keyCode(KbName('escape')), return, end
    end
    stimulusInfo.actualBaseLineTime = toc;
end


%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
idx=0;
qFlag=0;
for repeat = 1:q.repeats
    for patch = 1:nPatches
        %overdraw the photodiode rectangle if it is of finite size (i.e.
        %wanted)
        for d=1:q.directionsNum
            idx=idx+1;
            %Record absolute and relative stimulus start time
            stimulusInfo.stimuli(idx).startTime = toc;
            stimulusInfo.stimuli(idx).type='Drift';
            thisDirection = stimulusInfo.stimuli(idx).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
            for frameCount= 1:DG_DirectionFrames;
                %Define shifted srcRect that cuts out the properly shifted rectangular
                %area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                srcRect=[xoffset 0 (xoffset + q.screenRect(3)*2) q.screenRect(4)*2];
                                
                %Draw grating texture, rotated by "angle":
                Screen('DrawTexture', q.window, q.gratingtex, srcRect, [], thisDirection);
                
                %overdraw the alpha mask
                Screen('DrawTexture', q.window, masktex(stimulusInfo.stimuli(idx).patch));
                
                if q.photoDiodeRect(2) 
                    if d==1
                        Screen('FillRect', q.window, 255,q.photoDiodeRect )
                    else
                        Screen('FillRect', q.window, 0, q.photoDiodeRect)
                    end
                end

                %push to screen
                Screen('Flip',q.window);
                
                %Record measured stimulus display time
                stimulusInfo.stimuli((repeat-1)*q.directionsNum + d).endTime = toc;
            end
        end
        
        %Quit only if 'esc' key was pressed
        [~, ~, keyCode] = KbCheck;
        if keyCode(KbName('escape')), qFlag=1; return, end
    end
    if qFlag==1
        return
    end
end
    
    %Display a black screen at the end
    Screen('FillRect', q.window, 0);
    Screen('Flip',q.window);
    
end