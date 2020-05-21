%calcula angulo vento

function [I,D]=mycordcurr2angle(x,y)
D=[];
I=[];

for i=1:length(x);
    
    ux=x(i);
    uy=y(i);

II=sqrt((ux).^2+(uy).^2);
I=[I;II];

if ux>0 & uy>0;% 1 Quadrante
    [teta]=angle1(ux,uy);
    d=90-teta;
    D=[D;d];
    
elseif ux<0 & uy>0; %2 Quadrante
    [teta]=angle1(ux,uy);
    d=270+(180-teta);
    D=[D;d];
    
elseif ux<0 & uy<0; %3 Quadrante
    [teta]=angle1(ux,uy);
    d=180+(270-teta);
    D=[D;d];
    
else ux>0 & uy<0; % 4 quadrante
    [teta]=angle1(ux,uy);
    d=90+(360-teta);
    D=[D;d];
    
end

end
end




