function stimulusStack=createSparseNoiseStimulusImageStack(s)
border=s.spotSizeMean+s.spotSizeRange;
stimulusStack=zeros(s.screenRect(3)+border, s.screenRect(4)+border, s.nStimFrames, 'int8');
[xx yy] = meshgrid(1:size(stimulusStack,1), 1:size(stimulusStack, 2));

for sf=1:s.nStimFrames
    for spot=1:size(s.stimuliSp{sf}, 1)
        r=s.stimuliSp{sf}(spot, :);
        xC=mean([r(1) r(3)]); yC=mean([r(2) r(4)]);
        C = sqrt((xx-xC).^2+(yy-yC).^2)<=(s.spotSizes{sf}(spot)/2);
        spotCol=(s.spotColors{sf}(1, spot)-0.5)*2;
        stimulusStack(:,:, sf)=stimulusStack(:,:, sf)+int8(spotCol*C');
    end
end


