%Created 01/02/2011 by Alex Brown; modified from the version provided by
%Bruno Pichler.

% Adapted 30/7/2013 by AB to generate multiple spatial frequency gratings

function m=GratingAlex(type,xpoints, ypoints, ang, spacF)
m=zeros(length(ypoints),length(xpoints), length(spacF));
for ii=1:length(spacF)
    
    sz_x=numel(xpoints)-1;                  %How many points need to be generated in x
    sz_y=numel(ypoints)-1;                  %Ditto for y
    xpoints= -(sz_x/2):(sz_x/2);            %Define the points in x
    ypoints= -(sz_y/2):(sz_y/2);            %And y
    [x,y]=meshgrid(xpoints,ypoints);    %Create the mesh
    angle=ang*pi/180;               %Convert to radians
    spacFD=spacF(ii)*2*pi;
    a=cos(angle)*spacFD;
    b=sin(angle)*spacFD;
    if type
        m(:,:,ii)=square(a*x+b*y);
    else
        m(:,:,ii)=sin(a*x+b*y);
    end
end
end
