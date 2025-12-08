%	Version 1.0,
%	Author: Sergey Shestakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function qout = mQuatMultiply(q1, q2, secondisvec)
% calculates multiplication of quaternions
% q1 -- first quaternion (4x1)
% q2 -- second quaternion (or vector) (4x1 or 3x1)
% secondisvec -- additional parameter, either 0 or 1. Default values is 0.
% 1 means that second quaternion is actually a vector (3x1 array)
if nargin == 2
    secondisvec = 0;
end

if secondisvec == 0
    qout = zeros(4,1);
    if ~isequal(size(q1), [4, 1]) || ~isequal(size(q2), [4, 1])
        error('Inputs must be 4x1 arrays. If you are trying to multiply quat by vector, pass third parameter as 1')
    end
    qout(1) = q1(1)*q2(1) - q1(2)*q2(2) - q1(3)*q2(3) - q1(4)*q2(4);
    qout(2) = q1(1)*q2(2) + q2(1)*q1(2) + q1(3)*q2(4) - q1(4)*q2(3);
    qout(3) = q1(1)*q2(3) + q2(1)*q1(3) + q1(4)*q2(2) - q1(2)*q2(4);
    qout(4) = q1(1)*q2(4) + q2(1)*q1(4) + q1(2)*q2(3) - q1(3)*q2(2);

else 
    if ~isequal(size(q1), [4, 1]) || ~isequal(size(q2), [3, 1])
        error('q1 must be 4x1 array and q2 must be [3x1] array. If you are trying to multiply quat by quat, pass third parameter as 0 or ignore it')
    end
    qout = zeros(4,1);

    qout(1) = - q1(2)*q2(1) - q1(3)*q2(2) - q1(4)*q2(3);
    qout(2) = q1(1)*q2(1) + q1(3)*q2(3) - q1(4)*q2(2);
    qout(3) = q1(1)*q2(2) + q1(4)*q2(1) - q1(2)*q2(3);
    qout(4) = q1(1)*q2(3) + q1(2)*q2(2) - q1(3)*q2(1);

end

end