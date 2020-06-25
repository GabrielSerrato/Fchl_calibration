function [intfchl,intdate] = tidal_hourlycosine_fchl(MDate_Hend,MDate_Lend,Hfchlend,Lfchlend,MDate)
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

%this portion of code sorts out any differences in the length of the high
%tide and low tide arrays and puts them into one array
L=length(Lfchlend);
H=length(Hfchlend);
dif=abs(L-H); %getting the difference between the length of the high tide and low tide maxima endmember array 
add(1:dif,1)=[NaN]; %make a NAN array that lenth
if L>H 
Hfchlend_ext=[Hfchlend;add]; %if there are more low tides, add the difference to the high tide array
combinedfchl=[Lfchlend';Hfchlend_ext'];
MDate_Hend_ext=[MDate_Hend;add];
combineddate=[MDate_Lend';MDate_Hend_ext'];
elseif H>L
Lfchlend_ext=[Lfchlend;add]; %likewise, if there are more high tides
combinedfchl=[Hfchlend';Lfchlend_ext'];
MDate_Lend_ext=[MDate_Lend;add];
combineddate=[MDate_Hend';MDate_Lend_ext'];
end
combinedfchl=combinedfchl(:); %turn the fchl tidal velocity maxima into one array
combinedfchl=combinedfchl(1:length(combinedfchl)-1,1);
combineddate=combineddate(:); %turn the mdate times high and low tide into one array
combineddate=combineddate(1:length(combineddate)-1,1);

%this section of code prepares a cell array
clear mdate_comb
for i=1:length(combineddate)-1
mdate_comb{i}=combineddate(i):datenum([0 0 0 1 0 0]):combineddate(i+1); %creating a cell array of hourly time vectors between one high or low and the next
mdate_combsz(i,:) = size(mdate_comb{i}); % getting the size of each vector
end
Colmax = max(mdate_combsz(:,2));                             % maximum number of columns
mdate_combtx = NaN(i,Colmax); % preallocate two matrices, rows: number of tidal maxima rows, columns: max number of hours in between tidal maxima
interpfchl=NaN(i,Colmax);
for k1 = 1:i
    mdate_combtx(k1,1:mdate_combsz(k1,2)) = mdate_comb{k1}; % fill the preallocated mdate matrix with the above interpolated mdate times
end

for i=1:length(combinedfchl)-1
    A=(1/2)*(combinedfchl(i+1)-combinedfchl(i)); %getting the amplitude of one high or low tide to the next high or low
    midpoint=(combinedfchl(i+1)+combinedfchl(i))/2; %getting the midpoint
    m=length(mdate_combtx(i,~isnan(mdate_combtx(i,:)))); %find the size of this tidal maxima-tidal maxima interval 
    for j=1:length(mdate_combtx(i,~isnan(mdate_combtx(i,:)))) %for that size, in other words, calculated piecewise 
        interpfchl(i,j)=-A.*cos(((mdate_combtx(i,j)-mdate_combtx(i,1))/(mdate_combtx(i,m)-mdate_combtx(i,1)))*pi)+midpoint; %equation 2 from Carberry et al. 2019
    end
end

intfchl=interpfchl'; %transpose and arrange the fchl in one column
intfchl=intfchl(:);

intdate=mdate_combtx'; %likewise for the mdate matrix
intdate=intdate(:);

x=[intdate,intfchl]; %denan them to get the finished product
dex=denan(x); 
intdate=dex(:,1);
intfchl=dex(:,2);

end



