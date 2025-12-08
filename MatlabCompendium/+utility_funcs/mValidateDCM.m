%	Version 1.0,
%	Author: Sergey Shestakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function out = mValidateDCM(dcm, tol)
% checks either input dcm matrix describes SO3 rotation or not,
% SO3 means that dcm*dcm' = dcm'*dcm = E, and det(dcm) = 1

% dcm -- 3x3 matrix
% tol -- tolerance value
    if ~isequal(size(dcm), [3, 3])
        error('dcm size must be 3x3')
    end
    % check determinant
    lefterror = max(abs(dcm*dcm' - eye(3)),[],'all');
    out = 1;
    if (lefterror > tol) || abs(det(dcm) - 1) > tol
        out = 0;
    end
    
end