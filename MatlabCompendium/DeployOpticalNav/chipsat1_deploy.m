%% Init
clear
clc
close all
import graphics.*
import project_utils.*
config
load('local/cameraParams')

% Case choice
dt = 0.02;
t_modeling = 20;

case_n = 2;
n_deputy = 10;
e = M_orf2brf'*e_deploy;

if case_n == 1
    r_deploy = [0:dr:dr*(n_deputy-1);0:dr:dr*(n_deputy-1);0:dr:dr*(n_deputy-1)] .*e + [chief_dims(1)/2;0;0];     % m
    v_deploy = [0:dv:dv*(n_deputy-1);0:dv:dv*(n_deputy-1);0:dv:dv*(n_deputy-1)].*e + v0 * e;                  % m/s
    t_deploy = zeros(1, n_deputy);                               % s
    arrow_rate = 0.3;  % for plot
elseif case_n == 2
    r_deploy = ones(3, n_deputy) * chief_dims(1)/2 .* e;         % m
    v_deploy = ones(1, n_deputy) * v0 .* e;                      % m/s
    t_deploy = (0:(n_deputy-1)) * dr/v0;                         % s
    arrow_rate = 0.15*1.3;  % for plot
end


% Dynamic system
d = dynamics(h_orb, dt);  % Class of dynamics

% Chief spacecraft vectors
chief = spacecraft(zeros(3,1),zeros(3,1),chief_dims);

% Deputy pacecrafts
spacecrafts = chief;
for j = 1:n_deputy
    r = chief.r + M_orf2brf' * r_deploy(:,j);
    v = chief.v + M_orf2brf' * v_deploy(:,j);
    spacecrafts = [spacecrafts spacecraft(r, v, deputy_dims)];
    disp('Отделение: r=['+string(r(1))+','+string(r(2))+','+string(r(3))+']м, v=['+string(v(1))+','+string(v(2))+','+string(v(3))+']м/с')
end

% Plan of trajectory
figure('Position', [100 100 600 400]); hold on
axis equal
xlabel('x, м');    ylabel('y, м');    zlabel('z, м')
xlim([-0.15, 0.65]); ylim([-0.2, 0.2]); zlim([-0.2, 0.2])
colormap('gray')
% Arrows show
rc = spacecrafts(1).r + M_orf2brf'*r_camera;

r = rc + M_orf2brf'*e_cam_dir*arrow_rate; arrow3(rc', r', 'r',0.7); 
text(r(1), r(2), r(3), "Направление камеры")
r = Mz(camera_angle/2*pi/180)*M_orf2brf'*e_cam_dir; myplot3([rc, rc+r*arrow_rate]);
r = Mz(-camera_angle/2*pi/180)*M_orf2brf'*e_cam_dir; myplot3([rc, rc+r*arrow_rate]);

% r = rc + M_orf2brf'*e_cam_up*arrow_rate;    arrow3(rc', r', 'r',0.4); text(r(1), r(2), r(3), "Camera up")
% r = rc + M_orf2brf'*e_cam_aside*arrow_rate; arrow3(rc', r', 'r',0.4); text(r(1), r(2), r(3), "Camera side")

%r = spacecrafts(2).r + M_orf2brf'*e_deploy*arrow_rate; 
%arrow3(spacecrafts(2).r', r', 'b',0.7, 'LineWidth', 2); text(r(1), r(2), r(3), "Направление отделения")

% Trajectory show
N = round(1 * t_modeling / dt);
t = dt:dt:t_modeling;
R = zeros(3,N+1); V = zeros(3,N+1);
LOS_3d     = zeros(3, n_deputy, N); % Line of sight
for j=1:n_deputy
    R(:,1) = chief.r + M_orf2brf' * r_deploy(:,j);
    V(:,1) = chief.v + M_orf2brf' * v_deploy(:,j);
    for i=1:N
        if i*dt < t_deploy(j)
            V(:,i+1) = V(:,i);  R(:,i+1) = R(:,i);
        else
            [dr_, dv_] = d.rhs(R(:,i), V(:,i));
            V(:,i+1) = V(:,i) + dv_*dt;  
            R(:,i+1) = R(:,i) + dr_*dt;
        end
        % if i==round(t_modeling / dt) % Как камера смотрит на середины чипсатов
        %     myplot3([rc R(:,i+1)], 'k')
        % end
        LOS_3d(:,j,i) = R(:,i+1) - rc;
    end
    spacecrafts(j+1).r = R(:,N+1);  % Костыль для отображения на графике
    myplot3(R, 'b')
end
% Patch show
chief.show_chief()
for j=1:n_deputy
    spacecrafts(j+1).show_deputy(j)
    spacecrafts(j+1).r = chief.r + M_orf2brf' * r_deploy(:,j);  % Костыль убирается для численного моделирования
