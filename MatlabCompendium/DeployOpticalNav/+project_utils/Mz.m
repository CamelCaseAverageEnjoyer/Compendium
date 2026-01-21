function M = Mz(ang)
%MZ is rotation matrix
M = [cos(ang) -sin(ang) 0;
     sin(ang)  cos(ang) 0
     0         0        1];
end