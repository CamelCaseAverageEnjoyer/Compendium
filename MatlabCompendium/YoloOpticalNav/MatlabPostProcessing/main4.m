%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading
import graphics.*  % my functions loading

clear cam
load("local/calibration-3")  % cam{icam} - Camera class (main3)
load("local/trajectories-3D")  % T{iexp,icam} - trajectories (main3)

POLY_DEGREE = 2;  % Try 3,4,5,6

%% Approximate
for iexp = 1:2
    figure('Position', [(10 + 700*(iexp-1)) 150 700 500])
    for icam = 1:3
        t = T{iexp,icam}.time;
        x = T{iexp,icam}.R_mlm(:,1);
        y = T{iexp,icam}.R_mlm(:,2);
        z = T{iexp,icam}.R_mlm(:,3);
        p{iexp,icam}.x = polyfit(t, x, POLY_DEGREE);  % Polinomial approximation
        p{iexp,icam}.y = polyfit(t, y, POLY_DEGREE);   % [p{iexp,icam}.x,S,mu]
        p{iexp,icam}.z = polyfit(t, z, POLY_DEGREE); 
        x_pol = polyval(p{iexp,icam}.x, t);
        y_pol = polyval(p{iexp,icam}.y, t);
        z_pol = polyval(p{iexp,icam}.z, t);

        for i=1:3  % x,y,z
            subplot(3,3,(icam-1)*3 + i)
            xyz = [x y z];
            xyz_pol = [x_pol y_pol z_pol];
            xyz_lab = ["x","y","z"];
            plot(t,xyz(:,i))
            hold on
            plot(t,xyz_pol(:,i))
            hold off
            title("Камера " + num2str(icam) + ", " + xyz_lab(i))
            xlabel("Время, c")
            ylabel("Координата, м")
        end
    end
end

