function MOut=convertGreyscaleSpotState(MIn)
%Converts a matrix containing greyscale(0, 127, 255) to
%spot states (-1=black, 0=grey, 1=white)

MOut=MIn;
MOut(MIn==255)=1;
MOut(MIn==127)=0;
MOut(MIn==0)=-1;