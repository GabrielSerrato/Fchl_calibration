function dvp(uu,vv,dt)
%dt = delta T, intervalo de amostragem.
%dt deve ser transformado em segundos:
u=uu;
v=vv;

dt = dt;          %para dt originalmente em minutos.

np=max(size(u)); 
plot(0,0)
clf
hold

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
dessoma=0;

%k=1;

x(2)=0;
y(2)=0;

cntemp=0;
for i=1:np;
    x(1)=x(2);
    y(1)=y(2);
    x(2)=u(i)*dt/10^5 + x(1);
    y(2)=v(i)*dt/10^5 + y(1);
    plot(x,y,'b')
    
    % Faz uma marca a cada 24horas
    cntemp=cntemp+1;
    if cntemp == (24*3600/dt)
        plot(x(2),y(2),'or')
        plot(x(2),y(2),'+r')
        cntemp=0;
    end
    
    %Calcula a distância total percorrida
    desloca(i)=sqrt((u(i)*dt/10^3)^2 + (v(i)*dt/10^3)^2)+ dessoma;
    dessoma=desloca(i);
end

axis('equal')
xlabel('Distância [km], Oeste-Leste','FontSize',11)
ylabel('Distância [km], Sul-Norte','FontSize',11)
title('Diagrama Vetorial Progressivo da Corrente, [+] início e [o] a cada 24h','FontSize',12)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% ORIGEM %
tam=.025*max(abs(desloca));
x(1)=0;
y(1)=0-tam;
x(2)=0;
y(2)=0+tam;
plot(x,y,'k')

x(1)=0-tam;
y(1)=0;
x(2)=0+tam;
y(2)=0;
plot(x,y,'k')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
hold

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Y=desloca;

