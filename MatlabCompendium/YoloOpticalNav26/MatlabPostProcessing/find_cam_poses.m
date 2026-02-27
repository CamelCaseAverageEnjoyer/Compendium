clear
clc
close all
markerFamily = "DICT_4X4_50";
markerSizeInMM = 138;

load("local/camcal/cameraParams_cam1.mat")
load("local/camcal/cameraParams_cam2.mat")
load("local/camcal/cameraParams_cam3.mat")

%% Нахождение меток на кадрах
I = imread("local/camcal/cam1_aruco.jpg"); 
camIntrinsics = cameraParams_cam1.Intrinsics;
[id1,loc1,pos1] = readArucoMarker(I,markerFamily,camIntrinsics,markerSizeInMM);
disp("Камера 1: найдена метка id="+string(id1))
I = insertShape(I,"polygon",{loc1},Opacity=1,ShapeColor="green",LineWidth=4);
I = insertText(I,mean(loc1),id1,FontSize=50,BoxOpacity=1);
worldPoints = [0 0 0; markerSizeInMM/2 0 0; 0 markerSizeInMM/2 0; 0 0 markerSizeInMM/2];
imagePoints = world2img(worldPoints,pos1,camIntrinsics);     
axesPoints = [imagePoints(1,:) imagePoints(2,:);
              imagePoints(1,:) imagePoints(3,:);
              imagePoints(1,:) imagePoints(4,:)];
I = insertShape(I, "Line", axesPoints, Color = ["red","green","blue"], LineWidth=10);
figure('Toolbar', 'none', 'Menubar', 'none'); imshow(I);

I = imread("local/camcal/cam2_aruco.jpg");
camIntrinsics = cameraParams_cam2.Intrinsics;
[id2,loc2,pos2] = readArucoMarker(I,markerFamily,camIntrinsics,markerSizeInMM);
for i=1:2
    disp("Камера 2: найдена метка id="+string(id2(i)))
    I = insertShape(I,"polygon",{loc2(:,:,i)},Opacity=1,ShapeColor="green",LineWidth=4);
    I = insertText(I,mean(loc2(:,:,i)),id2(i),FontSize=50,BoxOpacity=1);
    imagePoints = world2img(worldPoints,pos2(i),camIntrinsics);     
    axesPoints = [imagePoints(1,:) imagePoints(2,:);
                  imagePoints(1,:) imagePoints(3,:);
                  imagePoints(1,:) imagePoints(4,:)];
    I = insertShape(I, "Line", axesPoints, Color = ["red","green","blue"], LineWidth=10);
end
figure('Toolbar', 'none', 'Menubar', 'none'); imshow(I);


I = imread("local/camcal/cam3_aruco.jpg");
camIntrinsics = cameraParams_cam3.Intrinsics;
[id3,loc3,pos3] = readArucoMarker(I,markerFamily,camIntrinsics,markerSizeInMM);
disp("Камера 3: найдена метка id="+string(id3))
I = insertShape(I,"polygon",{loc3},Opacity=1,ShapeColor="green",LineWidth=4);
I = insertText(I,mean(loc3),id3,FontSize=50,BoxOpacity=1);
imagePoints = world2img(worldPoints,pos3,camIntrinsics);     
axesPoints = [imagePoints(1,:) imagePoints(2,:);
              imagePoints(1,:) imagePoints(3,:);
              imagePoints(1,:) imagePoints(4,:)];
I = insertShape(I, "Line", axesPoints, Color = ["red","green","blue"], LineWidth=10);
figure('Toolbar', 'none', 'Menubar', 'none'); imshow(I);

%% Определение положений камер в СК меток
cam1_pos_Aru3RF = - pos1.R' * pos1.Translation';
cam2_pos_Aru4RF = - pos2(1).R' * pos2(1).Translation';  % id2=[->4,  0]
cam2_pos_Aru0RF = - pos2(2).R' * pos2(2).Translation';  % id2=[  4,->0]
cam3_pos_Aru4RF = - pos3.R' * pos3.Translation';

%% 3D-отображение
cam1_near_pos = [-4289; 0; 1081];
cam2_near_pos = [-3845; -902; 0];
cam3_near_pos = [-2863; 443; 0];

import graphics.* 
figure('Position', [100 100 1500 900], 'Toolbar', 'none', 'Menubar', 'none'); hold on;
xlabel('x, мм');    ylabel('y, мм');    zlabel('z, мм')
colormap('gray'); 
camproj('orthographic'); cameratoolbar("SetMode","orbit"); camup([0 1 0]); 
campos([-3000; 3000; 3000]); camtarget([-4000; 0; 0]); % camva(50);

