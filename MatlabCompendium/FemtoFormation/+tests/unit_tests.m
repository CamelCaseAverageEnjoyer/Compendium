close all; clc; clear; import utils.*

%% Geoid test
p = Problem(1,"Earth",[1, 2],['',''],'random',0,0,0,0,0);  
a = p.a_body; f = p.f_body;
for i =1:100
    h = height(a,f,unitVec(rand(3,1)*2-1)*(a + 1000e3));
    assert((1000e3 < h) && (h < 1100e3))
    rho_atm = density_aero_0007(h, "Earth");
    disp(rho_atm)
end

%% Params init
tic
% Zero-params
p = Problem(1,"Earth",[1, 10],['isotropic','isotropic'],'random',...
    400e3, ...                      % H, высота орбиты
    0.01, ...                       % e, экцентриситет
    deg2rad(0), ...                 % i, наклонение
    deg2rad(0), ...                 % om, аргумент перицентра
    deg2rad(0));                   % Om, долгота восходящего узла

assert(all(all(p.S_orb2dec == eye(3))))
assert(all(all(p.S_irf2grf == eye(3))))
assert(all(all(p.S_orf2irf == [0 1 0; 1 0 0; 0 0 -1])))

e = p.sat.("CubeSat")(1).e(1);
h = p.sat.("CubeSat")(1).h(1);
c = p.sat.("CubeSat")(1).c(:,1);
f = p.sat.("CubeSat")(1).f(:,1);
assert(abs(  norm(f) - p.mu*e  )/norm(f) < 1e-15)  % e = f/mu
assert(abs(  dot(c,f)  )/norm(c)/norm(f) < 1e-15)  % (c,f) = 0
assert(abs(  norm(f)^2-p.mu^2-h*norm(c)^2  )/max(norm(c),norm(f))^2 < 1e-10) % f^2 = mu^2 + hc^2

% Non-zero-params
p = Problem(1,"Earth",[1, 10],['isotropic','isotropic'],'random',...
    400e3, ...                      % H, высота орбиты
    0.01, ...                       % e, экцентриситет
    deg2rad(10), ...                % i, наклонение
    deg2rad(20), ...                 % om, аргумент перицентра
    deg2rad(30));                   % Om, долгота восходящего узла

e = p.sat.("CubeSat")(1).e(1);
i = p.sat.("CubeSat")(1).i(1);
om = p.sat.("CubeSat")(1).om(1);
Om = p.sat.("CubeSat")(1).Om(1);
assert(abs(0.01 - e)/0.01       < 1e-10)
assert(abs(10 - rad2deg(i)) /10 < 1e-10)
assert(abs(20 - rad2deg(om))/20 < 1e-10)
assert(abs(30 - rad2deg(Om))/30 < 1e-10)


toc

%% Core.Frames: frame transforms


%% Core.Dynamics: inertial dynamics


%% Core.Dynamics: hcw


%% Core.Dynamics: schwartz_sedwick


%% Core.Measurements: Antenna Gain


%% Core.Measurements: RSS


%% Simulation: rk4
