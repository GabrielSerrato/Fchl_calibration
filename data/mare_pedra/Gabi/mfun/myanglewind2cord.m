%calcula angulo vento

function [X,Y]=myanglewind2cord(I,D)

X=[];
Y=[];

for i=1:length(I);
    
    ii=I(i);
    dd=D(i);
%     
%       ii=wind(i);
%       dd=dir(i);


if dd>=0 & dd<90;% 1 Quadrante

    dd=90-dd;
    
    xx=-cosd(dd)*ii;
    yy=-sind(dd)*ii;
    
    X=[X;xx];
    Y=[Y;yy];
elseif dd>=90 & dd<180; %2 Quadrante
    
%         dd=90-dd;
        dd=360-dd;

    
    yy=-cosd(dd)*ii;
    xx=sind(dd)*ii;
    
    X=[X;xx];
    Y=[Y;yy];
    
    
elseif dd>=180 & dd<270; %3 Quadrante
 dd=(270-dd)+180;
    yy=-cosd(dd)*ii;
    xx=-sind(dd)*ii;
    
    X=[X;xx];
    Y=[Y;yy];
    
else dd>=270 & dd<380; % 4 quadrante
    
    dd=(360-dd)+90;
 
    yy=-cosd(dd)*ii;
    xx=-sind(dd)*ii;
    
    X=[X;xx];
    Y=[Y;yy];
    
end

end
end