%% Merge trajectories 
P = cell(2,1);  % Polynomial approximation of trajectories 
for iexp = 1:2
    P{iexp}.p.x = mean([             p{iexp,2}.x; p{iexp,3}.x]);
    P{iexp}.p.y = mean([p{iexp,1}.y; p{iexp,2}.y; p{iexp,3}.y]);
    P{iexp}.p.z = p{iexp,1}.z;
    
    t = T{iexp,1}.time;  % largest time array
    dt = cam{1}.dt;
    P{iexp}.t = t;
    p_r = [P{iexp}.p.x; P{iexp}.p.y; P{iexp}.p.z];
    P{iexp}.r_mlm = [polyval(p_r(1,:), t), polyval(p_r(2,:), t), polyval(p_r(3,:), t)];

    v_coef = (POLY_DEGREE:-1:1);
    a_coef = (POLY_DEGREE:-1:2) .* ((POLY_DEGREE-1):-1:1);
    if iexp == 1
        disp("v coeffs: "+num2str(v_coef))
        disp("a coeffs: "+num2str(a_coef))
    end
    p_v = [P{iexp}.p.x(1:POLY_DEGREE) .* v_coef; 
           P{iexp}.p.y(1:POLY_DEGREE) .* v_coef;
           P{iexp}.p.z(1:POLY_DEGREE) .* v_coef];
    p_a = [P{iexp}.p.x(1:POLY_DEGREE-1) .* a_coef; 
           P{iexp}.p.y(1:POLY_DEGREE-1) .* a_coef;
           P{iexp}.p.z(1:POLY_DEGREE-1) .* a_coef];
    P{iexp}.v_mlm = [polyval(p_v(1,:), t), polyval(p_v(2,:), t), polyval(p_v(3,:), t)];
    P{iexp}.a_mlm = [polyval(p_a(1,:), t), polyval(p_a(2,:), t), polyval(p_a(3,:), t)];

    % MLM to ORB
    P{iexp}.r_orb = mlm2orf(P{iexp}.r_mlm')';
    
    P{iexp}.p_orb.x = polyfit(t, P{iexp}.r_orb(:,1), POLY_DEGREE);  % approximation AGAIN
    P{iexp}.p_orb.y = polyfit(t, P{iexp}.r_orb(:,2), POLY_DEGREE);
    P{iexp}.p_orb.z = polyfit(t, P{iexp}.r_orb(:,3), POLY_DEGREE);
    disp("Exp="+num2str(iexp)+" | px = "+num2str(P{iexp}.p_orb.x))
    disp("Exp="+num2str(iexp)+" | py = "+num2str(P{iexp}.p_orb.y))
    disp("Exp="+num2str(iexp)+" | pz = "+num2str(P{iexp}.p_orb.z))
    
    % Poly v, a
    p_v = [P{iexp}.p_orb.x(1:POLY_DEGREE) .* v_coef; 
           P{iexp}.p_orb.y(1:POLY_DEGREE) .* v_coef;
           P{iexp}.p_orb.z(1:POLY_DEGREE) .* v_coef];
    p_a = [P{iexp}.p_orb.x(1:POLY_DEGREE-1) .* a_coef; 
           P{iexp}.p_orb.y(1:POLY_DEGREE-1) .* a_coef;
           P{iexp}.p_orb.z(1:POLY_DEGREE-1) .* a_coef];
    P{iexp}.v_orb = [polyval(p_v(1,:), t), polyval(p_v(2,:), t), polyval(p_v(3,:), t)];
    P{iexp}.a_orb = [polyval(p_a(1,:), t), polyval(p_a(2,:), t), polyval(p_a(3,:), t)];

    % Manual v, a
%     s1 = size(P{iexp}.r_orb,1);
%     P{iexp}.v_orb_1 = [P{iexp}.r_orb(2:s1,1) - P{iexp}.r_orb(1:s1-1,1), ...
%                        P{iexp}.r_orb(2:s1,2) - P{iexp}.r_orb(1:s1-1,2), ...
%                        P{iexp}.r_orb(2:s1,3) - P{iexp}.r_orb(1:s1-1,3)] / dt;
%     s2 = size(P{iexp}.v_orb,1);
%     P{iexp}.a_orb_1 = [P{iexp}.v_orb(2:s2,1) - P{iexp}.v_orb(1:s2-1,1), ...
%                        P{iexp}.v_orb(2:s2,2) - P{iexp}.v_orb(1:s2-1,2), ...
%                        P{iexp}.v_orb(2:s2,3) - P{iexp}.v_orb(1:s2-1,3)] / dt;
end

%% 3D plots
% MLM frame
for iexp=1:2
    fig = figure('Position', [(30 + 700*(iexp-1)) 80 700 500]);
    tb = cameratoolbar(fig);
    hold on
    for icam=1:3
        myplot3(T{iexp,icam}.R_mlm)
    end
    myplot3(P{iexp}.r_mlm, 'k', 'LineWidth', 3)

    size_v = 1e2;
    size_a = 1e4;
    for i=1:100:(length(T{iexp,1}.time)-2)
        myplot3([P{iexp}.r_mlm(i,:); P{iexp}.r_mlm(i,:) + P{iexp}.v_mlm(i,:)*size_v], 'g')
        myplot3([P{iexp}.r_mlm(i,:); P{iexp}.r_mlm(i,:) + P{iexp}.a_mlm(i,:)*size_a], 'r')
    end
    hold off
    legend({'Камера 1','Камера 2','Камера 3','Усредненная траектория','Скорость','Ускорение'})
    title("MLM")
    cameratoolbar("SetCoordSys", "y")
end

% Orbital frame
for iexp=1:2
    fig = figure('Position', [(60 + 700*(iexp-1)) 10 700 500]);
    tb = cameratoolbar(fig);
    hold on
    myscatter3(P{iexp}.r_orb(1,:), 200, 'b.')
    myscatter3(P{iexp}.r_orb(size(P{iexp}.r_orb,1),:), 200, 'm.')
    myplot3(P{iexp}.r_orb, 'k', 'LineWidth', 2)
    size_v = 1e2;
    size_a = 1e4;
    for i=1:100:(length(T{iexp,1}.time)-2)
        myplot3([P{iexp}.r_orb(i,:); P{iexp}.r_orb(i,:) + P{iexp}.v_orb(i,:)*size_v], 'g')
        myplot3([P{iexp}.r_orb(i,:); P{iexp}.r_orb(i,:) + P{iexp}.a_orb(i,:)*size_a], 'r')
%         myplot3([P{iexp}.r_orb(i,:); P{iexp}.r_orb(i,:) + P{iexp}.v_orb_1(i,:)*size_v], 'b:')
%         myplot3([P{iexp}.r_orb(i,:); P{iexp}.r_orb(i,:) + P{iexp}.a_orb_1(i,:)*size_a], 'y:')
    end
    hold off
    legend({'Начало','Конец','Траектория','Скорость','Ускорение'})
    title("Orbital RF")
    cameratoolbar("SetCoordSys", "y")
end

%% Save
save("local/trajectories-3D-approxed", "P")
