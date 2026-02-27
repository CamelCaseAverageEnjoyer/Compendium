close all; clc; clear

%% Numerical & Analytical


%% Energy conservation


%% benchmark_performance


%% Gravity models compare 
import core.dynamics.force_gravity_central

configs.config_earth
r = [r_orb; 0; 0];
F = force_gravity_central(r,cfg.PCBsat.mass,cfg.planet.mu);
a = F / cfg.PCBsat.mass;
disp(a);

%% Atmospheric models compare 
import core.dynamics.density_aero_0007

h = 300e3:20e3:500e3;
rho = zeros(1,length(h));
for i=1:length(h)
    rho(i) = density_aero_0007(h(i));
end
figure('Position', [650 500 600 500]); hold on; 
title("Модели плотности атмфосферы");
plot(h./1e3,rho); 
legend('Сухой Ю.Г., Брагинец В.Ф., Мошнин А.А.');
grid; xlabel("Высота, км"); ylabel("Плотность, кг/м3"); hold off;



%% Antenna Gain
import core.measurements.antenna_gain

theta = -pi/2:0.01:3*pi/2;
G1 = antenna_gain(theta,"half-wave monopole");
G2 = antenna_gain(theta,"short monopole");
G3 = antenna_gain(theta,"sin3");
figure('Position', [100 500 500 500]); hold on; 
title("Диаграмма направленностей разных антенн");
[x,y]=pol2cart(theta+pi/2,G1); plot(x,y,'r'); 
[x,y]=pol2cart(theta+pi/2,G2); plot(x,y,'g'); 
[x,y]=pol2cart(theta+pi/2,G3); plot(x,y,'b'); 
legend('Half-wave','Short','sin3'); hold off; axis equal;
disp("Максимальная разница [half-wave monopole, short monopole]: "+string(max(abs(G1-G2))))
disp("Максимальная разница [half-wave monopole, sin3]:           "+string(max(abs(G1-G3))))


%% Сранвение сил, действующих на PCBsat на НОО
% 0189 (Archison J.A., Peck M.A.) "Length Scaling in Spacecraft Dynamics"
import core.dynamics.*
import core.frames.*
import utils.*
configs.config_earth

h = 400;
rho_a = density_aero_0007(h*1e3, "Earth");

N = 300;
varTypes = {'double','double','double','double','double','double','double'};
varNames = {'Сила гармоники J2','Притяжение Луны','Притяжение Солнца', ...
    'Лобовое сопрортивление','Подъёмная сила','Давление солнечного света', ...
    'Давление солнечного ветра'};
