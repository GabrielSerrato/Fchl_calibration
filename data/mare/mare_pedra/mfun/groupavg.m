function [tm,varm]=groupavg(mtime,dt,var);
% Compute the block average for any time series
% 
% ti = begin time
% te = end time (matlab format)
% dt = desired time interval (days)
% var = choosen variable
%
%----------------------------------------------------
%ti=mtime(1); tf=mtime(end);
i2=find(diff(mtime)> dt);
i1=i2+1;
i1=i1(1:end-1); 
i2=i2(2:end);
 
for i=1:numel(i1); 
    id=find(mtime >= mtime(i1(i)) & mtime < mtime(i2(i)));
    tm(i)=nanmean(mtime(id));
    varm(i)=nanmean(var(id));
end
