%% Init
clear
clc
close all
import graphics.*
import my_utils.*
import project_utils.*
config
load('local/cameraParams')

% Dynamic system
dt = 0.5;
t_modeling = 500;
d = dynamics(h_orb, dt);  % Class of dynamics

% Chief spacecraft vectors
w_irf2orf = [0; d.w_orb; 0];      % IRF->ORF in ORF
w_irf2brf = M_orf2brf*w_irf2orf;  % IRF->BRF in BRF (BRF don't rotate in ORF)
chief = spacecraft(zeros(3,1),zeros(3,1),q_irf2brf,w_irf2brf,3,chief_dims);

% Deputy pacecrafts
n_deputy = 10;
r_deploy = (0:dr:dr*(n_deputy-1)) + chief_dims(1)/2;  % in m
v_deploy = (0:dv:dv*(n_deputy-1)) + v0;  % in m/s
spacecrafts = chief;
for j = 1:n_deputy
    M = chief.ORF2BRF(d);
    r = chief.r + M' * e_deploy * r_deploy(j);
    v = chief.v + M' * e_deploy * v_deploy(j);
    q = q_irf2deputy;
    w = chief.w;
    spacecrafts = [spacecrafts spacecraft(r, v, q, w, 0.01, deputy_dims)];
    disp('Отделение: r=['+string(r(1))+','+string(r(2))+','+string(r(3))+']м, v=['+string(v(1))+','+string(v(2))+','+string(v(3))+']м/с')
end

% Testing
disp('Тестировка: '+string(norm(spacecrafts(1).ORF2BRF(d) - M_orf2brf) < 1e-14))

% Plan of trajectory
figure; hold on
axis equal
xlabel('x, m')
ylabel('y, m')
zlabel('z, m')
xlim([-1.5, 1.5])
ylim([-1.0, 1.0])
zlim([-0.5, 0.5])
colormap('gray')
% Camera show
arrow_rate = 0.3;
point_rate = 0.4;
M_orf2cam = M_brf2cam * M_orf2brf;
rc = spacecrafts(1).r + M_orf2brf'*r_camera;
r = rc + M_orf2brf'*r_cam_dir*arrow_rate;   arrow3(rc', r', 'r',point_rate);
text(r(1), r(2), r(3), "Camera toward")
% r = Mz(camera_angle/2*pi/180)*M_orf2brf'*r_cam_dir; myplot3([rc, rc+r*arrow_rate]);
% r = Mz(-camera_angle/2*pi/180)*M_orf2brf'*r_cam_dir; myplot3([rc, rc+r*arrow_rate]);
r = rc + M_orf2brf'*r_cam_up*arrow_rate;    arrow3(rc', r', 'r',point_rate);
text(r(1), r(2), r(3), "Camera up")
%r = rc + M_orf2brf'*r_cam_aside*arrow_rate; arrow3(rc', r', 'r',point_rate);
%text(r(1), r(2), r(3), "Camera side")
% Other show
r = spacecrafts(2).r + M_orf2brf'*e_deploy*0.5; arrow3(spacecrafts(2).r', r', 'b',point_rate);
text(r(1), r(2), r(3), "Deploy direction")
% Trajectory show
N = round(1 * t_modeling / dt);
t = dt:dt:t_modeling;
R = zeros(3,N+1); V = zeros(3,N+1);
LOS_in_pic = zeros(3, n_deputy, N); % Line of sight the deputy perp. to r_cam_dir 
LOS_3d     = zeros(3, n_deputy, N); % Line of sight
for j=1:n_deputy
    R(:,1) = chief.r + M_orf2brf' * r_deploy(j) * e_deploy;
    V(:,1) = chief.v + M_orf2brf' * v_deploy(j) * e_deploy;
    for i=1:N
        [dr_, dv_, ~, ~] = d.rhs(R(:,i), V(:,i), zeros(4,1), zeros(3,1));
        V(:,i+1) = V(:,i) + dv_*dt;
        R(:,i+1) = R(:,i) + dr_*dt;
        if i==round(t_modeling / dt) % Как камера смотрит на середины чипсатов
            myplot3([rc R(:,i+1)], 'k')
        end
        LOS = R(:,i+1) - rc;
        % LOS_in_pic(:,j,i) = LOS - (M_orf2brf'*e_deploy) * dot(M_orf2brf'*e_deploy, LOS);
        LOS_in_pic(:,j,i) = LOS - (M_orf2cam'*r_cam_dir) * dot(M_orf2cam'*r_cam_dir, LOS);
        LOS_3d(:,j,i) = LOS;
    end
    myplot3(R, 'b')
end
% Patch show
chief.show_chief(d)
show_cube([0.02;0.02;0.05], M_orf2cam', rc - M_orf2brf'*r_cam_dir*0.025)
camup([0 1 0])
hold off

% Это то, как считается в статье. А на саааааааамом то деле всё по-другому
% Visioned part of deputy in t=t_modeling
deltas = zeros(n_deputy-1, N);
deltas2 = zeros(n_deputy-1, N);
for j=1:(n_deputy-1)
    for i=1:N
        deltas(j,i) = norm(LOS_in_pic(:,j+1,i)-LOS_in_pic(:,j,i)) / spacecrafts(2).dims(1)*100;
        R1 = norm(LOS_3d(:,j+1,i));
        R2 = norm(LOS_3d(:,j,i));
        cos_a = dot(LOS_3d(:,j+1,i), LOS_3d(:,j,i)) / R1 / R2;
        a = acos(cos_a);
        % deltas2(j,i) = R1 * sqrt(1 - cos_a^2);
        deltas2(j,i) = R1 * sin(a)  / spacecrafts(2).dims(1)*100;
    end
end
% disp('Видимая часть чипсата: '+string(deltas1(1))+' м ('+string(deltas1(1)/spacecrafts(2).dims(1)*100)+' %)')
figure()
hold on
l = [];
legend()
for j=1:(n_deputy-1)
    % plot(t, deltas(j,:), 'b')
    plot(t, deltas2(j,:),'DisplayName','ДКА '+string(j+1))
end
xlabel('t, c')
ylabel('Видимая часть чипсата, %')
hold off

% Отображение лучших направлений запусков
tick_rate = 6;
figure()
[azimuth,elevation,r] = cart2sph(ex(1),ex(2),ex(3));
disp('Current phi='+string(elevation)+', theta='+string(azimuth))
phi = 0:(2*pi/N):(2*pi);
theta = (-pi):(2*pi/N):(pi);

counter = 0;
i_list = [2,n_deputy];
t_list = [10,50,100];
D = {};
for i=i_list
    for t=t_list
        counter = counter + 1;
        D{counter} = DeltaDistribution(t,i,dr,dv,v0,d.w_orb,r_camera) / deputy_dims(1) * 100;
        m = min(D{counter}(:)); M = max(D{counter}(:)); [i1,i2]=find(D{counter}==M);
        for j=1:1  % length(i1)
            disp('Max '+string(M)+'in phi='+string(phi(i1(j)))+', theta='+string(theta(i2(j))))
        end
        if counter == 1
            m_ = m; M_ = M;
        else
            m_ = min(m,m_); M_ = max(M,M_);
        end
    end
end
counter = 0;
for i=i_list
    for t=t_list
        counter = counter + 1;
        subplot(length(i_list),length(t_list),counter)
        h = heatmap(D{counter});
        h.XDisplayLabels = repmat({''}, 1, size(D{counter}, 2));
        h.YDisplayLabels = repmat({''}, 1, size(D{counter}, 1));
        title('Видимая часть ДКА '+string(i)+' (t='+string(t)+'), %')
        xlabel('phi')
        ylabel('theta')
        clim([m_, M_]);
    end
end


%% Run of modeling
% Display
f = figure('Color', [0 0 0], 'Position', [200 100 window_size]);
counter_gif_frames = 0;

% Docking
N = round(t_modeling / dt);
CameraPosORF = zeros(N, 3);
ChiefPosORF = zeros(N, 3);
ChiefQuatIRF = zeros(N, 4);
DeputyPosORF = zeros(N, 3 * n_deputy);
DeputyQuatIRF = zeros(N, 4 * n_deputy);
modeling_report = table(CameraPosORF, ChiefPosORF, ChiefQuatIRF, ...
                        DeputyPosORF, DeputyQuatIRF);

for i = 1:N
    % Time step
    [d, spacecrafts] = d.time_step(spacecrafts);

    % SHAMANIZM
    spacecrafts(1).r = zeros(3,1); 
    spacecrafts(1).v = zeros(3,1);
    spacecrafts(1).w = zeros(3,1);
    q_irf2orf = [cos(-d.w_orb*d.t/2), 0, 0, sin(-d.w_orb*d.t/2)];
    spacecrafts(1).q = qdot(q0, q_irf2orf);
    
    % Figure update
    clf;
    colormap('gray');
    camproj('perspective');
    axis equal;
    cameratoolbar("SetMode","pan");  % pan
    light('Style', 'infinite', 'Position', d.R_sun);
    gca.XAxis.Visible = 'off';
    gca.YAxis.Visible = 'off';
    gca.ZAxis.Visible = 'off';
    axis off ;
    hold on;
    
    % Spacecrafts show
    spacecrafts(1).show_chief(d);
    for j = 2:length(spacecrafts)
        spacecrafts(j).show_deputy(j-1, d, markerSize);
    end
    
    % Camera update
    M_orf2brf = spacecrafts(1).ORF2BRF(d);
    M_orf2cam = M_brf2cam * M_orf2brf;
    cam_pos = spacecrafts(1).r + M_orf2brf' * r_camera;
    campos(cam_pos);
    camup(M_orf2cam' * r_cam_up);
    camtarget(cam_pos + M_orf2cam' * r_cam_dir);
    camva(camera_angle);
    hold off;

    % Find Aruco
    % try
    %     saveas(f, 'local/tmp.jpg');
    %     I = imread('local/tmp.jpg');
    %     delete local/tmp.jpg
    %     [ids,locs,poses] = readArucoMarker(I,markerFamily,cameraParams.Intrinsics,markerSize(1));
    %     for ii=1:length(ids)
    %         disp('i='+string(i)+' | Метка id='+string(ids(ii)) + ', r=['+string(poses(ii).Translation(1))+',' ...
    %                                                                     +string(poses(ii).Translation(2))+',' ...
    %                                                                     +string(poses(ii).Translation(3))+'] м')
    %     end
    % catch 
    %      % disp('i='+string(i)+' | Меток не обнаружено!')
    % end

    % Docking
    modeling_report.CameraPosORF(i,:) = cam_pos';
    modeling_report.ChiefPosORF(i,:) = spacecrafts(1).r';
    modeling_report.ChiefQuatIRF(i,:) = spacecrafts(1).q';
    for j=1:n_deputy
        modeling_report.DeputyPosORF(i,3*j-2:3*j) = spacecrafts(j+1).r';
        modeling_report.DeputyQuatIRF(i,4*j-3:4*j) = spacecrafts(j+1).q';
    end

    % Animation
    if mod(i, 100) == 0
        frame = getframe(gcf);
        img =  frame2im(frame);
        [img,cmap] = rgb2ind(img,256);
        if i == 1
            imwrite(img,cmap,'local/animation_chipsat.gif','gif','LoopCount',Inf,'DelayTime',0.001);
        else
            imwrite(img,cmap,'local/animation_chipsat.gif','gif','WriteMode','append','DelayTime',0.001);
        end        
    end
end

%% Plot the results
figure
hold on
spacecrafts(1).show_chief(d);
plot3(modeling_report.ChiefPosORF(:,1), modeling_report.ChiefPosORF(:,2), modeling_report.ChiefPosORF(:,3), 'k');
for j = 1:n_deputy
    plot3(modeling_report.DeputyPosORF(:,3*j-2), modeling_report.DeputyPosORF(:,3*j-1), modeling_report.DeputyPosORF(:,3*j), 'b');
end
xlabel('x, m')
ylabel('y, m')
zlabel('z, m')
colormap('gray');
axis equal;
hold off