function [tm,varm]=blockavg(mtime,ti,tf,dt,var);
% Compute the block average for any time series
% 
% ti = begin time
% te = end time (matlab format)
% dt = desired time interval (days)
% var = choosen variable
%
%----------------------------------------------------
%ti=mtime(1); tf=mtime(end);
tm=ti:dt:tf; 
varm=NaN.*tm;
for i=1:numel(tm)-1; 
    id=find(mtime >= tm(i) & mtime < tm(i+1));
    varm(i)=nanmean(var(id));
end;
