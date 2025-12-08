%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function aol = rv2AoL(r, v)
% rv2AoL calculates argument of lattitude using r and v. They must be given
% in Inertial Frame (z axis along Earth rotation axis)
e3 = cross(r, v)/norm(cross(r, v)); % area integral
e1 = cross([0; 0; 1], e3)/norm(cross([0; 0; 1], e3)); % ascending node direction
e2 = cross(e3, e1);

aol = atan2(dot(e2, r), dot(e1, r));

end