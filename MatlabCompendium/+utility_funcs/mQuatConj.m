%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [q_conj] = mQuatConj(q)
%MQUATCONJ calculates conjugated quaternion
%   q -- quaternion, 4x1
if ~isequal(size(q), [4, 1])
    error('Input must be 4x1')
end
q_conj = [q(1); 
         -q(2:4)];
end

