function [altitude, latit, longi] = xyz2all(r_vec)
% Calculates altitude, latitude and longitude from the given r_vec.
% Altitude is the distance from the Earth Center, not height above
% ellipsoid!
% r_vec -- radius-vector (3x1)

if ~isequal(size(r_vec), [3, 1])
    error('Input vector must be 3x1 array')
end

if norm(r_vec) < 1e-10
    error('Input vector almost zero. You are doing something wrong')
end

altitude = norm(r_vec);
latit = asin(r_vec(3)/altitude);
longi = atan2(r_vec(2), r_vec(1));
end

