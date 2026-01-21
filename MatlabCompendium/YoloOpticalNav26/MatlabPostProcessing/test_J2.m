clear
clc

%% Estimation of error of perturbing acceleration
r = 50;  % Between spacecrafts
Re = 6371000;
R  = 6790520;
mu = 5.972e24 * 6.67408e-11;
J2 = 1.082e-3;
Z = [0;0;1];

r1 = rand(3,1);
r1 = R * r1 / norm(r1);  % Position of 1-st spacectaft (random)

r2 = rand(3,1);
r2 = r1 + r * r2 / norm(r2);  % Position of 2-nd spacectaft (random)

rho = r2 - r1;

a2_rel_withoutJ2 = -mu/R^3 * (rho - 3*r1*((rho/R)' * (r1/R)));
a2_rel_withoutJ2_min = mu/R^3 * r;
disp("Formula difference (no J2)")
disp(a2_rel_withoutJ2')
disp(num2str(norm(a2_rel_withoutJ2)) + " m/s2")
disp(num2str(a2_rel_withoutJ2_min) + " m/s2 (min)")
disp(" ")

da2_rel_withoutJ2 = -mu/R^3 * (-3*rho*((rho/R)' * (r1/R)) -3/2 * norm(rho)^2*(r1 + rho)/R^2 + 15/8*(norm(rho)^2/R^2 + 2*(rho'*r1)/R^2)^2*(r1 + rho));
disp("Formula error (no J2)")
disp(num2str(norm(da2_rel_withoutJ2)) + " m/s2")
disp(num2str(100 * norm(da2_rel_withoutJ2) / norm(a2_rel_withoutJ2)) + " %")
disp(num2str(100 * norm(da2_rel_withoutJ2) / a2_rel_withoutJ2_min) + " % (min)")
disp(" ")


a1_full_withoutJ2 = -mu*r1/norm(r1)^3;
a2_full_withoutJ2 = -mu*r2/norm(r2)^3;
disp("Calculated difference (no J2)")
disp((a2_full_withoutJ2 - a1_full_withoutJ2)')
disp(norm(a2_full_withoutJ2 - a1_full_withoutJ2))

a1_full_withJ2 = -mu*r1/norm(r1)^3 - 3*J2*Re^2*mu/2 * (r1/norm(r1)^5 + 2*Z*(r1'*Z)/norm(r1)^5 + 5*r1*(r1'*Z)^2/norm(r1)^7);
a2_full_withJ2 = -mu*r2/norm(r2)^3 - 3*J2*Re^2*mu/2 * (r2/norm(r2)^5 + 2*Z*(r2'*Z)/norm(r2)^5 + 5*r2*(r2'*Z)^2/norm(r2)^7);
disp("Calculated difference (with J2)")
disp((a2_full_withoutJ2 - a1_full_withoutJ2)')
disp(norm(a2_full_withJ2 - a1_full_withJ2))

da2_rel_withJ2 = -3*J2*Re^2*mu/2 * ((rho + 2*Z*(rho'*Z))/R^5 + ...
    (r2 + 2*Z*(r2'*Z))/R^5*(5/2*((rho'*rho) + 2*(rho'*r1))/R^2) - ...
    5*r1*((rho'*Z)^2 + 2*(r1'*Z)*(rho'*Z))/R^7 - ...
    5*rho*((r1'*Z)^2 + (rho'*Z)^2 + 2*(r1'*Z)*(rho'*Z))/R^7 - ...
    5*(r1+rho)*((r1'*Z)^2 + (rho'*Z)^2 + 2*(r1'*Z)*(rho'*Z))/R^7 *(7/2*((rho'*rho) + 2*(rho'*r1))/R^2));
a2_rel_withoutJ2_min = -3*J2*Re^2*mu/2 * ((r + 2*r)/R^5 + ...
    (R + 2*R)/R^5*(5/2*(r^2 + 2*r*R)/R^2) - ...
    5*R*(r^2 + 2*R*r)/R^7 - ...
    5*r*(R^2 + r^2 + 2*R*r)/R^7 - ...
    5*(R+r)*(R^2 + r^2 + 2*R*r)/R^7 *(7/2*(r^2 + 2*r*R)/R^2));
disp("Formula error (with J2)")
disp(num2str(norm(da2_rel_withJ2)) + " m/s2")
disp(num2str(da2_rel_withJ2_max) + " m/s2 (max)")
disp(num2str(100 * norm(da2_rel_withJ2) / norm(a2_rel_withoutJ2)) + " %")
disp(num2str(100 * norm(da2_rel_withJ2) / a2_rel_withoutJ2_min) + " % now / (min)")
disp(num2str(100 * norm(da2_rel_withJ2) / a2_rel_withoutJ2_min) + " % (max) / (min)")
disp(" ")

disp("==================")
disp("Error when is no J2")
disp(num2str(norm(a2_full_withoutJ2 - a1_full_withoutJ2 - a2_rel_withoutJ2)) + " m/s2")
disp(num2str(100 * norm(a2_full_withoutJ2 - a1_full_withoutJ2 - a2_rel_withoutJ2) / norm(a2_full_withoutJ2 - a1_full_withoutJ2)) + " %")
disp(" ")

disp("Error when is J2")
disp(num2str(norm(a2_full_withJ2 - a1_full_withJ2 - a2_rel_withoutJ2)) + " m/s2")
disp(num2str(100 * norm(a2_full_withJ2 - a1_full_withJ2 - a2_rel_withoutJ2) / norm(a2_full_withJ2 - a1_full_withJ2)) + " %")






