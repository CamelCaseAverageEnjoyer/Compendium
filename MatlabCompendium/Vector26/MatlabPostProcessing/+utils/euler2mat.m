function M = euler2mat(angs)
a = angs(1);
b = angs(2);
g = angs(3);
M = [cos(a)*cos(g) - sin(a)*cos(b)*sin(g), -cos(a)*sin(g) - sin(a)*cos(b)*cos(g),  sin(a)*sin(b);
     sin(a)*cos(g) + cos(a)*cos(b)*sin(g), -sin(a)*sin(g) + cos(a)*cos(b)*cos(g), -cos(a)*sin(b);
     sin(b)*sin(g),                         sin(b)*cos(g),                         cos(b)];
end

