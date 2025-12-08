%	Version 1.0,
%	Author: Sergey Shestakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function q = mDcm2quat(dcm, check, tol)

% According to https://en.wikipedia.org/wiki/Rotation_matrix#Quaternion
% The formulas from "Alternatively, use a single square root and
% division"
% The dcm used here is transposed wrt the one used in wikipedia due to 
% the following: we prefer to think about dcm as transforming coordinate
% columns, not bases. This leads to difference between dcm definitions: our
% matrix is inverse (which is transposed for orthogonal matrices) wrt the
% one used in wikipedia. 
% For example, matrix [1, 0, 0; 0, 0, -1; 0, 1, 0] produces quaternion 
% (w, x, y, z) = (1/sqrt(2), -1/sqrt(2), 0, 0)
% The definition is the same as in original dcm2quat from aerospace 
% toolbox (passive rotation) and is different from rotm2quat from
% navigation toolbox and robotics system toolbox.
%
% The second and third arguments are optional, if orthocheck is true, the
% basic check for validity of dcm is provided with tol argument being the
% tolerancy of test. The test substantially slows computation down, so
% discretion is advised.
%
%   dcm -- direction cosine matrices. 3x3xN array of orthogonal matrices.
%   It must describe SO3 rotation, i.e. dcm*dcm' = dcm'*dcm = E, and det(dcm) = 1
%   check -- bool variable, true -- we conduct DCM validation, false -- we skip it
%   tol -- tolerance used in DCM check function

if (nargin == 1)
    check = false;
elseif (nargin == 2)
    tol = 1e-7;
elseif (nargin > 3)
    error('Too many input arguments')
end

tmp = size(dcm);
if ~isequal(tmp(1:2), [3, 3])
    error('input dcm must be 3x3xN array')
end

q = zeros(4, size(dcm,3));

for i = 1:size(dcm,3)
    
    if check
        if ~utility_funcs.mValidateDCM(dcm(:,:,i), tol)
            warning('Matrix is not orthogonal. Results may be incorrect')
        end       
    end

    t = dcm(1,1,i) + dcm(2,2,i) + dcm(3,3,i);
    if (t > 0) % if it is positive, the following is numerically stable
        r = sqrt(t + 1.0); 
        s = 1/(2.0*r);
        q(1, i) = 0.5*r; 
        q(2, i) = (dcm(2, 3, i) - dcm(3, 2, i))*s;
        q(3, i) = (dcm(3, 1, i) - dcm(1, 3, i))*s; 
        q(4, i) = (dcm(1, 2, i) - dcm(2, 1, i))*s; 
    else % we search for largest diagonal entry
        d = [dcm(1,1,i), dcm(2,2,i), dcm(3,3,i)];
        
        if ((d(1) >= d(2)) && (d(1) >= d(3))) % max value at dcm(1, 1), x value of q
            
            % the next if-else is not in wikipedia, it produces
            % quaternion with guaranteed nonnegative scalar part
            if (dcm(2, 3, i) - dcm(3, 2, i) >= 0)
                r = sqrt(1.0 + d(1) - d(2) - d(3));
            else
                r = -sqrt(1.0 + d(1) - d(2) - d(3));
            end
            
            s = 1/(2.0*r);
            q(2, i) = 0.5*r;
            q(1, i) = (dcm(2, 3, i) - dcm(3, 2, i))*s; 
            q(3, i) = (dcm(1, 2, i) + dcm(2, 1, i))*s; 
            q(4, i) = (dcm(3, 1, i) + dcm(1, 3, i))*s;
            
        elseif (d(2) >= d(3)) % max value at dcm(2, 2), y value of q
            
            if (dcm(3, 1, i) - dcm(1, 3, i) >= 0)
                r = sqrt(1.0 + d(2) - d(1) - d(3));
            else
                r = -sqrt(1.0 + d(2) - d(1) - d(3));
            end
            
            s = 1/(2.0*r);
            q(3, i) = 0.5*r; 
            q(1, i) = (dcm(3, 1, i) - dcm(1, 3, i))*s; 
            q(2, i) = (dcm(1, 2, i) + dcm(2, 1, i))*s; 
            q(4, i) = (dcm(2, 3, i) + dcm(3, 2, i))*s; 
            
        else % max value at dcm(3, 3), z value of q
            
            if (dcm(1, 2, i) - dcm(2, 1, i) >= 0)
                r = sqrt(1.0 + d(3) - d(1) - d(2));
            else
                r = -sqrt(1.0 + d(3) - d(1) - d(2));
            end
            
            s = 1/(2.0*r);
            q(4, i) = 0.5*r; 
            q(1, i) = (dcm(1, 2, i) - dcm(2, 1, i))*s;
            q(2, i) = (dcm(3, 1, i) + dcm(1, 3, i))*s; 
            q(3, i) = (dcm(2, 3, i) + dcm(3, 2, i))*s; 

         end
    end
end