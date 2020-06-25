function [MDate_Hmax,MDate_Lmax,Hfchl_max,Lfchl_max] = tidal_maxima_fchl(FChl,MDate,Tide)
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

i=1:length(Tide)-3; 
I=find (Tide((i))>0 & Tide((i+1))<0 & Tide((i+2))<0 & Tide((i+3))<0); %find high tide occurrences by change of sign in velocity from positive to negative
K=find (Tide((i))<0 & Tide((i+1))>0 & Tide((i+2))>0 & Tide((i+3))>0); %find low tide occurrences by change of sign in velocity from negative to positive

MDate_Hmax=MDate(I); %array of high tide times
MDate_Lmax=MDate(K); %array of low tide times
Hfchl_max=FChl(I); %array of high tide Fchl
Lfchl_max=FChl(K); %array of low tide Fchl


end

