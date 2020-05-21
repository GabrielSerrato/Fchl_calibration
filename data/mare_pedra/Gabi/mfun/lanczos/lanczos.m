function [time_filt,data_filt]= lanczos(time, data, IWW,TCO, type)

% USE: [time_filt,data_filt]= lanczos(time, data, IWW,TCO, type)
%
% INPUT VARIABLES:
%
% TIME - Matlab Julian time
% DATA - Data to be filtered
% IWW  - Window Width expressed in points (must be odd)
% TCO  - CUTOFF period expressed in (hours)
% TYPE - What type of lowpass to perform (OPTIONAL)
%        Default: LP (Lowpass)
%        Options: LL (Low Low Pass)
%                 HP (Hight Pass)
%                 BP (Band Pass)
%
% RETURNS:
% time_filt - time (filter length)??
% data_filt - filtered data
%        data_filt(1,:) = LP
%        data_filt(2,:) = LL (optional)
%	 data_filt(3,:) = HP (optional)
%        data_filt(4,:) = BP (optional)
%
% Translated from FORTRAN 77 code written by kuo Wong in 1976
% by Masha Medvedeva
% University of Delaware
% October 2001

if nargin<4
  error('Not Enough Input Arguments!');
  error('USAGE: [time_filt,data_filt]=lanczos(time, data, IWW,TCO, type)');
elseif nargin==4
  type='LP';
end

% check the shape of a matrix
sz=size(data);
if (sz(1) > sz(2))
     data=data';
end
clear sz

% Check if IWW is odd
if(fix(IWW/2)*2 == IWW)
 error ('Window Width Must Be Odd');
end

% Calculate sampling interval, convert into hours
DT=(time(2)-time(1))*24;

if (DT < .01)
   error('Data sampling interval less than 1 minute');
end


omega=(2*pi)/TCO*DT;% left associativity DT multiplied by 2pi/TCO
H0=omega/pi; % Center Filter
con=(2*pi)/IWW;


% Compute Window Weights
SUM=H0;
NS=1:((IWW-1)/2);% index from min to max
H(NS)=H0*(sin(NS*omega)./(NS*omega)).*(sin(NS*con)./(NS*con));
SUM=H0+sum(2*H);

% Normalize each weight by the sum of all weights
H0=H0/SUM;
H=H/SUM;

% Filter itself. Easier to do loops than figure out indeces
for i=max(NS)+1:length(data)-max(NS);
  TEMP=H0*data(i);
  for j=1:max(NS)
     TEMP=TEMP+H(j)*(data(i-j)+data(i+j));
  end
  data_filt(i-max(NS))=TEMP;
  time_filt(i-max(NS))=time(i);
end

if(strcmp(type,'LL'))
   %return LL from filter
   elseif (strcmp(type,'HP'))
% subtract lowpass from original (which is longer)
   elseif(strcmp(type,'BP'))
% subtract LLP from LP
end

