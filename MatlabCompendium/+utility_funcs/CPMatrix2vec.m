%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020

function [vec] = CPMatrix2vec(cp_mat)
%CPMATRIX2VEC transforms cross product matrix  (3x3) to vector (3x1)
%   cp_mat -- skew-symmetric matrix [3x3]

if ~isequal(size(cp_mat), [3, 3])
    error('Matrix must be 3x3')
end

a = [cp_mat(3, 2); cp_mat(1, 3); cp_mat(2, 1)];
b = [cp_mat(2, 3); cp_mat(3, 1); cp_mat(1, 2)];

if norm(cp_mat + cp_mat') > 1e-10
    warning('matrix is far from skew symmetric, please re-check')
end

vec = 0.5*(a - b);
end

