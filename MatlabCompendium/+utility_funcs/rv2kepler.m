%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [p, e, inc, Omega, w, nu] = rv2kepler(r, v, mu)
%RV2KEPLER calculates kepler elements using satellite radius-vector and
%velocity
%   r -- satellite radius-vector in GCRF [m] (3x1)
%   v -- satellite velocity in GCRF [m/s] (3x1)
%   mu -- gravitational parameter [m^3/s^2] (1x1)
if ~isequal(size(r), [3, 1])
    error('Input radius vector must be 3x1')
end

if ~isequal(size(v), [3, 1])
    error('Input velocity  must be 3x1')
end

if ~isequal(size(mu), [1, 1])
    error('Input gravity parameter must be 1x1')
end

c = cross(r, v);
n = c/norm(c);
f = cross(v, c) - mu*r/norm(r);
e3 = [0; 0; 1];
e1 = [1; 0; 0];
e2 = [0; 1; 0];
inc = acos(dot(n, e3));
node_line = cross(e3, n)/norm(cross(e3, n));
e2_orbital = cross(n, node_line)/norm(cross(n, node_line));
Omega = atan2(dot(e2, node_line), dot(e1, node_line));
w = atan2(dot(e2_orbital, f), dot(node_line, f));
p = norm(c)^2/mu;
e = norm(f)/mu;

e1_canonical = f/norm(f);
e2_canonical = cross(n, e1_canonical);
nu = atan2(dot(r, e2_canonical), dot(r, e1_canonical));
end

