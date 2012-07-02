function stimulusInfo =  RetinotopyDrift(randMode, retinotopyRandMode, patchGridDimensions, hz, screenRect, window, baseLineTime,driftTime,  directionsNum, spaceFreqPixels, tempFreq, gratingtex, repeats, photoDiodeRect)
% This function displays a drifting retinotopy stimulus, untriggered
%
% Inputs:
%
% Randomisation Mode; Screen refresh rate; Screen Size (as rect); Window
% Pointer; Baseline recording time; Drift time; Number of directions; the
% spatial frequency (in pixels) of the grating; Temporal frequency of the
% grating; gratingtex; number of repeats; lockout time (to prevent
% mistriggering); 'v' for verbose mode
%
%
% Ouput:
%   stimulusInfo
%       .experimentType         'Ret'
%       .triggering             'off'
%       .baseLineTime           a copy of baseLineTime
%       .baseLineSFrames        stimulus frames during baseline (calculated)
%       .directionsNum          Number of different directions displayed in each patch
%       .repeats                    Number of cycles of ALL patches
%       .experimentStartTime    what time the experiment started (beginning
%                               of baseline)
%       .actualBaseLineTime     how long baseLine actually was (tictoc)
%       .stimuli                a 1 x m struct array:
%               m = repeat * directions * patchGrid_x*patchGrid_y - a complete list of states
%                   .type               'Drift'
%                   .repeat             Which repetition, within the run, this
%                                           drift was in
%                   .patchLocation  The location of the patch, in the range
%                   [0-1.0, 0-1.0]
%                   .num                Which number, within a repetition this
%                                           drift was
%                   .direction          In degrees, with 0 being upward movement, increasing CW
%                   .startTime          Relative time, in seconds, since the
%                                           start of the experiment, that the
%                                           state started to be shown
%                   .endTime        Relative time, in seconds, since the
%                                           start of the experiment, that the
%                                           state stopped being shown
%
%  The following are added to stimulusInfo by the VisStim program itself,
%  after it is returned:
%       .temporalFreq           the grating temporal frequency
%       .spatialFreq            the grating spatial frequency
% (it's just easier that way. Think of them as outputs.)

%% ---------------------------Initialisation--------------------------------
DG_SpatialPeriod = ceil(1/spaceFreqPixels);             % EDIT:Was originally (1/space_freq) / 2. Not sure why.
DG_ShiftPerFrame = DG_SpatialPeriod * tempFreq / hz;    % How far to shift the grating in each frame
DG_DirectionFrames = round(driftTime * hz);             % How many frames are to be displayed for each direction

%Initialise the output variable
stimulusInfo.experimentType = 'Ret';
stimulusInfo.triggering = 'off';
stimulusInfo.baseLineTime = baseLineTime;
stimulusInfo.baseLineSFrames = baseLineTime*hz;
stimulusInfo.directionsNum = directionsNum;
stimulusInfo.repeats = repeats;

nPatches = patchGridDimensions(1)*patchGridDimensions(2);

z = zeros(1, repeats * directionsNum * nPatches);
stimulusInfo.stimuli = struct('type', z, 'repeat', z, 'patch', z, 'num', z, 'direction', z, 'startTime', z, 'endTime', z);
%% Stimulus Generation
% This switch structure preloads patch identity
        patches = zeros(nPatches*repeats, 1);
switch retinotopyRandMode
    case 0 %orderly progression of patches
         for i = 1:repeats
            patches(((i-1)*nPatches +1): i*nPatches) = 1:nPatches;
         end
    case 1 %pseudorandom repeated
        O=randperm(nPatches);
         for i = 1:repeats
            patches(((i-1)*nPatches +1): i*nPatches)= O;
         end
    case 2 %pseudorandom
        patches = zeros(nPatches*repeats, 1);
        for i = 1:repeats
            patches(((i-1)*nPatches +1): i*nPatches) = randperm(nPatches);
        end
    case 3
        for i = 1:repeats
            patches(((i-1)*nPatches +1): i*nPatches) = maximallyDifferentDirections(nPatches);
        end
end
patches =imresize(patches, [length(patches)*directionsNum, 1], 'nearest'); % duplicate for all directions
% This switch structure preloads direction identity
dirsN=zeros(directionsNum*nPatches*repeats, 1);
switch randMode
    case 0 %orderly progression of directions
        d=1:directionsNum;
        for i=1:directionsNum:length(dirsN)
            dirsN(i:i+directionsNum-1) = d;
        end
    case 1 %pseudorandom repeated
        d= randperm(directionsNum);
        for i=1:directionsNum:length(dirsN)
            dirsN(i:i+directionsNum-1) = d;
        end
    case 2 %pseudorandom
        for i=1:directionsNum:length(dirsN)
            d= randperm(directionsNum);
            dirsN(i:i+directionsNum-1) = d;
        end
    case 3 %max diff
        d= maximallyDifferentDirections(directionsNum);
        for i=1:directionsNum:length(dirsN)
            dirsN(i:i+directionsNum-1) = d;
        end
end
directions = (dirsN-1)*(360/directionsNum);

 % and assign
 idx = 0;
 for repeat = 1:repeats
     for patch=1:nPatches
         for d=1:directionsNum
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
 
 [px, py]=meshgrid(linspace(0, 1, patchGridDimensions(1)+1), linspace(0, 1, patchGridDimensions(2)+1));
 px=px(1:end-1, 1:end-1)'.*screenRect(3);
 py=py.*screenRect(4);
 stepSz=[px(2) py(2)];
 py=py(1:end-1, 1:end-1)';
 
 %enable alpha blending and create masks
 Screen('BlendFunction', window, GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);
 mask=ones(screenRect(3), screenRect(4), 2) * 128; %unused luminance channel - fill with grey
 mask(:,:,2)=255; %default alpha channel to max(opaque)
 
 masktex=zeros(nPatches, 1); %array of handles
 
 for i = 1:nPatches
     tmp =mask;
     minX=round(px(i)); if minX ==0; minX=1; end
     minY=round(py(i)); if minY ==0; minY =1; end
     maxX=round(px(i)+stepSz(1));
     maxY=round(py(i)+stepSz(2));
     tmp(minX:maxX, minY:maxY, 2)=0;
     masktex(i)=Screen('MakeTexture', window, tmp);
 end
 clear tmp
 %% Stimulus Execution
 %grey background
 Screen('Rect', window);
   
%--------------------------------------------------------------------------
% Let's get going...
stimulusInfo.experimentStartTime = now;
tic

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


%The Display Loop - Displays the grating at predefined orientations from
%the switch structure
idx=0;
qFlag=0;
for repeat = 1:repeats
    for patch = 1:nPatches
        %overdraw the photodiode rectangle if it is of finite size (i.e.
        %wanted)
        for d=1:directionsNum
            idx=idx+1;
            %Record absolute and relative stimulus start time
            stimulusInfo.stimuli(idx).startTime = toc;
            stimulusInfo.stimuli(idx).type='Drift';
            thisDirection = stimulusInfo.stimuli(idx).direction + 90;       %0, the first orientation, corresponds to movement towards the top of the screen
            for frameCount= 1:DG_DirectionFrames;
                %Define shifted srcRect that cuts out the properly shifted rectangular
                %area from the texture:
                xoffset = mod(frameCount*DG_ShiftPerFrame,DG_SpatialPeriod);
                srcRect=[xoffset 0 (xoffset + screenRect(3)*2) screenRect(4)*2];
                                
                %Draw grating texture, rotated by "angle":
                Screen('DrawTexture', window, gratingtex, srcRect, [], thisDirection);
                
                %overdraw the alpha mask
                Screen('DrawTexture', window, masktex(stimulusInfo.stimuli(idx).patch), [], [], 90);
                
                if photoDiodeRect(2) 
                    if d==1
                        Screen('FillRect', window, 255,photoDiodeRect )
                    else
                        Screen('FillRect', window, 0, photoDiodeRect)
                    end
                end

                %push to screen
                Screen('Flip',window);
                
                %Record measured stimulus display time
                stimulusInfo.stimuli((repeat-1)*directionsNum + d).endTime = toc;
            end
        end
        
        %Quit only if 'esc' or 'q' key was pressed
        [keyDn, ~, ~] = KbCheck;
        if keyDn
            [~, ~, keyCode] = KbCheck;
            a=find(keyCode);
            fprintf(num2str(a));
            if (a == 20) || (a == 41)
                qFlag=1;
                return
            end
        end
    end
    if qFlag==1
        return
    end
end
    
    %Display a black screen at the end
    Screen('FillRect', window, 0);
    Screen('Flip',window);
    
end