end
show_cube([0.02;0.02;0.05], M_orf2cam', rc - M_orf2brf'*e_cam_dir*0.025)
camup([0 1 0])
hold off

% Visioned part of deputy in t=t_modeling
deltas = zeros(n_deputy-1, N);
for j=1:(n_deputy-1)
    for i=1:N
        R1 = norm(LOS_3d(:,j+1,i));
        R2 = norm(LOS_3d(:,j,i));
        cos_a = dot(LOS_3d(:,j+1,i), LOS_3d(:,j,i)) / R1 / R2;
        cos_phi = dot(LOS_3d(:,j+1,i), M_orf2brf' * e_spread) / R1;
        if cos_phi > 0
            deltas(j,i) = R1/cos_phi * sqrt(1 - cos_a^2) / spacecrafts(2).dims(1)*100;
        else
            deltas(j,i) = 0;
        end
    end
end
% axes('Position',[.22 .55 .3 .3]); box on; hold on
figure('Position', [700 100 300 200]); hold on
m = 0;
for j=1:(n_deputy-1)
    plot(t, deltas(j,:),'b')
    m = max(m, max(deltas(j,:)));
end
ylim([0, min(100, m)])
xlabel('Время, c'); ylabel('Видимая часть ДКА, %')
hold off


%% Run of modeling
% Display
f = figure('Color', [0 0 0], 'Position', [200 100 window_size]);
counter_gif_frames = 0;

% Docking
N = round(t_modeling / dt);
CameraPosORF = zeros(N, 3);
ChiefPosORF = zeros(N, 3);
DeputyPosORF = zeros(N, 3 * n_deputy);
modeling_report = table(CameraPosORF, ChiefPosORF, DeputyPosORF);

counter = 0;
for i = 1:N
    % Time step
    [d, spacecrafts] = d.time_step(spacecrafts, t_deploy);

    % SHAMANIZM
    spacecrafts(1).r = zeros(3,1); 
    spacecrafts(1).v = zeros(3,1);
    
    % Figure update
    clf
    colormap('gray')
    camproj('perspective')
    axis equal
    cameratoolbar("SetMode","pan")
    light('Style', 'infinite', 'Position', d.R_sun)
    gca.XAxis.Visible = 'off';
    gca.YAxis.Visible = 'off';
    gca.ZAxis.Visible = 'off';
    axis off
    hold on
    
    % Spacecrafts show
    spacecrafts(1).show_chief();
    for j = 2:length(spacecrafts)
        spacecrafts(j).show_deputy(j-1);
    end
    
    % Camera update
    M_orf2cam = M_brf2cam * M_orf2brf;
    cam_pos = spacecrafts(1).r + M_orf2brf' * r_camera;
    campos(cam_pos);
    camup(M_orf2brf' * e_cam_up);
    camtarget(cam_pos + M_orf2brf' * e_cam_dir);
    camva(camera_angle);
    hold off;

    % Docking
    modeling_report.CameraPosORF(i,:) = cam_pos';
    modeling_report.ChiefPosORF(i,:) = spacecrafts(1).r';
    for j=1:n_deputy
        modeling_report.DeputyPosORF(i,3*j-2:3*j) = spacecrafts(j+1).r';
    end

    % Animation + pic saving
    frame = getframe(gcf);
    img =  frame2im(frame);
    [img,cmap] = rgb2ind(img,256);
    if i == 1
        imwrite(img,cmap,'local/animation_chipsat.gif','gif','LoopCount',Inf,'DelayTime',0.001);
    else
        imwrite(img,cmap,'local/animation_chipsat.gif','gif','WriteMode','append','DelayTime',0.001);
    end        
    counter = counter + 1;
    saveas(f, 'local/modeling_chipsat/' + string(counter) + '.jpg');
end
save("local/modeling_report", 'modeling_report')

%% Plot the results
figure
hold on
spacecrafts(1).show_chief();
myplot3(modeling_report.ChiefPosORF', 'k');
for j = 1:n_deputy
    myplot3(modeling_report.DeputyPosORF(:,3*j-2:3*j)', 'b');
end
xlabel('x, м'); ylabel('y, м'); zlabel('z, м')
camup([0 1 0])
colormap('gray')
axis equal
hold off

%% Find aruco
config  % markerFamily, markerSize
load('local/cameraParams')
counter = 0;
docking = {};
for i = 1:1000  % Сколько картинок обработать
    I = imread('local/modeling_chipsat/' + string(i) + '.jpg');
    camIntrinsics = cameraParams.Intrinsics;
    try
        [ids,locs,poses] = readArucoMarker(I,markerFamily,camIntrinsics,markerSize(1));
        for ii=1:length(ids)
            r = poses(ii).Translation;
            % disp('i='+string(i)+' | Метка id='+string(ids(ii)) ...
            %     +', r=['+string(r(1))+','+string(r(2))+','+string(r(3))+'] м')
            counter = counter + 1;
            docking{counter}.id = ids(ii);
            docking{counter}.r = r';
            docking{counter}.i = i;
        end
    catch
        % disp('i='+string(i)+' | Меток не обнаружено!')
    end
end

%% Post 
import graphics.myplot3
load("local/modeling_report")
config

figure('Position', [100 100 400 250]);
hold on
r = zeros(3, N, n_deputy);
rs = {};
ts = {};
for j=n_deputy:-1:1
    t = [];
    r = [];
    reals = [];
    r_est = [];
    counter = 0;
    for k = 1:length(docking)
        if j == docking{k}.id
            counter = counter + 1;
            r(:, counter) = M_orf2brf' * (M_brf2cam' * docking{k}.r + r_camera - M_brf2dep' * marker_pos);

            i = docking{k}.i;
            r_real = modeling_report.DeputyPosORF(i,3*j-2:3*j)';
            reals(:, counter) =  r_real;
            r_est(:, counter) =  r(:, counter);
            r(:, counter) = r(:, counter) - r_real;
            t(counter) = i*dt;
        end
    end
    % plot(t,r(1,:) / markerSize(1)); plot(t,r(2,:) / markerSize(1)); plot(t,r(3,:) / markerSize(1));
    if size(r, 2) > 0
        e = norm(r_real);
        % e = deputy_dims(1);
        plot(t,r(1,:)/e, 'LineWidth', 2); 
        plot(t,r(2,:)/e, 'LineWidth', 2); 
        plot(t,r(3,:)/e, 'LineWidth', 2);
        endpoint = size(t, 2)-10;
        if endpoint > 10
            ts{j} = t(10:endpoint);
            rs{j} = r_est(:,10:endpoint);
            rr{j} = reals(:,10:endpoint);
        end
    end
end
hold off
% camup([1 0 0])
% axis equal
% legend('x', 'y', 'z')
xlabel('Время, c'); ylabel('Ошибка навигации, безразм')

%%
import graphics.*
new_window_size = [300 300];
t_modeling = 10000;
dt = 1;
h_orb = 400e3;
d = dynamics(h_orb, dt);
N = round(1 * t_modeling / dt);

figure('Position', [100 100 new_window_size]); hold on
xlabel('x, м');    ylabel('y, м');    zlabel('z, м')

for j = 1:10
    all_counter = size(ts{j},2);
    ft = fittype('a*x + b');
    [paramx,~] = fit(ts{j}',rs{j}(1,:)',ft);
    [paramy,~] = fit(ts{j}',rs{j}(2,:)',ft);
    [paramz,~] = fit(ts{j}',rs{j}(3,:)',ft);
    R_mnk = [paramx.a * ts{j} + paramx.b;
             paramy.a * ts{j} + paramy.b;
             paramz.a * ts{j} + paramz.b];
    R_real = rr{j};
    % figure('Position', [100 600 new_window_size]); hold on
    % plot(R_real(1,:), 'r:'); plot(R_real(2,:), 'g:'); plot(R_real(3,:), 'b:'); 
    % plot(R_mnk(1,:), 'r-');  plot(R_mnk(2,:), 'g-');  plot(R_mnk(3,:), 'b-'); 
    % xlabel('Кадры'); ylabel('Координаты R, м')
    % legend('Rˣ', 'Rʸ', 'Rᶻ', 'оценка Rˣ', 'оценка Rʸ', 'оценка Rᶻ')
    % grid; hold off
    
    
    R_r = zeros(3,N+1); V_r = zeros(3,N+1);
    R_e = zeros(3,N+1); V_e = zeros(3,N+1);
    R_r(:,1) = R_real(:,1); R_e(:,1) = R_mnk(:,1);
    V_r(:,1) = (R_real(:,all_counter) - R_real(:,1))/3;
    V_e(:,1) = (R_mnk(:,all_counter) - R_mnk(:,1))/3;
    for i=1:N
        [dr_, dv_] = d.rhs(R_r(:,i), V_r(:,i));
        V_r(:,i+1) = V_r(:,i) + dv_*dt;  
        R_r(:,i+1) = R_r(:,i) + dr_*dt;
        [dr_, dv_] = d.rhs(R_e(:,i), V_e(:,i));
        V_e(:,i+1) = V_e(:,i) + dv_*dt;  
        R_e(:,i+1) = R_e(:,i) + dr_*dt;
    end
    
    myplot3(R_r, 'b')
    myplot3(R_e, 'r')
    
end
legend('Действительные траектории', 'Оцениваемые траектории')
grid; hold off;

figure('Position', [100 400 new_window_size]); hold on
myplot3(R_e-R_r, 'b')
xlabel('x, м');    ylabel('y, м');    zlabel('z, м')
legend('Ошибка траектории')
grid; hold off;