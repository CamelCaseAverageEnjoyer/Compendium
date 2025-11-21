%% Params of display
clear
clc
close all
import utils.*

window_size = [1280 720];
camera_angle = 90;

%% Produce pictures
f = figure('Color', [1 1 1], 'Position', [100 100 window_size]);
set(gca,'Color','white');
colormap('gray');

marker = [1 0 1 0 1 0 1 0 1 0;
          0 1 0 1 0 1 0 1 0 1;
          1 0 1 0 1 0 1 0 1 0;
          0 1 0 1 0 1 0 1 0 1;
          1 0 1 0 1 0 1 0 1 0;
          0 1 0 1 0 1 0 1 0 1;
          1 0 1 0 1 0 1 0 1 0;
          0 1 0 1 0 1 0 1 0 1;
          1 0 1 0 1 0 1 0 1 0;
          0 1 0 1 0 1 0 1 0 1;
          1 0 1 0 1 0 1 0 1 0;
          0 1 0 1 0 1 0 1 0 1;];

% 250мм на 10 ячеек (300мм на 12) -> 25мм на 1 ячейку
dims = [0.30, 0.25];
A = [0 0 1;
     1 0 0;
     0 1 0];
a = 0.5;
B = {[cos(a) 0 -sin(a); 0 1 0; sin(a) 0 cos(a)];
     [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1];
     [cos(-a) 0 -sin(-a); 0 1 0; sin(-a) 0 cos(-a)];
     [cos(-a) -sin(-a) 0; sin(-a) cos(-a) 0; 0 0 1]};
counter = 0;
for x = 0.4:0.2:0.6
    for y = -0.2:0.2:0.2
        for z = -0.2:0.2:0.2
            for i = 1:4
                clf
                % Camera update
                campos([0 0 0]);
                camup([0 0 1]);
                camtarget([1 0 0]);
                camva(camera_angle);
                camproj('perspective');
                cameratoolbar("SetMode","pan");
                set(gca,'visible','off');
                axis equal;
        
                show_aruco(dims, B{i}*A, [x;y;z], [0;0;0], marker)
                
                counter = counter + 1;
                saveas(f, 'local/camcal/' + string(counter) + '.jpg');
            end
        end
    end
end
close all

%% Calibration
cameraCalibrator 

%%
save('local/cameraParams', "cameraParams")

%% Check camera calibration
close all
clc
load('local/cameraParams')

markerFamily = "DICT_4X4_250";
id = 42;
marker = generateArucoMarker(markerFamily,id,6) / 255;

f = figure('Color', [1 1 1], 'Position', [100 100 window_size]);
set(gca,'Color','white');
colormap('gray');

dims = [0.2, 0.2];
markerSize = 0.2;
a = 0.5;
B = {[cos(a) 0 -sin(a); 0 1 0; sin(a) 0 cos(a)]; [cos(a) -sin(a) 0; sin(a) cos(a) 0; 0 0 1]};
A = [1 0 0; 0 -1 0; 0 0 -1];
counter = 0;
for z = 0.7:0.2:0.9
    for y = -0.2:0.4:0.2
        for x = -0.2:0.4:0.2
            for i = 1:2
                clf
                % Вроде это стандартные параметры для камеры (СК = CК Камеры)
                campos([0 0 0]);
                camup([0 1 0]);
                camtarget([0 0 1]);
                camva(camera_angle);
                camproj('perspective');
                cameratoolbar("SetMode","pan");
                set(gca,'visible','off');
                axis equal;
        
                show_aruco(dims, B{i}*A, [x;y;z], [0;0;0], marker)
                
                counter = counter + 1;
                % pause(0.1);
                saveas(f, 'local/camcalcheck/' + string(counter) + '.jpg');
                I = imread('local/camcalcheck/' + string(counter) + '.jpg');
                [ids,locs,poses] = readArucoMarker(I,markerFamily,cameraParams.Intrinsics,markerSize);
                
                real_pose = ([-1 0 0; 0 -1 0; 0 0 1] * [x y z]')';
                disp('Метка id='+string(ids) + ', Δr=' + string(norm(poses.Translation - real_pose)) + ' м')
                disp(real_pose)
                disp(poses.Translation)

                worldPoints = [0 0 0; markerSize/2 0 0; 0 markerSize/2 0; 0 0 markerSize/2];
                imagePoints = world2img(worldPoints,poses,cameraParams.Intrinsics);
                axesPoints = [imagePoints(1,:) imagePoints(2,:);
                              imagePoints(1,:) imagePoints(3,:);
                              imagePoints(1,:) imagePoints(4,:)];
                I = insertShape(I, "Line", axesPoints, Color = ["red","green","blue"], LineWidth=10);
                imwrite(I, 'local/camcalcheck/' + string(counter) + '.jpg');
            end
        end
    end
end
close all


