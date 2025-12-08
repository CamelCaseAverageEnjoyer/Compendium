function M = Mz(a)
%MZ is basic rotation matrix about z-axis
arguments
    a (1,1) {mustBeNumeric}  % angle
end

M = [cos(a), -sin(a), 0;
     sin(a), cos(a), 0;
     0, 0, 1];

end