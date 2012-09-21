function stimulusInfo=generateSparseStimuli(q, stimulusInfo)

stimulusInfo.stimuliSp=zeros(q.screenRect(3), q.screenRect(4), q.nStimFrames);
stimulusInfo.spotSizes=cell(q.nStimFrames, 1);
prevSpots=[];
for i=1:q.nStimFrames
    nSpots=round(q.spotNumberMean+q.spotNumberStd*randn(1));
    nSpots=max([nSpots 1]);                         %Prevent there being no or 'negative' numbers of spots
    stimulusInfo.spotSizes{i}=round(max(q.spotSizeMean+randn(nSpots, 1)*q.spotSizeStd, q.spotSizeMin));
    randomSpots=randperm(q.screenRect(3)*q.screenRect(4), nSpots);
    while sum(ismember(randomSpots, prevSpots))>0
        randomSpots=randperm(xLocations*yLocations, nSpots);
    end
    g=zeros(q.screenRect(3), q.screenRect(4));
    g(randomSpots)=(randi(2, nSpots, 1)-1)*2-1;
    stimulusInfo.stimuliSp(:, :, i)=g;
    prevSpots=randomSpots;
end
end