function [out] = validateSymmetric(mat, tol)
%VALIDATESYMMETRIC checks if matrix is symmetrical or not
%   mat -- matrix (must be square)
%   tol -- tolerance
if max(abs(mat - mat'), [], 'all') > tol
    out = 0;
else
    out = 1;
end
end

