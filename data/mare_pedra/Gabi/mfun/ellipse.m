function  [x,y] = ellipse(a,b,phi,x0,y0,color)
% ELLIPSE  Plotting ellipse.
%       ELLIPSE(A,B,PHI,X0,Y0,COLOR)  Plots ellipse with
%	semiaxes A, B, rotated by the angle PHI,
%	with origin at X0, Y0 and consisting of N points
%	(default 100).
%	[X,Y] = ELLIPSE(...) Instead of plotting returns
%	coordinates of the ellipse.

%  Copyright (c) 1995  by Kirill K. Pankratov
%	kirill@plume.mit.edu
%	03/21/95

%n_dflt = 100;   % Default for number of points
%th = linspace(0,2*pi,n+1);

% Added by felipe
npoints = 100;   % Default for number of points
th = linspace(0,2*pi,npoints);

x = a*cos(th);
y = b*sin(th);

c = cos(phi);
s = sin(phi);

th = x*c-y*s+x0;
y = x*s+y*c+y0;
x = th;

if nargout==0, plot(x,y,color); end


