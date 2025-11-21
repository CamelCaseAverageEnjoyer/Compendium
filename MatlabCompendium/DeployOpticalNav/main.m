clear;

%% Params of display
window_size = [900 600];
camera_angle = 50;
is_animate = false;

%% Params of modeling
% Dynamic system
h_orb = 400 * 1000;
dt = 0.5;
t_modeling = 40;
d = dynamics(h_orb, dt);  % Class of dynamics

% Spacecrafts
n_deputy = 3;
t_deploy_deputy = [0, 0, 0];  % in sec
if_deployed_deputy = [false false false];
r_orf_deputy = [[0;0.1;0.1], [0;0.1;0.1], [0;0.1;0.1]];  % in m
v_orf_deputy = [[0;0.09;0], [0;0.06;0], [0;0.03;0]];  % in m/s
i = 1/sqrt(2);
q_irf_deputy = [[-i;i;0;0], [-i;i;0;0], [-i;i;0;0]];
w_orf_deputy = [[0;0;0], [0;0;0], [0;0;0]];

r_orf_chief = [0;0;0];
v_orf_chief = [0;0;0];
q_irf_chief = [1;0;0;0];
w_orf_chief = [0;0;0];
c = spacecraft(d,r_orf_chief,v_orf_chief,q_irf_chief,w_orf_chief);
c.cam_pos = [0.3;-1.5;0.3];
c.cam_dir = [-0.1;0.6;-0.01];
c.cam_up = [0;0;1];
spacecrafts = [c];  % c variable is no more useful (delete it)

%% Run of display
figure('Color', [1 1 1], 'Position', [200 100 window_size]);
set(gca,'Color','white');
colormap('gray');
camproj('perspective');
axis equal;
cameratoolbar("SetMode","pan");
light('Style', 'local', 'Position', d.R_sun);
set(gca,'visible','off');
gca.XAxis.Visible = 'off';
gca.YAxis.Visible = 'off';
gca.ZAxis.Visible = 'off';
% axis off ;
% box off

% Animation
if is_animate
    myVideo = VideoWriter("result");
    myVideo.FrameRate = 60;
    open(myVideo)
end

%% Run of modeling
N = round(t_modeling / dt);

% Docking
names = ["campos", "chief r"];
CameraPosIRF = zeros(N, 3);
ChiefPosIRF = zeros(N, 3);
CameraPosORF = zeros(N, 3);
ChiefPosORF = zeros(N, 3);
modeling_report = table(CameraPosIRF, CameraPosORF, ChiefPosIRF, ChiefPosORF);

for i = 1:N
    % Deploying
    for j = 1:n_deputy
        if and(if_deployed_deputy(j) == false, d.t >= t_deploy_deputy(j))
            if_deployed_deputy(j) = true;
            tmp = spacecraft(d,r_orf_deputy(:,j),v_orf_deputy(:,j), ...
                               q_irf_deputy(:,j),w_orf_deputy(:,j));
            spacecrafts = [spacecrafts, tmp];
        end
    end

    % Time step
    [d, spacecrafts] = d.time_step(spacecrafts);

    clf;
    hold on;

    % Earth show
    [X,Y,Z] = sphere(20);
    fvc = surf2patch(X * d.r_earth, Y * d.r_earth, Z * d.r_earth);
    % patch('Faces', fvc.faces, 'Vertices', fvc.vertices, 'FaceColor', [0.5, 0.5, 0.5])
    
    % Spacecrafts show
    spacecrafts(1).show_chief();
    for j = 2:length(spacecrafts)
        spacecrafts(j).show_deputy();
    end
    
    % Camera update
    cam_pos = spacecrafts(1).get_campos_irf();
    campos(cam_pos);
    camup(spacecrafts(1).get_camup_irf());
    camtarget(cam_pos + spacecrafts(1).get_camdir_irf());
    camva(camera_angle);
    light('Style', 'local', 'Position', d.R_sun);

    axis equal;
    axis off ;
    hold off;
    pause(0.001);

    % Docking
    modeling_report.CameraPosIRF(i,:) = cam_pos';
    modeling_report.CameraPosORF(i,:) = d.i2o_r(cam_pos)';
    modeling_report.ChiefPosIRF(i,:) = spacecrafts(1).r_irf';
    modeling_report.ChiefPosORF(i,:) = d.i2o_r(spacecrafts(1).r_irf)';

    % Animation
    if and(i > 1, is_animate)  % Workaround (instead: frame doesn't fit to 900x600)
        frame = getframe(gcf);
        writeVideo(myVideo, frame);
    end
end
if is_animate
    close(myVideo);
end

%% Additional plots
% Plots of trajectories (from table of docking)
% figure('Color', [1 1 1], 'Position', [10 10 900 600]);
% tiledlayout(1,2);
% 
% ax1 = nexttile; 
% plot3(ax1, modeling_report.CameraPosIRF(:,1),modeling_report.CameraPosIRF(:,2),modeling_report.CameraPosIRF(:,3),'--', ...
%       modeling_report.ChiefPosIRF(:,1),modeling_report.ChiefPosIRF(:,2),modeling_report.ChiefPosIRF(:,3));
% legend(["CameraPos", "ChiefPos"]);
% axis equal;
% title(ax1,'IRF trajectories')
% 
% ax2 = nexttile; 
% plot3(ax2, modeling_report.CameraPosORF(:,1),modeling_report.CameraPosORF(:,2),modeling_report.CameraPosORF(:,3),'--', ...
%       modeling_report.ChiefPosORF(:,1),modeling_report.ChiefPosORF(:,2),modeling_report.ChiefPosORF(:,3));
% legend(["CameraPos", "ChiefPos"]);
% title(ax2,'ORF trajectories')

% Plots of constant values (testing)
% figure('Color', [1 1 1], 'Position', [50 50 900 600]);
% hold on;
% plot(modeling_report.CameraPosORF(:,1) - modeling_report.ChiefPosORF(:,1))
% plot(modeling_report.CameraPosORF(:,2) - modeling_report.ChiefPosORF(:,2))
% plot(modeling_report.CameraPosORF(:,3) - modeling_report.ChiefPosORF(:,3))
% hold off;
% legend(["x", "y", "z"]);

