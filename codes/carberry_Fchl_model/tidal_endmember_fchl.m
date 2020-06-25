function [MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,MDate_Hendi,MDate_Lendi,F,G,X,W] = tidal_endmember_fchl(MDate_Hmax,MDate_Lmax,MDate,FChl,varargin)
%Correct for gaps in the current velocity data and interpolate tidal Fchl endmembers to hourly resolution
% 
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

%comment one of these to change the maxima-maxima tidal time
tidalperiod=datenum([0,0,0,12,24,2.88]); %for semidiurnal tidal cycles
% tidalperiod=datenum([0,0,0,24,48,5.76]); %for diurnal tidal cycles 

%this for loop fills in missing high tide occurrences in patchy velocity
%data by interpolating according to the predominant tidal cycle
n=1;
MDate_Hend(1,:)=MDate_Hmax(1,:); %create the new high tide endmember vector
for i=2:length(MDate_Hmax) 
    
    D=MDate_Hmax(i)-MDate_Hmax(i-1); %finding the time to the next measured high tide
    N=D/tidalperiod; %dividing it by the known tidal maxima-maxima time
    if N>1.2 %if D is much greater, a high tide wasn't measured by the current velocity and should be interpolated 
        for j=1:round(N)
            n=n+1;
            MDate_Hend(n,:)=MDate_Hend(n-1,:)+tidalperiod;
        end
    elseif N<1.2 %if D is the same or less than the tidal period, the high tide was measured
        n=n+1;
        MDate_Hend(n,:)=MDate_Hmax(i,:);
    end%if
end%i loop

%this loop does the same for low tide 
n=1;
MDate_Lend(1,:)=MDate_Lmax(1,:);
for i=2:length(MDate_Lmax)
    
    D=MDate_Lmax(i)-MDate_Lmax(i-1);
    N=D/tidalperiod;
    if N>1.2
        for j=1:round(N)
            n=n+1;
            MDate_Lend(n,:)=MDate_Lend(n-1,:)+tidalperiod;
        end
    elseif N<1.2
        n=n+1;
        MDate_Lend(n,:)=MDate_Lmax(i,:);
    end%if
end%i loop

%this loop matches interpolated endmember high tide times to the MDate
%array that corresponds to Fchl measurements
%this section of the code requires dateround, written by Stephen Cobeldick
%https://www.mathworks.com/matlabcentral/fileexchange/39274-round-serial-date-numbers-or-date-vectors
n=1;
for i=1:length(MDate_Hend)
    I=find(dateround(MDate_Hend(i,:),'hour')==MDate); %find where daterounded high tide times are found in the original datenum array
    if I>0
        X(n,:)=I; 
        MDate_Hendi(n,1)=MDate_Hend(i,:); %create a new endmember high tide array matching the original datenum times
        n=n+1;
    else
        continue
    end
end

%this loop does the same for low tide
n=1;
for i=1:length(MDate_Lend)
    I=find(dateround(MDate_Lend(i,:),'hour')==MDate);
    if I>0
        W(n,:)=I;
        MDate_Lendi(n,1)=MDate_Lend(i,:);
        n=n+1;
    else
        continue
    end
end

if length(varargin)>1
PAR=varargin{1};
PARthreshold=varargin{2}; 
F=find(PAR(X)<PARthreshold); %find PAR values for high tide array below quenching threshold
G=find(PAR(W)<PARthreshold); %find PAR values for low tide array below quenching threshold
else
    GDate=datevec(MDate); %if PAR is not given and PAR threshold not defined, then unquenched values are selected by hour of day
    F=find(GDate(X,4)>18|GDate(X,4)<6); %high tide
    G=find(GDate(W,4)>18|GDate(W,4)<6); %low tide
end

% uncomment the below three lines to remove quenched Fchl values according to time of day, instead of PAR. Change the hours if necessary


Hfchlend=interp1(MDate_Hendi((F),:),FChl(X(F),:),MDate_Hend); % interpolating unquenched, high tide FChl to modelled high tide chlorophyll
Lfchlend=interp1(MDate_Lendi((G),:),FChl(W(G),:),MDate_Lend); % interpolating unquenched, low tide FChl to modelled low tide chlorophyll


end

