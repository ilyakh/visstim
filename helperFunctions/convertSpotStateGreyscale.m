function MOut=convertSpotStateGreyscale(MIn)
%Converts a matrix containing spot states (-1=black, 0=grey, 1=white) to
%greyscale(0, 127, 255)

MOut=MIn;
MOut(MIn==1)=255;
MOut(MIn==0)=127;
MOut(MIn==-1)=0;