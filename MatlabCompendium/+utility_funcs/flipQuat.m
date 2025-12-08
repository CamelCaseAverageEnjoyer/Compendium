%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020

function [result_quat] = flipQuat(q1, q2)
%FLIPQUAT returns the quaternion that is closer to the q1: q2 or -q2
%   q1, q2 -- quaternions, [4x1] each
if ~(isequal(size(q1), [4, 1]) && isequal(size(q2), [4, 1]))
    error('Wrong quaternion size. It must be 4x1 vector')
end

if norm(q1 - q2) > norm(q1 + q2)
    result_quat = -q2;
else
    result_quat = q2;
end

end

