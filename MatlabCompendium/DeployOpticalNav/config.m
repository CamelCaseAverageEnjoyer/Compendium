%% Params of display  
window_size = [1280 720];  % (not)pixels
% window_size = [1920 1080];  % (not)pixels
camera_angle = 90;  % degree

h_orb = 400e3;

% Starlink params

% ChipSat params
markerFamily = "DICT_4X4_50";
markerSize = [0.02, 0.02];
deputy_dims = [0.08; 0.08; 0.002];
marker_pos = [deputy_dims(1)/2 - markerSize(1)/2 - 0.001; % Its position on deputy spacecraft
              deputy_dims(2)/2 - markerSize(2)/2 - 0.001; 
              deputy_dims(3)/2 + 0.000001];

% CubeSat params
import project_utils.*
chief_dims = [0.3; 0.1; 0.1];
e_deploy = unitVec([1; 0; 0]);     % в ССК
e_spread = unitVec([1; 0; 0]);     % в ССК

ex = unitVec([1; 0; 0.]);          % Ox ССК в ОСК
ey = unitVec(cross([0;0;1], ex));  % Oy ССК в ОСК
ez = unitVec(cross(ex, ey));       % Oz ССК в ОСК
M_orf2brf = [ex ey ez]';
M_irf2orf = eye(3);
M_irf2brf = M_orf2brf * M_irf2orf;
clear ex ey ez;

% CubeSat camera params
r_camera = [0.15;0.05;0.03];       % центр СК-кам в ССК
% r_camera = [0;0;0];              % центр СК-кам в ССК
% r_camera = [0.15;-0.05;0];       % центр СК-кам в ССК
% r_camera = [0;0.05;0];           % центр СК-кам в ССК
e_cam_dir = unitVec([1;-0.8;0]); % Оz СК-кам в ССК
% e_cam_dir = unitVec([1;0;0]);    % Оz СК-кам в ССК

e_cam_aside = unitVec(cross([0;1;0], e_cam_dir)); % Ox СК-кам в ССК
e_cam_up = unitVec(cross(e_cam_dir, e_cam_aside)); % Oy СК-кам в ССК
M_brf2cam = [-1  0  0;
              0 -1  0;
              0  0  1] * [e_cam_aside e_cam_up e_cam_dir]';
M_orf2cam = M_brf2cam * M_orf2brf;


% ChipSat deploy params
v0 = 0.01;   % m/s
dv = v0/10;  % m/s
dr = 0.01;    % m
M_brf2dep = [0 0 1;
             0 1 0;
            -1 0 0];  % Chipsat orienation relative to CubeSat
M_orf2dep = M_brf2dep * M_orf2brf;