toplot = {'Сила гармоники J2','Лобовое сопрортивление','Подъёмная сила','Давление солнечного света','Давление солнечного ветра'};
PCBsat = table('Size',[N 7],'VariableTypes',varTypes,'VariableNames',varNames);
Cubesat = table('Size',[N 7],'VariableTypes',varTypes,'VariableNames',varNames);
RelForces = table('Size',[N 7],'VariableTypes',varTypes,'VariableNames',varNames);
for iter = 1:N
    e_sun = unitVec(rand(3,1));
    n = unitVec(rand(3,1));

    i = rand() * pi;
    u = rand() * 2*pi;
    v = [0; v_orb; 0];
    r = [r_orb; 0; 0];
    
    [F_ad,F_al] = force_aerodynamic_0189(v,n,rho_a,"PCBsat",cfg);
    F_a  = force_aerodynamic_0345(v,n,rho_a,cfg);
    e = norm(F_ad + F_al-F_a) / norm(F_a);
    %disp(F_ad + F_al); disp(F_a)
    %disp("Ошибка формул 189, 345 = "+string(e)); disp(" ");
    
    F_g = force_gravity_central(r,cfg.PCBsat.mass,cfg.planet.mu);
    F_moon = force_gravity_central([384.4e6;0;0],cfg.PCBsat.mass,4902e9);
    F_sun = force_gravity_central([150e9;0;0],cfg.PCBsat.mass,132712440018e9);
    F_j2 = force_gravity_J2(r,cfg.PCBsat.mass,u,i,cfg,eye(3));
    F_sw = force_solarwind(e_sun,n,cfg);
    F_s = force_solarradiation(e_sun,n,cfg);
    
    PCBsat(iter,1) = {norm(F_j2)/norm(F_g)};    % Воздействие J2 Земли
    PCBsat(iter,2) = {norm(F_moon)/norm(F_g)};  % Воздействие притяжения Луны
    PCBsat(iter,3) = {norm(F_sun)/norm(F_g)};   % Воздействие притяжения Солнца
    PCBsat(iter,4) = {norm(F_ad)/norm(F_g)};    % Воздействие лобового сопротивления
    PCBsat(iter,5) = {norm(F_al)/norm(F_g)};    % Воздействие подъёмной силы ветра
    PCBsat(iter,6) = {norm(F_s )/norm(F_g)};    % Воздействие солнечного света
    PCBsat(iter,7) = {norm(F_sw)/norm(F_g)};    % Воздействие солнечного ветра

    r = r + (rand(3,1)*2-1) .* 100;  % ±100 метров
    v = v + (rand(3,1)*2-1) .* 1;    % ±1 метр/сек
    
    [F_ad,F_al] = force_aerodynamic_0189(v,n,rho_a,"Cubesat",cfg);
    
    F_g = force_gravity_central(r,cfg.Cubesat.mass,cfg.planet.mu);
    F_moon = force_gravity_central([384.4e6;0;0],cfg.Cubesat.mass,4902e9);
    F_sun = force_gravity_central([150e9;0;0],cfg.Cubesat.mass,132712440018e9);
    F_j2 = force_gravity_J2(r,cfg.Cubesat.mass,u,i,cfg,eye(3));
    F_sw = force_solarwind(e_sun,e_sun,cfg);  % (e_sun,n)=1
    F_s = force_solarradiation(e_sun,e_sun,cfg);  % (e_sun,n)=1
    
    Cubesat(iter,1) = {norm(F_j2)/norm(F_g)};    % Воздействие J2 Земли
    Cubesat(iter,2) = {norm(F_moon)/norm(F_g)};  % Воздействие притяжения Луны
    Cubesat(iter,3) = {norm(F_sun)/norm(F_g)};   % Воздействие притяжения Солнца
    Cubesat(iter,4) = {norm(F_ad)/norm(F_g)};    % Воздействие лобового сопротивления
    Cubesat(iter,5) = {norm(F_al)/norm(F_g)};    % Воздействие подъёмной силы ветра
    Cubesat(iter,6) = {norm(F_s )/norm(F_g)};    % Воздействие солнечного света
    Cubesat(iter,7) = {norm(F_sw)/norm(F_g)};    % Воздействие солнечного ветра
    
    for k=1:7
        RelForces(iter,k) = abs(PCBsat(iter,k) - Cubesat(iter,k));
    end
end

figure('Position', [100 100 400 500]);
boxchart(PCBsat, toplot); xticklabels(toplot) 
title("Действующие на PCBsat силы, h="+string(h)+"км")
ylabel("Отношение к притяжению центрального поля, безразм")
yscale log; grid; 

figure('Position', [550 100 400 500]);
boxchart(Cubesat, toplot); xticklabels(toplot) 
title("Действующие на Cubesat силы, h="+string(h)+"км")
ylabel("Отношение к притяжению центрального поля, безразм")
yscale log; grid; 

figure('Position', [1000 100 400 500]);
boxchart(RelForces, toplot); xticklabels(toplot) 
title("Разность сил, h="+string(h)+"км")
ylabel("Отношение к притяжению центрального поля, безразм")
yscale log; grid; 

%% Символьная проверка матрицы поворота
syms x y z Om u i
S1 = [cos(Om) -sin(Om) 0; sin(Om) cos(Om) 0; 0 0 1];
S2 = [1 0 0; 0 cos(i) -sin(i); 0 sin(i) cos(i)];
S3 = [cos(u) -sin(u) 0; sin(u) cos(u) 0; 0 0 1];
S = S1 * S2 * S3;  % orbital -> inertial (Ox - r, Oy - v)