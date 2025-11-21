%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading
import graphics.*  % my functions loading

load("local/pre-calibration.mat")  % F (main0)
load("local/calibration-1.mat")  % cam (manual_calibration)
cam{1}.f = F(1);
cam{2}.f = F(2);
cam{3}.f = F(3);

%% 2D plot
h = [figure() figure() figure()];
im = {imread("local/1cam-sample.jpg");
      imread("local/2cam-sample.jpg");
      imread("local/3cam-sample.jpg")};
for icam = 1:3
    figure(h(icam)) 
    imshow(im{icam})
    hold on
    for i = 1:1:size(cam{icam}.points, 1)
        x = cam{icam}.points.pixels(i, 1);
        y = cam{icam}.points.pixels(i, 2);
        text(x + d_text2point*2, y, cam{icam}.points.name{i}, 'Color','green','FontSize',10,'BackgroundColor','black')
        plot(x, y, 'g+', 'MarkerSize', d_text2point, 'LineWidth', 2)
    end
    hold off
end

%% Camera calibration
for icam = 1:3
    % Find parameters
    if icam == 1, dr=1; else, dr=0.05; end
    dk = 0.;
    de = 0.1;
    dc = 0;
    % note: x = [f,cx,cy,a,b,g,k1,k2,x,y,z]
    x0 = [cam{icam}.f, cam{icam}.c, cam{icam}.eulerangs, cam{icam}.k, cam{icam}.pos'];
    lb = [cam{icam}.f/1.3, cam{icam}.c - dc, cam{icam}.eulerangs - de, cam{icam}.k - dk, cam{icam}.pos' - dr];
    ub = [cam{icam}.f*1.3, cam{icam}.c + dc, cam{icam}.eulerangs + de, cam{icam}.k + dk, cam{icam}.pos' + dr];
    fun = @(x)residual(x,cam,icam,true,false);

    % diff_evolve
    anw = diff_evolve(fun, lb, ub, 1000, 200);
    x1 = anw;

    % fmincon
    options = optimset('MaxfunEvals', 100000000, ...
                       'MaxIter', 1000000000, ...
                       'Tolx',1e-15,...  % StepTolerance
                       'TolFun',1e-15,...  % OptimalityTolerance
                       'Algorithm', 'sqp',...
                       'Display', 'final-detailed');
    anw = fmincon(fun,x1,[],[],[],[],lb,ub,[],options);

    disp(fun(anw))
    t = removevars(rows2vars(table((x0)', (x1)', (anw)')), 'OriginalVariableNames');
    t.Properties.VariableNames = {'f', 'cx', 'cy', 'α', 'β', 'γ', 'k1', 'k2', 'x', 'y', 'z'}; % 'k3', 
    t.Data = {'No calibration'; 'Diff evolve'; 'Fmincon'};
    disp(t);

    [cam{icam}.f, cam{icam}.c, cam{icam}.eulerangs, cam{icam}.k, cam{icam}.pos] = myget(anw); 
end

%% Visualize
h = [figure() figure() figure()];
for icam = 1:3
    figure(h(icam));
    imshow(undistort(im{icam},cam,icam))
    hold on
    for i = 1:1:size(cam{icam}.points, 1)
        x = cam{icam}.points.pixels(i, 1);
        y = cam{icam}.points.pixels(i, 2);
        [x,y] = cam{icam}.undistort(x,y,[],[]);
        [x1, y1] = cam{icam}.pos2pixel(cam{icam}.points.pos(i,:)',[],[],[],[]);
        text(x  + d_text2point*2, y,  cam{icam}.points.name{i}, 'Color','green','FontSize',10,'BackgroundColor','black')
        text(x1 + d_text2point*2, y1, cam{icam}.points.name(i), 'Color','blue','FontSize',10,'BackgroundColor','black')
        plot(x,  y,  'g+', 'MarkerSize', d_text2point, 'LineWidth', 2)
        plot(x1, y1, 'b+', 'MarkerSize', d_text2point, 'LineWidth', 2)
        plot([x, x1], [y, y1], 'b', 'LineWidth', 3)
    end
    hold off
end

%% Save
save('local/calibration-2', "cam")





