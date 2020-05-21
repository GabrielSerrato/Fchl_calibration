  function [kr]=corrlag(x,y, maxlag)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% This routine runs linear regression with a specified lag.
% Usage:  [kr]=linregr_lagged(x,y, maxlag)
%     where   kr is the correlation array of the size maxlag+1
%             x and y are the same size
%             maxlag is the specified maximum lag
%  first lag is zero
% Need: linregr.m
% Masha M. Nov 6 2002
% x lags y by lag up to maxlag and  ylags x by the same
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%  1st do the zero lag case;

 [k0]=corrcoef(x,y); 
 maxlength=length(x);
 for jj=1:maxlag
 	n=maxlag-jj+1;
 	
 % This reverses the order of the coefficients for xlagging with the largest 
 % lag first, least 
 %last just before the zero lag entry. Then, ylagging starts with increasing 
 % lag by the index
 
   [kxlag(n)]=corrcoef(x(jj+1:maxlength),...
   y(1:maxlength-jj)); 
 end
 
 for kk=1:maxlag
 	
 	[kylag(kk)]=corrcoef...
 	(x(1:maxlength-kk),y(kk+1:maxlength));
 end 
 
 
 
 kr=cat(2,kxlag,k0,kylag);
 

 
 