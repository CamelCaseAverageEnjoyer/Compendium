function [GMST] = getGMST(t_jd)
%GETGMST calculates Greenwich siderial time (in radians)
%   t_jd -- julian date
t_jd_from_J2000 = (t_jd - 2451545.0); % days from J2000
T = t_jd_from_J2000/36525; % centuries from J2000
GMST = mod(67310.54841 + (876600*3600 + 8640184.812866)*T ... 
                  + 0.093104*T^2, 86400)/240*pi/180;
end

