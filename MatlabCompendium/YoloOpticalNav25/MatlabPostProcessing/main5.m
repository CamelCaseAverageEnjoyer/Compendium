%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading
import graphics.*  % my functions loading

load("local/trajectories-3D-approxed")  % P - poly trajectories (main4)

%% Parse ISS orbit params
data = readtable("local/Орбита_МКС_UTC.txt");
data.Properties.VariableNames = {'date','year','month','day','h','m','s','rx','ry','rz','vx','vy','vz','height'};

dt = 1.;
time = (1:length(data.s))' * dt;
date = datetime(data.year,data.month,data.day,data.h,data.m,data.s);
r_grf = [data.rx, data.ry, data.rz] * 1e3;  % m
v_grf = [data.vx, data.vy, data.vz] * 1e3;  % m/s
height = data.height * 1e3;  % m
rho = my_atm(height);
disp("Atmosphere density: "+num2str(rho(1)))

ISS = table(time, date, r_grf, v_grf, height, rho);  
ISS.Properties.VariableNames = {'time','date','r_grf','v_grf','height','density'};
% disp(head(ISS))

%% Calculations
R = norm(ISS.r_grf(1,:));
w0 = sqrt(mu / R^3);

% Geodesic RF
L_iss = length(ISS.time);
M_grf_irf = zeros(3,3,L_iss);
for i=1:L_iss
    a = w_earth * ISS.time(i);
    M = [cos(a) -sin(a) 0;
         sin(a)  cos(a) 0;
         0       0      1];  % GRF -> IRF
    M_grf_irf(:,:,i) = M;

    ISS.r_irf(i,:) = (M * ISS.r_grf(i,:)')';
    ISS.v_irf(i,:) = ISS.v_grf(i,:) + cross([0;0;w_earth], ISS.r_grf(i,:)')';
end

% Orbital moment vector
b = cross(ISS.r_irf(1,:)',ISS.v_irf(1,:)');
b = b / norm(b);

%% Duration of experiments
t0 = {datetime(2024,06,18,8,40,0);
      datetime(2024,06,18,9,02,0)};
for iexp=1:2
    durations{iexp} = P{iexp}.t(length(P{1}.t));
    t1{iexp} = t0{iexp} + seconds(durations{iexp});
    timeMask{iexp} = (ISS.date >= t0{iexp}) & (ISS.date <= t1{iexp});
end

%% 3D plot
for i=1:2
    fig = figure('Position', [(10+(i-1)*720) 150 700 500]);
    tb = cameratoolbar(fig);
    hold on
    % Earth show
    [X,Y,Z] = sphere(30);
    fvc = surf2patch(X * Re, Y * Re, Z * Re);
    patch('Faces', fvc.faces, 'Vertices', fvc.vertices, ...
          'FaceColor', [0.01, 0.8, 0.8], 'EdgeColor', 'none', 'FaceAlpha', 0.5);
    mylegend = "Земля";
    if i == 1
        myplot3(ISS.r_grf)
        myscatter3(ISS.r_grf(1,:), 200, 'b.')
        myscatter3(ISS.r_grf(L_iss,:), 200, 'm.')
        for iexp=2:2  % !!!
            r = ISS.r_grf(timeMask{iexp}, :);
            myplot3(r, 'LineWidth', 3)
        end
        mylegend(2:5) = ["Траектория ГCК", "Начало", "Конец", "Эксперимент"];  % , "Эксперимент 2"];
    else
        myplot3(ISS.r_irf)
        myscatter3(ISS.r_irf(1,:), 200, 'b.')
        myscatter3(ISS.r_irf(size(ISS.r_irf,1),:), 200, 'm.')
        myplot3([0 0 0; b' * norm(ISS.r_irf(1,:)) * 1.1], 'LineWidth', 2)
        mylegend(2:5) = ["Траектория ИCК", "Начало", "Конец", "Орбитальный момент"];
    end
    hold off
    legend(mylegend);
    view(-15, 20);
end

%% Comparing to HKW + aero
Cx = 1;
Cy = 1;
Cz = 1;
for iexp=1:2
    L = size(P{iexp}.r_orb, 1);
    a_hkw = zeros(L,3);
    a_aero = zeros(L,3);
    for i=1:L
        a_hkw(i,:) = [-w0*P{iexp}.v_orb(i,2);
                      w0*P{iexp}.v_orb(i,1) + w0^2*P{iexp}.r_orb(i,2);
                      -w0^2*P{iexp}.r_orb(i,3)]';
        a_aero(i,:) = ISS.density(1) * S_miedel * ...
                      norm(ISS.v_grf(1,:))^2 * ...
                      (M_orb_brf' * [Cx;Cy;Cz])' ...
                      / (2 * m_iss);
    end

    figure('Position', [(35 + 700*(iexp-1)) 135 700 500])
    hold on
    plot(P{iexp}.t, a_hkw(:,1) + a_aero(:,1),'r:','LineWidth',2)
    plot(P{iexp}.t, a_hkw(:,2) + a_aero(:,2),'g:','LineWidth',2)
    plot(P{iexp}.t, a_hkw(:,3) + a_aero(:,3),'b:','LineWidth',2)
    plot(P{iexp}.t, P{iexp}.a_orb(:,1),'r-','LineWidth',2)
    plot(P{iexp}.t, P{iexp}.a_orb(:,2),'g-','LineWidth',2)
    plot(P{iexp}.t, P{iexp}.a_orb(:,3),'b-','LineWidth',2)
    hold off
    grid on
    legend({'x hkw+aero','y hkw+aero','z hkw+aero','x poly','y poly','z poly'})
    title("Сравнение XKУ и результатов")
    
end

%% Ballistic coefficients
w_ = [0; 0; w0];
R_ = [0; R; 0];
for iexp=1:2
    % FINALLY
    L = size(P{iexp}.r_orb, 1);
    a_aero_orb = zeros(L,3);
    for i=1:L
        a_aero_orb(i,:) = (-P{iexp}.a_orb(i,:)' - ...
                           cross(w_, cross(w_, P{iexp}.r_orb(i,:)')) - ...
                           2*cross(w_, P{iexp}.v_orb(i,:)') + ...
                           mu/R^3 * (3*R_*(P{iexp}.r_orb(i,:) * R_)/R^2 - P{iexp}.r_orb(i,:)'))';
    end

    figure('Position', [(60 + 700*(iexp-1)) 100 700 500])
    hold on
    plot(P{iexp}.t, a_aero_orb(:,1))
    plot(P{iexp}.t, a_aero_orb(:,2))
    plot(P{iexp}.t, a_aero_orb(:,3))
    hold off
    grid on
    legend({'x','y','z'})
    
end
