%Created 01/02/2011 by Alex Brown; modified from the version provided by
%Bruno Pichler.

function m=GratingAlex(type,xpoints, ypoints, ang, spacF)

sz_x=numel(xpoints)-1;                  %How many points need to be generated in x
sz_y=numel(ypoints)-1;                  %Ditto for y
xpoints= -(sz_x/2):(sz_x/2);            %Define the points in x
ypoints= -(sz_y/2):(sz_y/2);            %And y
    [x,y]=meshgrid(xpoints,ypoints);    %Create the mesh
        angle=ang*pi/180;               %Convert to radians
        spacF=spacF*2*pi;
    a=cos(angle)*spacF;
    b=sin(angle)*spacF;
    if type
     m=square(a*x+b*y);
    else
        m=sin(a*x+b*y);
    end
end
