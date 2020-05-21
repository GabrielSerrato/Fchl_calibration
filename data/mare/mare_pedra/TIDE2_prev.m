load ('data\raw_tide.mat');

tt=mtime; ee=elev_norm;
       
       
       % Define inference parameters.
       %infername=['P1';'K2'];
       %inferfrom=['K1';'S2'];
       %infamp=[.33093;.27215];
       %infphase=[-7.07;-22.40];
       
       % The call (see t_demo code for details).
       %[tidestruc,pout]=t_tide(tuk_elev,...
       'interval',1, ...                     % hourly data
       'start',tt(1),...               % start time is datestr(tuk_time(1))
       'latitude',27.00,...               % Latitude of obs
       %'inference',infername,inferfrom,infamp,infphase,...
       %'shallow','M10',...                   % Add a shallow-water constituent 
       %'error','linear',...                   % coloured boostrap CI
       %'synthesis',1);                       % Use SNR=1 for synthesis. 
       %);

        % The call (see t_demo code for details).
       [tidestruc,ee_out]=t_tide(ee,'interval',1,'start',tt(1),'latitude',27.00);
       mtime_prev=datenum(2017,01,01,00,00,00):(1/24):datenum(2019,12,31,00,00,00);
       elev_prev=t_predic(mtime_prev,tidestruc,'latitude',27.00,'synthesis',1);

eval (['save ','data/','forecast_tide.mat ', 'mtime elev elev_norm mtime_prev elev_prev']);





