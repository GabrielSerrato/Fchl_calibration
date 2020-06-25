function DtN = dateround(DVN,Uni,RFC)
% Round Date Vectors or Serial Date Numbers to the chosen unit. Round/Floor/Ceiling.
%
% (c) 2015 Stephen Cobeldick
%
% Round Serial Date Numbers or Date Vectors to the nearest chosen unit, i.e.
% to the nearest year, month, day, hour, minute, or second. Accepts multiple
% date values, returns Serial Date Numbers. Choice of rounding, floor or ceiling.
%
% Syntax:
%  DtN = dateround              % Round the current time to the nearest second.
%  DtN = dateround(DVN)         % Round <DVN> to the nearest second.
%  DtN = dateround(DVN,Uni)     % Round <DVN> to the chosen unit.
%  DtN = dateround(DVN,Uni,RFC) % Round/floor/ceiling <DVN> to the chosen unit.
%
% See also ROUND CLOCK NOW DATENUM8601 DATESTR8601 ROUND60063 DATENUM DATEVEC DATESTR
%
% Note 1: Calls undocumented MATLAB functions "datevecmx" and "datenummx".
% Note 2: Provides a precision of ca. 0.0001 seconds, from year 0000 to 5741.
%
% ### Examples ###
%
% Examples use the date+time described by the vector [1999,1,3,15,6,48.0568].
%
% datevec(dateround(730123.62972287962))
%             ans = [1999,1,3,15,6,48]
%
% datevec(dateround([1999,1,3,15,6,48.0568]))
%             ans = [1999,1,3,15,6,48]
%
% datevec(dateround([1999,1,3,15,6,48.0568],'minute'))
%             ans = [1999,1,3,15,7,0]
%
% datevec(dateround([1999,1,3,15,6,48.0568],5)) % 5=='minute'
%             ans = [1999,1,3,15,7,0]
%
% datevec(dateround([1999,1,3,15,6,48.0568],5,'floor'))
%             ans = [1999,1,3,15,6,0]
%
% datevec(dateround([1999,12,31,23,59,59.5000;1999,12,31,23,59,59.4999]))
%             ans = [2000, 1, 1, 0, 0, 0;     1999,12,31,23,59,59]
%
% ### Input & Output Arguments ###
%
% Inputs (*=default):
%  DVN = Date Vector, one single date vector (OR matrix of Date Vectors).
%      = Serial Date Number, scalar numeric (OR column vector of Serial Date Numbers).
%      = []*, use the current time.
%  Uni = Numeric scalar, 1/2/3/4/5/6* -> round to the year/month/day/hour/min/sec.
%      = String 'year'/'month'/'day'/'hour'/'minute'/'second' (case insensitive, plural also).
%      = String as per "datestr8601"/"datenum8601" tokens: 'y'/'m'/'d'/'H'/'M'/'S'.
%      = String as per MATLAB symbolic identifiers: 'yyyy'/'mm'/'dd'/'HH'/'MM'/'SS'.
%  RFC = String token to select the rounding method: *'round'/'floor'/'ceiling',
%        ('ceil' also accepted), or the initials 'r'/'f'/'c' (all are case insensitive).
%
% Output:
%  DtN = Serial Date Number, column vector, <DVN> rounded at the units given by <Uni>.
%
% DtN = dateround(DVN,Uni*,RFC*)

% ### Date Vector & Number ###
%
% Calculate date-vector/s:
if nargin==0||isempty(DVN) % Default = now
    DtV = clock;
elseif iscolumn(DVN)       % Serial Date Number/s
    DtV = datevecmx(DVN);
elseif ismatrix(DVN)       % Date Vector/s
    DtV = datevecmx(datenummx(DVN));
else
    error('First argument: invalid Date Vector or Date Number. Check array dimensions.')
end
% Calculate serial date-number/s:
DtN = datenummx(DtV);
%
% ### Unit Index ###
%
% Determine unit's index (1/2/3/4/5/6* = year/month/day/hour/min/sec):
if nargin<2 || isempty(Uni)
    Uni = 6; % *default = seconds.
elseif isnumeric(Uni) && isscalar(Uni) && isreal(Uni)
    assert(0<Uni&&Uni<7,'Second argument <Uni>: permitted range 1-6 inclusive')
    Uni = double(Uni);
elseif ischar(Uni) && isrow(Uni)
    Uni = DtRndStr(Uni);
else
    error('Second argument <Uni>: must be a numeric scalar or a string.')
end
%
% ### Check Trailing Values ###
%
% Separate milliseconds from seconds:
DtV(:,7) = rem(DtV(:,6),1);
DtV(:,6) = floor(DtV(:,6));
% Check if any trailing values are > default:
DtW = [0,1,1,0,0,0,0];
DtI = any(bsxfun(@gt,DtV(:,Uni+1:7),DtW(Uni+1:7)),2);
% Remove milliseconds:
DtV(:,7) = [];
%
% ### Floor & Ceiling ###
%
% floor:
DtV(:,Uni+1:6) = DtW(ones(1,numel(DtN)),Uni+1:6);
DtC(:,2) = datenummx(DtV);
% ceiling:
DtV(:,Uni) = DtV(:,Uni)+DtI;
DtC(:,1) = datenummx(DtV);
% DtC must be columnwise so that logical indexing gives correct output order.
%
% ### Select Output ###
%
if nargin<3
    RFC = 'round';
else
    assert(ischar(RFC)&&isrow(RFC),'Third argument <RFC> must be a string token.')
end
%
switch lower(RFC)
    case {'r','round'}
        DtL = 2*DtN < sum(DtC,2)-0.0000000002; % - Conversion precision
        DtN = DtC([~DtL,DtL]);
    case {'f','floor','fix'}
        DtN = DtC(:,2);
    case {'c','ceil','ceiling'}
        DtN = DtC(:,1);
    otherwise
        error('Third argument <RFC> is an unrecognised string token: ''%s''',RFC)
end
%
end
%----------------------------------------------------------------------END:dateround
function Uni = DtRndStr(Str)
% Convert a string unit argument to indices.
%
% Case insensitivity for the unit names:
if any(diff(double(Str)))
    Str = lower(Str);
end
%
switch Str % is the fastest way to select the index
    case {'S','SS','sec','secs','second','seconds'}
        Uni = 6;
    case {'M','MM','min','mins','minute','minutes'}
        Uni = 5;
    case {'H','HH','hour','hours'}
        Uni = 4;
    case {'d','dd','day','days'}
        Uni = 3;
    case {'m','mm','month','months'}
        Uni = 2;
    case {'y','yyyy','year','years'}
        Uni = 1;
    otherwise
        error('Second argument <Uni> is an unrecognized string token: ''%s''',Str)
end
%
end
%----------------------------------------------------------------------END:DtRndStr