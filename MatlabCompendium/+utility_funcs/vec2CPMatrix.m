%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [cp_mat] = vec2CPMatrix(a)
%VEC2CPMATRIX transforms vector (3x1) to cross product matrix
%   a -- vector (3x1)
if (length(a) ~= 3) || ~isnumeric(a)
    error('input must be 3x1 or 1x3 numeric vector')
end
cp_mat = [0, -a(3), a(2);
         a(3), 0, -a(1);
         -a(2), a(1), 0];
end

