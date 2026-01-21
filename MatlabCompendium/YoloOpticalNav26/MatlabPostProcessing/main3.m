%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading

clear cam
% load("local/calibration-1")  % cam{icam} - Camera class
load("local/calibration-2")  % cam{icam} - Camera class
load("local/trajectories-2D")  % T{iexp,icam} - trajectories

%% Calculation
for iexp=1:2
    for icam=1:3
        df = T{iexp, icam};

        [df.x0_und, df.y0_und] = cam{icam}.undistort(df.x0, df.y0, [], []);
        [df.x1_und, df.y1_und] = cam{icam}.undistort(df.x1, df.y1, [], []);
        df.x = (df.x0_und + df.x1_und)/2;
        df.y = (df.y0_und + df.y1_und)/2;
        df.d = (df.x1_und - df.x0_und + df.y1_und - df.y0_und) / 2;
        df.Z = cam{icam}.f * ball.d{iexp} ./ df.d;
        df.X = (df.x - cam{icam}.c(1)) .* df.Z / cam{icam}.f;
        df.Y = (df.y - cam{icam}.c(2)) .* df.Z / cam{icam}.f;
        df.R_cam = [df.X df.Y df.Z];
        df.R_mlm = cam{icam}.cam2mlm(df.R_cam',[],[])';

        T{iexp, icam} = df;
    end
end

%% Visualisation
c = 'g';
L = min([size(T{1,1},1), size(T{1,2},1), size(T{1,3},1), size(T{2,1},1), size(T{2,2},1), size(T{2,3},1)]);
for iexp=1:2
    R.cam1 = T{iexp,1}.R_mlm(1:L,:);
    R.cam2 = T{iexp,2}.R_mlm(1:L,:);
    R.cam3 = T{iexp,3}.R_mlm(1:L,:);

    fig = figure('Position', [(50 + 700*(iexp-1)) 50 700 500]);
    tb = cameratoolbar(fig);
    hold on
    for icam=1:3
        plot3(T{iexp,icam}.R_mlm(:,1), T{iexp,icam}.R_mlm(:,2), T{iexp,icam}.R_mlm(:,3))
    end
%     for i=1:500:L
%         plot3([R.cam1(i,1); R.cam2(i,1)], [R.cam1(i,2); R.cam2(i,2)], [R.cam1(i,3); R.cam2(i,3)], c)
%         plot3([R.cam1(i,1); R.cam3(i,1)], [R.cam1(i,2); R.cam3(i,2)], [R.cam1(i,3); R.cam3(i,3)], c)
%         plot3([R.cam3(i,1); R.cam2(i,1)], [R.cam3(i,2); R.cam2(i,2)], [R.cam3(i,3); R.cam2(i,3)], c)
%     end
    hold off
    xlabel('x, м')
    ylabel('y, м')
    zlabel('z, м')
    legend({'Камера 1','Камера 2','Камера 3'})
    axis equal
    grid on
    cameratoolbar("SetCoordSys", "y")
end

%% Second calibration
% note: x = [f,cx,cy,a,b,g,k1,k2,x,y,z,
%            f,cx,cy,a,b,g,k1,k2,x,y,z,
%            f,cx,cy,a,b,g,k1,k2,x,y,z,];

df = 1.1;
dk = 0.1;
dc = 10;
de = 0.01;
dr1 = 0.1;
dr2 = 0.01;

% df = 1;
% dk = 0;
% dc = 0;
% de = 0;
% dr1 = 0;
% dr2 = 0;

x0 = [cam{1}.f, cam{1}.c, cam{1}.eulerangs, cam{1}.k, cam{1}.pos', ...
      cam{2}.f, cam{2}.c, cam{2}.eulerangs, cam{2}.k, cam{2}.pos', ...
      cam{3}.f, cam{3}.c, cam{3}.eulerangs, cam{3}.k, cam{3}.pos'];


lb = [cam{1}.f/df, cam{1}.c - dc, cam{1}.eulerangs - de, cam{1}.k - dk, cam{1}.pos' - dr1, ...
      cam{2}.f/df, cam{2}.c - dc, cam{2}.eulerangs - de, cam{2}.k - dk, cam{2}.pos' - dr2, ...
      cam{3}.f/df, cam{3}.c - dc, cam{3}.eulerangs - de, cam{3}.k - dk, cam{3}.pos' - dr2];
ub = [cam{1}.f*df, cam{1}.c + dc, cam{1}.eulerangs + de, cam{1}.k + dk, cam{1}.pos' + dr1, ...
      cam{2}.f*df, cam{2}.c + dc, cam{2}.eulerangs + de, cam{2}.k + dk, cam{2}.pos' + dr2, ...
      cam{3}.f*df, cam{3}.c + dc, cam{3}.eulerangs + de, cam{3}.k + dk, cam{3}.pos' + dr2];
fun = @(x)residual3(x, T, cam, ball);
anw = diff_evolve(fun, lb, ub, 1000, 50);

% x0 = anw; 
% options = optimset('MaxfunEvals', 100000000, ...
%                    'MaxIter', 1000000000, ... 
%                    'Algorithm', 'sqp',...
%                    'final-detailed');
% anw = fmincon(fun,x0,[],[],[],[],lb,ub,[],options);

[cam{1}.f, cam{1}.c, cam{1}.eulerangs, cam{1}.k, cam{1}.pos] = myget(anw( 1:11));
t = removevars(rows2vars(table((x0(1:11))', (anw(1:11))')), 'OriginalVariableNames');
t.Properties.VariableNames = {'f', 'cx', 'cy', 'α', 'β', 'γ', 'k1', 'k2', 'x', 'y', 'z'};
t.Data = {'No calibration'; 'Diff evolve'};  % ; 'Fmincon'
disp(t);

[cam{2}.f, cam{2}.c, cam{2}.eulerangs, cam{2}.k, cam{2}.pos] = myget(anw(12:22));
t = removevars(rows2vars(table((x0(12:22))', (anw(12:22))')), 'OriginalVariableNames');
t.Properties.VariableNames = {'f', 'cx', 'cy', 'α', 'β', 'γ', 'k1', 'k2', 'x', 'y', 'z'};
t.Data = {'No calibration'; 'Diff evolve'};  % ; 'Fmincon'
disp(t);

[cam{3}.f, cam{3}.c, cam{3}.eulerangs, cam{3}.k, cam{3}.pos] = myget(anw(23:33));
t = removevars(rows2vars(table((x0(23:33))', (anw(23:33))')), 'OriginalVariableNames');
t.Properties.VariableNames = {'f', 'cx', 'cy', 'α', 'β', 'γ', 'k1', 'k2', 'x', 'y', 'z'};
t.Data = {'No calibration'; 'Diff evolve'};  % ; 'Fmincon'
disp(t);

disp("Residuals before: " + num2str(fun(x0)) + " m")
disp("Residuals after:  " + num2str(fun(anw)) + " m")


%% Calculation
for iexp=1:2
    for icam=1:3
        df = T{iexp, icam};

        [df.x0_und, df.y0_und] = cam{icam}.undistort(df.x0, df.y0, [], []);
        [df.x1_und, df.y1_und] = cam{icam}.undistort(df.x1, df.y1, [], []);
        df.x = (df.x0_und + df.x1_und)/2;
        df.y = (df.y0_und + df.y1_und)/2;
        df.d = (df.x1_und - df.x0_und + df.y1_und - df.y0_und) / 2;
        df.Z = cam{icam}.f * ball.d{iexp} ./ df.d;
        df.X = (df.x - cam{icam}.c(1)) .* df.Z / cam{icam}.f;
        df.Y = (df.y - cam{icam}.c(2)) .* df.Z / cam{icam}.f;
        df.R_cam = [df.X df.Y df.Z];
        df.R_mlm = cam{icam}.cam2mlm(df.R_cam',[],[])';

        T{iexp, icam} = df;
    end
end

%% Visualisation
c = 'g';
L = min([size(T{1,1},1), size(T{1,2},1), size(T{1,3},1), size(T{2,1},1), size(T{2,2},1), size(T{2,3},1)]);
for iexp=1:2
    R.cam1 = T{iexp,1}.R_mlm(1:L,:);
    R.cam2 = T{iexp,2}.R_mlm(1:L,:);
    R.cam3 = T{iexp,3}.R_mlm(1:L,:);

    fig = figure('Position', [(50 + 700*(iexp-1)) 50 700 500]);
    tb = cameratoolbar(fig);
    hold on
    for icam=1:3
        plot3(T{iexp,icam}.R_mlm(:,1), T{iexp,icam}.R_mlm(:,2), T{iexp,icam}.R_mlm(:,3))
    end
    for i=1:500:L
        plot3([R.cam1(i,1); R.cam2(i,1)], [R.cam1(i,2); R.cam2(i,2)], [R.cam1(i,3); R.cam2(i,3)], c)
        plot3([R.cam1(i,1); R.cam3(i,1)], [R.cam1(i,2); R.cam3(i,2)], [R.cam1(i,3); R.cam3(i,3)], c)
        plot3([R.cam3(i,1); R.cam2(i,1)], [R.cam3(i,2); R.cam2(i,2)], [R.cam3(i,3); R.cam2(i,3)], c)
    end
    hold off
    xlabel('x, м')
    ylabel('y, м')
    zlabel('z, м')
    legend({'Камера 1','Камера 2','Камера 3'})
    axis equal
    grid on
    cameratoolbar("SetCoordSys", "y")
end

%% Save
save('local/calibration-3', "cam")
save("local/trajectories-3D", "T")
