function q1 = invQuat(q)
%INVERTQUAT inverts the quaternion
arguments (Input)
    q (1,4) {mustBeNumeric}
end

q1 = [q(1), -q(2), -q(3), -q(4)];
end