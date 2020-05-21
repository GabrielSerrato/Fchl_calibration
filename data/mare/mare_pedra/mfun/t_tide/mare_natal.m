       load('D:\00.TCC\02.Dados\01.Maré\DHN\data\mat\2.mat')
       tt=mtime; ee=elev_cent;
       
       
       % Define inference parameters.
       %infername=['P1';'K2'];
       %inferfrom=['K1';'S2'];
       %infamp=[.33093;.27215];
       %infphase=[-7.07;-22.40];
       
       % The call (see t_demo code for details).
       %[tidestruc,pout]=t_tide(tuk_elev,...
       'interval',1, ...                     % hourly data
       'start',tt(1),...               % start time is datestr(tuk_time(1))
       'latitude',5.00,...               % Latitude of obs
       %'inference',infername,inferfrom,infamp,infphase,...
       %'shallow','M10',...                   % Add a shallow-water constituent 
       %'error','linear',...                   % coloured boostrap CI
       %'synthesis',1);                       % Use SNR=1 for synthesis. 
       %);

        % The call (see t_demo code for details).
       [tidestruc,ee_out]=t_tide(ee,'interval',1,'start',tt(1),'latitude',5.00);
       
       tt_prev=datenum(2011,01,01,00,00,00):(1/24):datenum(2014,01,01,00,00,00);
       ee_prev=t_predic(tt_prev,tidestruc,'latitude',5.00,'synthesis',1);

clf;orient tall;
subplot(411);
plot(tt-tt(1),ee);
line(tt-tt(1),ee-ee_out,'linewi',2,'color','r');
xlabel('Days in 1959');
ylabel('Elevation (cm)');

subplot(412);
plot(ee_prev);

