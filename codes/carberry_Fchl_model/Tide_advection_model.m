% Tide_advection_model.m
% sample test data and code for estimating hourly chlorophyll fluorescence
% in the presence of tidal advection when daytime observations are impacted
% by non-photochemical quenching.
% For details on the method, see and cite Carberry, L., C. Roesler, and S. Drapeau. 2019.
% Correcting in situ chlorophyll fluorescence time series observations for non-photochemical 
% quenching and tidal variability reveals non-conservative phytoplankton variability in 
% coastal waters. Limnol. Oceanogr. Methods. DOI: 10.1002/lom3.10325  
% 
clear all 
close all

%load sample data set
load('sampledata.mat')
% time Fchl PAR U V
Mdate=Sample_Data(:,1);Fchl=Sample_Data(:,2);PAR=Sample_Data(:,3);U=Sample_Data(:,4);V=Sample_Data(:,5);
%plot the data set
figure(1),clf
ymin=[0 0 -400 -400];ymax=[10 2500 400 400];
ylab=(['F_{Chl} (mg/m^3)         ';'PAR (\mumol quanta/m^2/s)';'U (cm/s)                 ';'V (cm/s)                 '])
for i=1:4
    subplot(4,1,i),plot(Sample_Data(:,1),Sample_Data(:,i+1),'.k-')
    hold on
    plot([Sample_Data(1,1) Sample_Data(length(Sample_Data),1)],[0 0],'k-')
ylabel(ylab(i,:)),axis([Sample_Data(1,1) Sample_Data(length(Sample_Data)) ymin(1,i) ymax(1,i)])
datetick('x','keeplimits')
end
subplot(4,1,1),title('Input Data')

%Step 1. Rotate the currents from N-S and E-W to alongshore and cross-shore
%function [Valong_shore,Vacross_shore] = rotate_tide(nortide,eastide,inlet_angle)
%Rotate tidal velocity values in estuaries into alongshore and across shore components
%[Valong_shore,Vacross_shore] = rotate_tide(nortide,eastide,inlet_angle)
%Inputs:
%   nortide = North-South current velocity observations
%   eastide = East-West current velocity observation, concurrent with nortide
%   angle = the positive angle (in degrees) you determine from a map between North and the direction of your estuary
%Outputs:
%   Valong_shore = the parallel-to-shore velocity vectors
%   Vacross_shore = the perpendicular-to-shore velocity vectors 
[Valong,Vacross]=rotate_tide(V,U,30);


%Step 2. Find time of high and low tide from velocity
%function [MDate_Hmax,MDate_Lmax,Hfchl_max,Lfchl_max] = tidal_maxima_fchl(FChl,MDate,Tide)
%Find tidal maxima using current velocity data
% [MDate_Hmax,MDate_Lmax,Hfchl_max,Lfchl_max] = tidal_maxima_fchl(FChl,MDate,Tide)
% Inputs
%     Fchl = raw chlorophyll fluorescence values 
%     MDate = matlab date vectors concurrent with Fchl observations
%     Tide = rotated alongshore current velocity observations concurrent
% Outputs
%     MDate_Hmax = mdate vector at all high tide occurrences 
%     MDate_Lmax = mdate vector at all low tide occurrences 
%     Hfchl_max = Fchl values at high tide occurrences 
%     Lfchl_max = Fchl values at low tide occurrences 

[MDate_Hmax,MDate_Lmax,Hfchl_max,Lfchl_max] = tidal_maxima_fchl(Fchl,Mdate,Valong);

