  function dvp(u,v,dt)
        
        dt = dt*60;          %para dt originalmente em minutos.
        np=max(size(u));
        plot(0,0)
        hold on
        
        dessoma=0;
        x(2)=0;
        y(2)=0;
        cntemp=0;
        
        for i=1:np ,
            x(1)=x(2);
            y(1)=y(2);
            x(2)=u(i)*dt/10^3 + x(1);
            y(2)=v(i)*dt/10^3 + y(1);
            plot(x,y,'b')
            
            % Faz uma marca a cada 24horas
            cntemp=cntemp+1;
            if cntemp == (24*3600/dt)
                plot(x(2),y(2),'or','markersize',5,'linewidth',1)
                plot(x(2),y(2),'+r','markersize',5,'linewidth',1)
                cntemp=0;
            end
            
            %Calcula a distância total percorrida
            desloca(i)=sqrt((u(i)*dt/10^5)^2 + (v(i)*dt/10^5)^2)+ dessoma;
            dessoma=desloca(i);
        end
        
        axis('equal')
        xlabel('Distância [km], Oeste-Leste','FontSize',6)
        ylabel('Distância [km], Sul-Norte','FontSize',6)
        set(gca,'YAxisLocation','right')
        title({'Diagrama Vetorial Progressivo da Corrente';'[+] início e [o] a cada 24h'},'FontSize',8)
        
        % ORIGEM %
        %         tam=.025*max(abs(desloca));
        tam=0.1*min(diff(get(gca,'xlim')),diff(get(gca,'ylim')));
        x(1)=0;
        y(1)=0-tam;
        x(2)=0;
        y(2)=0+tam;
        plot(x,y,'k','linewidth',1)
        
        x(1)=0-tam;
        y(1)=0;
        x(2)=0+tam;
        y(2)=0;
        plot(x,y,'k','linewidth',1)
        hold off
        
    end %plota diagrama vetorial progressivo
