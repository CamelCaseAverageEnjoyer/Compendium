%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [r, v, D] = kepler2rv(mu, p, e, Omega, w, inc, t_pi, t_cur, approx)
%kepler2rv returns position and velocity of the satellite using kepler
%elements
%   mu - gravitational parameter [m^3/s^2], 1x1
%   p - focal parameter [m], 1x1
%   e - excentricity
%   Omega - longitude of the ascending node
%   w - argument of the pericenter
%   inc - inclination
%   t_pi - pericenter time
%   t_cur - current time
%   approx - first approximation for Newton Method

if e < 1
    a = p/(1 - e^2);
    b = sqrt(a*p);
    M = sqrt(mu/a^3)*(t_cur - t_pi);
    misclosure = 1;
    D = approx;
    while misclosure > 1e-11
        D = (e*sin(D) - e*cos(D)*D + M)/(1 - e*cos(D));
%         D = D - (D - epsilon*sin(D) - M)/(1 - epsilon*cos(D));
        misclosure = abs(D - e*sin(D) - M);
    end
%     display(D - epsilon*sin(D) - M)
    r1 = [a*(cos(D) - e); b*sin(D); 0];
    cosTheta = (cos(D) - e)/(1 - e*cos(D));
    sinTheta = sqrt(1 - e^2)*sin(D)/(1 - e*cos(D));
    Vr = sqrt(mu/p)*e*sinTheta;
    Vn = sqrt(mu/p)*(1 + e*cosTheta);
    v1 = [Vr*cosTheta - Vn*sinTheta; Vr*sinTheta + Vn*cosTheta; 0];
else
    error('kepler2rv works only for elliptical orbits. Current orbit is nonelliptical (excentricity >= 1)')
end
A1 = [cos(Omega), sin(Omega), 0;...
     -sin(Omega), cos(Omega), 0;...
        0,        0,    1];
    
A2 = [1,      0,          0;...
      0,  cos(inc), sin(inc);...
      0, -sin(inc), cos(inc)];
  
A3 = [cos(w), sin(w), 0;...
     -sin(w), cos(w), 0;... 
           0,         0,      1];
       
B = (A1')*(A2')*(A3');

r = B*r1;
v = B*v1;
end

