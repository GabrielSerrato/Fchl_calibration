%calcula angulo vento

function [I,D]=myangle(x,y)
D=[];
I=[];

for i=1:length(x);
    
    ux=x(i);
    uy=y(i);

II=sqrt((ux).^2+(uy).^2);
I=[I;II];

if ux>0 & uy>0;% 1 Q
    [teta]=angle2(ux,uy);
    d=teta;
    D=[D;d];
    
elseif ux<0 & uy>0; %2 Q
    [teta]=angle2(ux,uy);
    d=360-teta;
    D=[D;d];
    
elseif ux<0 & uy<0; %3 Q
    [teta]=angle2(ux,uy);
    d=360-teta;
    D=[D;d];
    
else ux>0 & uy<0;
    [teta]=angle2(ux,uy);
    d=teta;
    D=[D;d];
    
end

end
end









% vetu=[ux,0];
% vety=[0,uy];
% res=vetu+vety;
% ref=[0,1];
% 
% a=dot(res,ref,2);
% b=sqrt(res(1)^2+res(2)^2);
% c=sqrt(ref(1)^2+ref(2)^2);
% 
% 
% theta=acos(a/(b*c);


% V=u+v;%soma dos vetores
% t=[0,1];%vetor referência
% t=repmat(t,[dim(1) 1]);
% d=dot(V,t,2);%produto interno

% % V1=(V(:,1)).^2;
% % V2=(V(:,2)).^2;
% VV=sqrt((V(:,1).^2+V(:,2).^2));% módulo
% 
% tt=t(:,2);
% baixo=VV.*tt;
% 
% a=d./baixo;
% a=acos(a);
% angle=180.-a.*180./pi;




