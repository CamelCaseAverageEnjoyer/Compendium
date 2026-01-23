clear
clc
close all
% config  % const params loading
% import utils.* 
markerFamily = "DICT_4X4_50";
markerSizeInMM = 138;

load("local/camcal/cameraParams_cam1.mat")
load("local/camcal/cameraParams_cam2.mat")
load("local/camcal/cameraParams_cam3.mat")
camIntrinsics = {cameraParams_cam1.Intrinsics;
                 cameraParams_cam2.Intrinsics; 
                 cameraParams_cam3.Intrinsics};

%% Нахождение меток на кадрах
I = imread("local/camcal/cam1_aruco.jpg");
[id1,loc1,pos1] = readArucoMarker(I,markerFamily,camIntrinsics{1},markerSizeInMM);
disp("Камера 1: найдена метка id="+string(id1))
I = insertShape(I,"polygon",{loc1},Opacity=1,ShapeColor="green",LineWidth=4);
I = insertText(I,mean(loc1),id1,FontSize=50,BoxOpacity=1);
figure; imshow(I);

I = imread("local/camcal/cam2_aruco.jpg");
[id2,loc2,pos2] = readArucoMarker(I,markerFamily,camIntrinsics{2},markerSizeInMM);
for i=1:2
    disp("Камера 2: найдена метка id="+string(id2(i)))
    I = insertShape(I,"polygon",{loc2(:,:,i)},Opacity=1,ShapeColor="green",LineWidth=4);
    I = insertText(I,mean(loc2(:,:,i)),id2(i),FontSize=50,BoxOpacity=1);
    figure; imshow(I);
end

I = imread("local/camcal/cam3_aruco.jpg");
[id3,loc3,pos3] = readArucoMarker(I,markerFamily,camIntrinsics{3},markerSizeInMM);
disp("Камера 2: найдена метка id="+string(id3))
I = insertShape(I,"polygon",{loc3},Opacity=1,ShapeColor="green",LineWidth=4);
I = insertText(I,mean(loc3),id3,FontSize=50,BoxOpacity=1);
figure; imshow(I);

%% Определение положений камер в СК меток
cam1_pos_Aru3RF = - pos1.R' * pos1.Translation';
cam2_pos_Aru4RF = - pos2(1).R' * pos2(1).Translation';  % id2=[4,0]
cam2_pos_Aru0RF = - pos2(2).R' * pos2(2).Translation';  % id2=[4,0]
cam3_pos_Aru4RF = - pos3.R' * pos3.Translation';

%% 3D-отображение
close all

import graphics.* 
figure('Position', [100 100 1500 900]); hold on;
xlabel('x, мм');    ylabel('y, мм');    zlabel('z, мм')
colormap('gray'); axis equal;
camproj('orthographic'); cameratoolbar("SetMode","orbit"); camup([0 1 0]); 
campos([-3000; 3000; 3000]); camtarget([-4000; 0; 0]); % camva(50);

A1 = eye(3);
markerpos_SM1 = [-4309; 167; -1087] + ...  % Низ-право панели 429
               [-(95+233)/2; (193+331)/2; 0];  % Положение Aruco ID 3 на панели
marker1 = generateArucoMarker(markerFamily,3,6) / 255;
r1 = markerpos_SM1 + A1 * cam1_pos_Aru3RF;


A2 = [1 0 0; 0 0 -1; 0 1 0];
markerpos_SM2 = [-3571; 1437; -471] + ...  % Угол панели 330
               [-(95+233)/2; (193+331)/2; 0];  % Положение Aruco ID 0 на панели
marker2 = generateArucoMarker(markerFamily,0,6) / 255;
r2 = markerpos_SM2 + A2 * cam2_pos_Aru0RF;

A3 = [0 0 1; 0 1 0; -1 0 0];
markerpos_SM3 = [-4964; -879; 739] + ...  %  Срез Д11-Д11, низ панели педотсека
               [-(155+293)/2; 0; (303+441)/2];  % Положение Aruco ID 4 на панели
marker3 = generateArucoMarker(markerFamily,4,6) / 255;
r3 = markerpos_SM3 + A3 * cam3_pos_Aru4RF;
r2_1 = markerpos_SM + A3 * cam2_pos_Aru4RF;

% --------------- %
scatter3(r1(1),r1(2),r1(3),30,'b');
scatter3(r2(1),r2(2),r2(3),30,'r');
scatter3(r3(1),r3(2),r3(3),30,'g');
scatter3(r2_1(1),r2_1(2),r2_1(3),30,'r');

myplot3([markerpos_SM1 r1]', 'color', 'b');
myplot3([markerpos_SM2 r2]', 'color', 'r');
myplot3([markerpos_SM3 r3]', 'color', 'g');
myplot3([markerpos_SM3 r2_1]', 'color', 'r');

show_aruco([markerSizeInMM, markerSizeInMM]*3, A1, markerpos_SM1, zeros(3,1), marker1)
show_aruco([markerSizeInMM, markerSizeInMM]*3, A2, markerpos_SM2, zeros(3,1), marker2)
show_aruco([markerSizeInMM, markerSizeInMM]*3, A3, markerpos_SM3, zeros(3,1), marker3)



legend(["Камера 1", "Камера 2", "Камера 3"])

hold off