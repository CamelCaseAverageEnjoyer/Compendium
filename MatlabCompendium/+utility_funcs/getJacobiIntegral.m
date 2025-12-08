%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [jacobi_int] = getJacobiIntegral(r, v, J, omega, mu)
%GETJACOBIINTEGRAL calculates Jacobi integral in the problem of rotation
%under GG torque on circular orbit
%   r -- radius-vector in Body Frame [m], (3x1)
%   v -- velocity in Body Frame [m/s], (3x1)
%   J -- tensor of inertia [kg*m^2], (3x3)
%   omega -- angular velocity in Body Frame [rad/s], (3x1)
%   mu -- Earth gravity parameter [m^3/s^2], (1x1)
w_orb = cross(r, v)/norm(r)^2;
jacobi_int = 0.5*dot(omega, J*omega) + 3/2*mu/norm(r)^5*dot(r, J*r) - dot(w_orb, J*omega);

end

