%% Params of display  
window_size = [1280 720];  % (not)pixels
camera_angle = 90;  % degree

h_orb = 400e3;

% Starlink params

% ChipSat params
markerFamily = "DICT_4X4_50";
markerSize = [0.02, 0.02];

% CubeSat params
import my_utils.*
chief_dims = [0.3; 0.1; 0.1];
e_deploy = unitVec([1; 0; 0]);     % в ССК

ex = unitVec([1; 0; 0.]);         % Ox ССК в ОСК
ey = unitVec(cross([0;0;1], ex));  % Oy ССК в ОСК
ez = unitVec(cross(ex, ey));       % Oz ССК в ОСК
M_orf2brf = [ex ey ez]';
q_orf2brf = dcm2quat(M_orf2brf);
q_irf2orf = [1, 0, 0, 0];
q_irf2brf = quatmultiply(q_orf2brf, q_irf2orf);
clear ey ez;

% CubeSat camera params
% r_camera = [0.14;0.05;0];        % центр СК-кам в ССК
r_camera = [0;0;0];        % центр СК-кам в ССК
r_cam_dir = unitVec([1;-0.2;0]); % Оz СК-кам в ССК
r_cam_up = [0;1;0];              % перп. Ox СК-кам

r_cam_aside = unitVec(cross(r_cam_up, r_cam_dir)); % Ox СК-кам в ССК
r_cam_up = unitVec(cross(r_cam_dir, r_cam_aside)); % Oy СК-кам в ССК
M_brf2cam = [r_cam_aside r_cam_up r_cam_dir]';

% ChipSat deploy params
deputy_dims = [0.08; 0.08; 0.002];
v0 = 0.001;   % m/s
dv = 0.0001;  % m/s
dr = 0.005;    % m
q_chief2deputy = [1/sqrt(2), 0, -1/sqrt(2), 0];  % Chipsat relative to CubeSat
q_irf2deputy = quatmultiply(q_chief2deputy, q_irf2brf);
