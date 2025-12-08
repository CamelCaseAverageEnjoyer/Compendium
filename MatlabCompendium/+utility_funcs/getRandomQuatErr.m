function [Q_err] = getRandomQuatErr(sigma)
%GETRANDOMQUATERR generates random quaternion with a given sigma.
%   Detailed explanation goes here
phi = randn()*sigma;
direction = randn(3, 1);
while norm(direction) < 1e-7
    direction = randn(3, 1);
end
direction = direction/norm(direction);
Q_err = [cos(phi/2); direction*sin(phi/2)];
end

