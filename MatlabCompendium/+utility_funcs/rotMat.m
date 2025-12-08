function [rot_mat] = rotMat(a, rot_axis)
%ROTMAT returns rotation matrix from basis A to basis B such that 
% r_B = rot_mat*r_A
%   a -- angle [radians]
%   rot_axis -- rotation axis number. 1 corresponds to the rotation along x
%   axis, 2 -- along y, 3 -- along z. Can also be the rotation axis vector.
if length(rot_axis) == 1
    ca = cos(a);
    sa = sin(a);
    switch rot_axis 
        case 1
            rot_mat = [1, 0, 0;
                       0, ca, sa;
                       0, -sa, ca];
        case 2
            rot_mat = [ca, 0, -sa;
                        0, 1, 0;
                        sa, 0, ca];
        case 3
            rot_mat = [ca, sa, 0;
                      -sa, ca, 0;
                       0,   0, 1];
        otherwise
            error('incorrect axis number. Must be 1,2 or 3')
    end
elseif length(rot_axis) == 3
    if isnumeric(rot_axis)
        if norm(rot_axis) > 1e-5
            e = zeros(3, 1);
            e(:) = rot_axis/norm(rot_axis);
            rot_mat = cos(a)*eye(3, 3) - sin(a)*utility_funcs.vec2CPMatrix(e) + (1 - cos(a))*(e*e');
        else
            error('rot_axis must be close to unit vector')
        end
    else
        error('rot_axis must be numeric');
    end


end

