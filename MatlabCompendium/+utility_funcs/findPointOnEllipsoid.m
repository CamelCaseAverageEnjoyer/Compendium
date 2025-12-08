function [point] = findPointOnEllipsoid(major_sa, minor_sa, r_sat, e_sat)
%FINDPOINTONELLIPSOID finds the point at which the satellite is looking at
%the moment. Ellipsoid is supposed to be symmetrical along the OZ axis
%   major_sa -- major semiaxis 
%   b -- minor semiaxis
%   r_sat -- current satellite position 
%   e_sat -- current camera axis
e_sat = e_sat/norm(e_sat);
a = (e_sat(1)^2 + e_sat(2)^2)/major_sa^2 + e_sat(3)^2/minor_sa^2;
b = (r_sat(1)*e_sat(1) + r_sat(2)*e_sat(2))/major_sa^2 + r_sat(3)*e_sat(3)/minor_sa^2;
c = (r_sat(1)^2 + r_sat(2)^2)/major_sa^2 + r_sat(3)^2/minor_sa^2 - 1;

diskr = b^2 - a*c;
if diskr < 0
    point = [nan; nan; nan];
elseif diskr == 0
    t = b^2/a;
    if t < 0
        point = [nan; nan; nan];
    else
        point = r_sat + e_sat*t;
    end
else
    t1 = (-b - sqrt(diskr))/a;
    t2 = (-b + sqrt(diskr))/a;
    if t1 < 0 && t2 < 0
        point = [nan; nan; nan];
    elseif t1 < 0
        warning('satellite is inside the ellipsoid. Something is wrong');
        point = r_sat + e_sat*t2;
    else
        point = r_sat + e_sat*min(t1, t2);
    end
end

