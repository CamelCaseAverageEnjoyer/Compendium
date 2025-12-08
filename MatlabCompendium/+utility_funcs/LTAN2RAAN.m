function [RAAN] = LTAN2RAAN(LTAN, t_jd)
%LTAN2RAAN claculates RAAN from LTAN. We suppose that LTAN is given in mean
%solar time! Also we neglect difference between J2000 and J of current
%date, so results are not totally accurate
%   LTAN -- [hours minutes seconds], 24 hours format
%   t_jd -- julian date when RAAN must be calculated
t_jd_from_J2000 = (t_jd - 2451545.0); % days from J2000
date = time_transformation.JD2date(t_jd);
GM_solar_time_angle = (date(4) + date(5)/60 + date(6)/3600)/12*pi; % /24*(2pi)

LTAN_angle = (LTAN(1) + LTAN(2)/60 + LTAN(3)/3600)/12*pi;
dlambda = LTAN_angle - GM_solar_time_angle;
theta = 2*pi*(0.7790572732640 + 1.00273781191135448 *t_jd_from_J2000); % current meridian siderial time

RAAN = mod(theta + dlambda, 2*pi);

end

