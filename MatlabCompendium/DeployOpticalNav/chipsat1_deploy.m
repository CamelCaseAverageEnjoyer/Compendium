clear
clc
close all
import utils.*

%% Params of display
window_size = [1280 720];
camera_angle = 90;
load('local/cameraParams')

%% Params of modeling
% Dynamic system
h_orb = 400e3;
dt = 0.5;
t_modeling = 1000;
d = dynamics(h_orb, dt);  % Class of dynamics
i = 1/sqrt(2);

% Chief spacecraft vectors
markerFamily = "DICT_4X4_50";
markerSize = [0.03, 0.03];
r0 = zeros(3,1);
v0 = zeros(3,1);
q0 = [1; 0; 0; 0];
w0 = [0; 0; d.w_orb];
% r_deploy = [0.15; 0; 0];
e_deploy = [1; 0; 0];
q_deploy = [i; 0; -i; 0];
% r_camera = [0.4;0.4;0];
r_camera = [-0.2;0.25;0];
r_cam_dir = [1;-0.2;0];
r_cam_up = [0;1;0];
chief = spacecraft(r0,v0,q0,w0,3,[0.3; 0.1; 0.1]);
spacecrafts = chief;

% Deputy pacecrafts
n_deputy = 10;
% t_deploy = 0:30:30*(n_deputy-1);  % in sec
r_deploy = (0:0.01:0.01*(n_deputy-1)) + (0.15 - 0.001*(n_deputy-1));  % in m
v_deploy = 0:0.001:0.001*(n_deputy-1);  % in m/s
% q_irf2orf = [cos(-d.w_orb*d.t/2); 0; 0; sin(-d.w_orb*d.t/2)];
for j = 1:n_deputy
    M = chief.ORF2BRF(d);
    r = chief.r + M' * e_deploy * r_deploy(j);
    v = chief.v + M' * e_deploy * v_deploy(j);
    q = q_deploy;  % q = qdot(q_deploy, q_irf2orf);
    w = chief.w;
    deputy = spacecraft(r, v, q, w, 0.01, [0.1; 0.1; 0.001]);
    disp('Отделение: r=['+string(r(1))+','+string(r(2))+','+string(r(3))+'], v='+string(v(1))+','+string(v(2))+','+string(v(3))+']')
    spacecrafts = [spacecrafts, deputy];
end

%% Find the trajectory
figure; hold on
for j=1:n_deputy
    M = spacecrafts(1).ORF2BRF(d);
    r = spacecrafts(1).r + M' * r_deploy(j) * e_deploy;
    v = spacecrafts(1).v + M' * v_deploy(j) * e_deploy;
    X  = r(1); Y  = r(2); Z  = r(3);
    Vx = v(1); Vy = v(2); Vz = v(3);
    for i=1:round(t_modeling / dt)
        t = i*dt;
        Vx = [Vx (Vx(length(Vx)) + (-2 * d.w_orb * Vy(length(Vy)))*dt)];
        Vy = [Vy (Vy(length(Vy)) + (3 * d.w_orb^2 * Y(length(Y)) + 2 * d.w_orb * Vx(length(Vx)))*dt)];
        Vz = [Vz (Vz(length(Vz)) + (-d.w_orb^2 * Z(length(Z)))*dt)];
        X = [X (X(length(X)) + Vx(length(Vx))*dt)];
        Y = [Y (Y(length(Y)) + Vy(length(Vy))*dt)];
        Z = [Z (Z(length(Z)) + Vz(length(Vz))*dt)];
    end
    plot3(X,Y,Z)
end
axis equal
xlabel('x, m')
ylabel('y, m')
zlabel('z, m')
hold off


%% Run of modeling
% Display
f = figure('Color', [0 0 0], 'Position', [200 100 window_size]);

% Docking
N = round(t_modeling / dt);
CameraPosORF = zeros(N, 3);
ChiefPosORF = zeros(N, 3);
modeling_report = table(CameraPosORF, ChiefPosORF);

for i = 1:N
    % Time step
    [d, spacecrafts] = d.time_step(spacecrafts);
    % SHAMANIZM
    spacecrafts(1).r = r0;
    spacecrafts(1).v = v0;
    % spacecrafts(1).q = q0;
    q_irf2orf = [cos(-d.w_orb*d.t/2); 0; 0; sin(-d.w_orb*d.t/2)];
    spacecrafts(1).q = qdot(q0, q_irf2orf);
    spacecrafts(1).w = w0;
    
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
    M = spacecrafts(1).ORF2BRF(d);
    cam_pos = spacecrafts(1).r + M' * r_camera;
    campos(cam_pos);
    camup(M' * r_cam_up);
    camtarget(cam_pos + M' * r_cam_dir);
    camva(camera_angle);
    hold off;

    % Find Aruco
    try
        saveas(f, 'local/tmp.jpg');
        I = imread('local/tmp.jpg');
        [ids,locs,poses] = readArucoMarker(I,markerFamily,cameraParams.Intrinsics,markerSize(1));
        for ii=1:length(ids)
            disp('i='+string(i)+' | Метка id='+string(ids(ii)) + ', r=['+string(poses(ii).Translation(1))+',' ...
                                                                        +string(poses(ii).Translation(2))+',' ...
                                                                        +string(poses(ii).Translation(3))+'] м')
        end
    catch 
         % disp('i='+string(i)+' | Меток не обнаружено!')
    end

    % Docking
    modeling_report.CameraPosORF(i,:) = cam_pos';
    modeling_report.ChiefPosORF(i,:) = spacecrafts(1).r';

    % Animation
    frame = getframe(gcf);
    img =  frame2im(frame);
    [img,cmap] = rgb2ind(img,256);
    if i == 1
        imwrite(img,cmap,'local/animation_chipsat.gif','gif','LoopCount',Inf,'DelayTime',0.0001);
    else
        imwrite(img,cmap,'local/animation_chipsat.gif','gif','WriteMode','append','DelayTime',0.0001);
    end
end

delete local/tmp.jpg

