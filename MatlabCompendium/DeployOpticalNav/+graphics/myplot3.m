function myplot3(r, color)
%MYPLOT3 plots the line in simple way
arguments (Input)
    r (3,:) {mustBeNumeric}
    color (1,1) string = 'k'
end
plot3(r(1,:), r(2,:), r(3,:), color,'LineWidth',2);

end