% Step 3. Interpolate to obtain daytime high and low tide endmembers,
% interpolate the high tide and low tide time hourly series
%function [MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,MDate_Hendi,MDate_Lendi,F,G,X,W] = tidal_endmember_fchl(MDate_Hmax,MDate_Lmax,MDate,FChl,varargin)
%Correct for gaps in the current velocity data and interpolate tidal Fchl endmembers to hourly resolution
% OPTIONAL INPUT: [MDate_Hend,MDate_Lend,Hfchlend,Lfchlend] = tidal_endmember_fchl(MDate_Hmax,MDate_Lmax,MDate,FChl,PAR,PARthreshold)
% Inputs - produced by     tidal_maxima_fchl
%     MDate_Hmax = mdate vector at all high tide occurrences 
%     MDate_Lmax = mdate vector at all low tide occurrences 
%     MDate = mdate vector concurrent with Fchl observations
%     Fchl = raw chlorophyll fluorescence values 
% Optional inputs - enter these to remove quenched Fchl values according to PAR
%     PAR = Photosynthetically active radiation observations concurrent with raw Fchl values
%     PARthreshold = enter the max PAR threshold in umol q m^-2 s^-1 above which quenching occurs
% Outputs
%     MDate_Hend = mdate for at all high tide occurrences, accounting for
%     gaps in the current data
%     MDate_Lend = same, for low tide
%     Hfchlend = fchl at high tide maxima, concurrent with MDate_Hend 
%     Lfchlend = fchl at low tide maxima, concurrent with MDate_Lend 
[MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,MDate_Hendi,MDate_Lendi,F,G,X,W] = tidal_endmember_fchl(MDate_Hmax,MDate_Lmax,Mdate,Fchl,0);

%Step 4. Fit the cosinusoidal model to the hourly high and low tide Fchl envelopes
%function [intfchl,intdate] = tidal_hourlycosine_fchl(MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,MDate)
%Interpolate tidal endmembers to hourly Fchl using cosine
% [interpfchl] = tidal_hourlycosine_fchl(MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,MDate)
% Inputs
%     MDate_Hend = mdate for all high tide occurrences, accounting for
%     gaps in the current velocity data
%     MDate_Lend = same, for low tide
%     Hfchlend = fchl concurrent with MDate_Hend (at high tide maxima)
%     Lfchlend = fchl concurrent with MDate_Lend (at low tide maxima)
%     MDate = mdate vectors at the desired resolution (suggest hourly) of
%     the interpolated fchl output

%     Note:
%           if PAR was entered in tidal_endmember_fchl, then Hfchlend and Lfchlend will be unquenched 
%           and linearly interpolated along the respective high and low tide endmember 
% Outputs
%     intdate = mdate array for hourly sine interpolation between high and low endmembers
%     intfchl = hourly sine interpolated Fchl observations
[intfchl,intdate] = tidal_hourlycosine_fchl(MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,Mdate);

Gdate=datevec(Mdate);
Hdawn=6;Hdusk=18;%input hours of dawn and dusk for the local time series
I=find(Gdate(:,4)<=Hdawn|Gdate(:,4)>=Hdusk);%Identify local nighttime values
%plot model outputs
figure(2),clf
subplot(4,1,1),plot(Mdate,Fchl,'.k','MarkerEdgeColor',[.5 .5 .5]),datetick('x')
hold on
plot(Mdate(I,1),Fchl(I,1),'.k')
title('Model Output')
text(datenum(2017,6,15),14,'A','FontSize',12),legend('Daytime','Nighttime'),ylabel('F_{Chl} (mg/m^{-3})')

subplot(4,1,2),plot(Mdate,Fchl,'.k','MarkerEdgeColor',[.5 .5 .5]),datetick('x'),ylabel('F_{Chl} (mg/m^{-3})')
hold on
plot(Mdate(I,1),Fchl(I,1),'.k')
plot(MDate_Hmax,Hfchl_max,'.b',MDate_Lmax,Lfchl_max,'.r'),datetick('x')
text(datenum(2017,6,15),14,'B','FontSize',12),legend('Daytime','Nighttime','High tide','Low tide')

subplot(4,1,3),plot(Mdate(I,1),Fchl(I,1),'.k'),ylabel('F_{Chl} (mg/m^{-3})')
hold on
plot(MDate_Hend,Hfchlend,'.b',MDate_Lend,Lfchlend,'.r'),datetick('x')
text(datenum(2017,6,15),14,'C','FontSize',12),legend('Nighttime observations','Nighttime High tide','Nighttime Low tide')

subplot(4,1,4)
plot(Mdate(I,1),Fchl(I,1),'.k')
hold on
plot(MDate_Hend,Hfchlend,'.b',MDate_Lend,Lfchlend,'.r'),datetick('x')
plot(intdate,intfchl,'k-'),datetick('x'),ylabel('F_{Chl} (mg/m^{-3})')
text(datenum(2017,6,15),14,'D','FontSize',12),legend('Nighttime observations','Nighttime High tide','Nighttime Low tide','Tidal interpolation')

