%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading
import graphics.*  % my functions loading

im = {imread("local/1cam-sample.jpg");
      imread("local/2cam-sample.jpg");
      imread("local/3cam-sample.jpg")};

%% 2D plot
h = [figure() figure() figure()];
for icam = 1:3
    figure(h(icam))
    imshow(im{icam})
    hold on
    for i=1:size(cam{icam}.lines,2)
        A = cam{icam}.lines{i};
        [x,y] = line_least_squares(A,true);
        plot(x, y, 'y', 'LineWidth', 3)
        for j=1:size(cam{icam}.lines{i},1) 
            plot(cam{icam}.lines{i}(j,1),cam{icam}.lines{i}(j,2),'r+', 'MarkerSize', 10, 'LineWidth', 2)
        end
        myplot(cam{icam}.lines{i},'r', 'LineWidth', 1)
    end
    hold off
end


%% Camera calibration
for icam = 1:3
    % x = [cx, cy, k1, k2]
    if icam ~= 1, dk=1; else, dk=1; end
    lb = [cam{icam}.c - 100, -dk, -dk];
    ub = [cam{icam}.c + 100,  dk,  dk];
    fun = @(x)residual(x,cam,icam,false,true);

    % diff_evolve
    anw = diff_evolve(fun, lb, ub, 1000, 30);
    cam{icam}.c = [anw(1) anw(2)];
    cam{icam}.k = [anw(3) anw(4)];
end

%% Visualize
h1 = [figure() figure() figure()];
for icam = 1:3
    figure(h1(icam))
    imshow(undistort(im{icam},cam,icam))
    hold on
    for i=1:size(cam{icam}.lines,2)
        xy = cam{icam}.lines{i} + 0;
        for j=1:size(xy,1)
            [xy(j,1),xy(j,2)] = cam{icam}.undistort(xy(j,1), xy(j,2), [], []);
        end
        A = xy;
        [x,y] = line_least_squares(A,true);
        plot(x, y, 'y', 'LineWidth', 3)
        for j=1:size(cam{icam}.lines{i},1)
            myplot(xy(j,:), 'r+', 'MarkerSize', 10, 'LineWidth', 2)
        end
        myplot(xy, 'r', 'LineWidth', 1)
    end
    hold off
end

%% Save
save('local/calibration-1', "cam")