A1 = eye(3);
marker1_pos_SM = [-4309; 167; -1087] + ...  % Низ-право панели 429
                 [-(95+233)/2; (193+331)/2; 0];  % Положение Aruco ID 3 на панели
marker_id3 = generateArucoMarker(markerFamily,3,6) / 255;
r1 = marker1_pos_SM + A1 * cam1_pos_Aru3RF;

A2 = [0 -1 0; 0 0 -1; 1 0 0];
marker2_pos_SM = [-3571; 1437; -471] + ...  % Угол панели 330
                 [-(155+293)/2; 0; (303+441)/2];  % Положение Aruco ID 0 на панели
marker_id0 = generateArucoMarker(markerFamily,0,6) / 255;
r2 = marker2_pos_SM + A2 * cam2_pos_Aru0RF;

A3 = [0 0 1; 0 1 0; -1 0 0];
marker3_pos_SM = [-4964; -879; 739] + ...  %  Срез Д11-Д11, низ панели медотсека
                 [0; (1153+1015)/2; (212+74)/2];  % Положение Aruco ID 4 на панели
marker_id4 = generateArucoMarker(markerFamily,4,6) / 255;
r3 = marker3_pos_SM + A3 * cam3_pos_Aru4RF;
r2_1 = marker3_pos_SM + A3 * cam2_pos_Aru4RF;

% Отображение точек камер %
scatter3(r1(1),r1(2),r1(3),60,'b');
scatter3(r2(1),r2(2),r2(3),60,'r');
scatter3(r3(1),r3(2),r3(3),60,'g');
scatter3(cam1_near_pos(1),cam1_near_pos(2),cam1_near_pos(3),60,'b','filled');
scatter3(cam2_near_pos(1),cam2_near_pos(2),cam2_near_pos(3),60,'r','filled');
scatter3(cam3_near_pos(1),cam3_near_pos(2),cam3_near_pos(3),60,'g','filled');
scatter3(r2_1(1),r2_1(2),r2_1(3),60,'r');

% Отбражение линий камеры-метки %
myplot3([marker1_pos_SM r1]', 'color', 'b');
myplot3([marker2_pos_SM r2]', 'color', 'r');
myplot3([marker3_pos_SM r3]', 'color', 'g');
myplot3([marker3_pos_SM r2_1]', 'color', 'r');

% Отображение Aruco-меток
show_aruco(markerSizeInMM*1, A1, marker1_pos_SM, marker_id3)
show_aruco(markerSizeInMM*1, A2, marker2_pos_SM, marker_id0)
show_aruco(markerSizeInMM*1, A3, marker3_pos_SM, marker_id4)

% Отображение стенок модуля
x = [-2863, -2863, -2863, -2863, -4964, -4964, -4964, -2863, -2863;
     -2863, -2863, -2863, -2863, -4964, -4964, -4964, -2863, -2863;
     -4964, -4964, -4964, -4964, -4964, -4964, -4964, -2863, -2863;
     -4964, -4964, -4964, -4964, -4964, -4964, -4964, -2863, -2863];
y = [-902,   1437,  1437,  1437,  1437,  -902,  -902,  1437,  1437;
     -902,   1437,  -902,  -902,   905,   905,   905,  1437,  1437;
     -902,   1437,  -902,  -902,   905,   905,   905,  -902,  -902;
     -902,   1437,  1437,  1437,  1437,  -902,  -902,  -902,  -902];
z = [1081,   1081,  1081, -1086, -1086,   739,  -746,  1081, -1086;
    -1086,  -1086,  1081, -1086, -1086,   739,  -746,   443,  -443;
    -1086,  -1086,  1081, -1086,  1081,  1081, -1086,   443,  -443; 
     1081,   1081,  1081, -1086,  1081,  1081, -1086,  1081, -1086];
alpha = 0.3; c = zeros(1, size(x,2)) * 0.5;
p1 = patch(x,y,z,c,'FaceAlpha',alpha);

legend(["Камера 1 (по Aruco)", "Камера 2 (по Aruco)", "Камера 3 (по Aruco)", ...
        "Камера 1 (очень примерно)", "Камера 2 (очень примерно)", "Камера 3 (очень примерно)"])
axis equal; hold off