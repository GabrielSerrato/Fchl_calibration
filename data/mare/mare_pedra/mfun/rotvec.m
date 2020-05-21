  function [ur,vr]=rotvec(u,v,theta)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% [ur,vr]=rotvec(u,v,theta) rotates a vector counterclockwise 
% theta degrees OR rotates the coordinate system clockwise 
% theta degrees. Example: rotvec(1,0,90) returns (0,1).            
%
% If 4 arguments, then it uses xa and ya as orientation
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Ver. 1: 11/17/96 (RG), FMP 07/08/14
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

a=theta/180*pi; % convert to radians

ur=u.*cos(a)-v.*sin(a);
vr=u.*sin(a)+v.*cos(a);
end
