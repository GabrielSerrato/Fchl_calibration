function [Valong_shore,Vacross_shore] = rotate_tide(nortide,eastide,inlet_angle)
%Rotate tidal velocity values in estuaries into alongshore and across shore components
%[Valong_shore,Vacross_shore] = rotate_tide(nortide,eastide,inlet_angle)
%Inputs:
%   nortide = North-South current velocity observations
%   eastide = East-West current velocity observation, concurrent with
%   nortide
%   angle = the positive angle (in degrees) you determine from a map between North and the direction of your estuary
%Outputs:
%   Valong_shore = the parallel-to-shore velocity vectors
%   Vacross_shore = the perpendicular-to-shore velocity vectors 

Deg=(180/pi)*atan(eastide./nortide); %
Rad=Deg*(pi/180); %convert to radians
Theta_T = inlet_angle*(pi/180); %define the angle between due N and the along sound direction
Theta_rot = Theta_T-Rad; %define the angle between observed flow and the rotated along sound axis
UV=[eastide';nortide']; %make an array of the E and N velocities in columns 1 and 2

rota = [cosd(inlet_angle) -sind(inlet_angle); sind(inlet_angle) cosd(inlet_angle)];
UVr = rota*UV;%rotated along axis and cross axis velocities in col 1 and 2
Vacross_shore=UVr(1,:);%velocity across
Valong_shore=UVr(2,:);%velocity along

end

