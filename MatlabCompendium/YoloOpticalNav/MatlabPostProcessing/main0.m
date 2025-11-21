%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading

POLY_DEGREE = 4;

%% Time managment - MANUAL SETUP!
% Note:  {Exp-1; Exp-2}
time_light = {[0*60 + 9,  0*60 + 15;  % cam1 [time off, time on]
               0*60 + 24, 0*60 + 30;  % cam2
               0*60 + 20, 0*60 + 26]; % cam3
              [0*60 + 26, 0*60 + 30;
               0*60 + 13, 0*60 + 17;
               0*60 + 17, 0*60 + 21]};

% Note: [time start of 1-st camera; 0; 0]
time_start = {[1*60 + 0;  0; 0];
              [0*60 + 50; 0; 0]};
for iexp = 1:2
    for icam = 2:3
        time_start{iexp}(icam) = time_start{iexp}(1) + time_light{iexp}(icam, 1) - time_light{iexp}(1, 1);
    end
end

duration = {[4*60 + 20;  % 260 sec
             4*60 + 10;  % 250 sec
             2*60 + 40]; % 160 sec
            [5*60 + 30;  % 330 sec
             5*60 + 20;  % 320 sec
             4*60 + 10]};% 250 sec

% TESTING (if dt=t1-t0 is const for all cameras)
for i=1:2
    disp("Calibration time in exp-"+i+":  ")
    tmp = unique(time_light{i}(:, 2) - time_light{i}(:, 1));
    if all(size(tmp) == 1), disp('true'), else, disp('false'), end  % time_light setted ok?
    tmp = unique(time_start{1} - time_light{1}(:, 1));
    if all(size(tmp) == 1), disp('true'), else, disp('false'), end  % time_start setted ok?
end

%% Files reading
T = cell(2,3);  % T{iexp,icam}
for iexp=1:2  % experiment
    for icam=1:3  % camera
        % read
        df = readtable("local/boxes_notrack_"+iexp+'_('+icam+").csv");
    
        % cut
        l = size(df, 1);
        df.time = cam{1}.dt * (1:l)' - time_start{iexp}(icam);
        df = df(~(df.time <= 0),:); % delete T <= T0
        df = df(~(df.time > duration{iexp}(icam)),:); % delete T > T1
        
        % fill nulls (dumb implementation: last value repeating)
        l = size(df, 1);
        for i=1:l
            if df.detected(i) == 0
                df.x0(i) = df.x0(i - 1);
                df.x1(i) = df.x1(i - 1);
                df.y0(i) = df.y0(i - 1);
                df.y1(i) = df.y1(i - 1);
            end
        end
    
        % calculate
        df.x = (df.x0 + df.x1) / 2;
        df.y = (df.y0 + df.y1) / 2;
        df.d = (df.x1 - df.x0 + df.y1 - df.y0) / 2;
    
        % Docking
        T{iexp,icam} = df;
    end
end

disp(head(T{1,1}))

%% Pre-calibration estimations
F = zeros(2,3);
for iexp=1:2
    for icam=1:3
        d = T{iexp,icam}.d(1);
        D = ball.d{iexp};
        R = cam{icam}.mlm2cam(ball.r0{iexp}, [], []);
        F(iexp,icam) = d/D * R(3);
    end
end
disp('Focal lenghs:')
disp(F)

F = (F(1,:) + F(2,:)) / 2;

%% Save
save('local/trajectories-2D', "T")
save('local/pre-calibration', "F")

%% 2D plot
import graphics.circle
for iexp=1:2
    for icam=1:3
        % CIRCLES - 2D Trajectory
        figure()
        plot(T{iexp,icam}.x, T{iexp,icam}.y)
        title("Exp-"+iexp+", Camera "+icam)
        xlim([0 1920])
        ylim([0 1080])
        xlabel('x, пикcели')
        ylabel('y, пикcели')
        set(gca, 'YDir','reverse', 'DataAspectRatio',[1 1 1])
        
        hold on
        l = size(T{iexp,icam}, 1);
        for i=1:300:l
            circle(T{iexp,icam}.x(i), T{iexp,icam}.y(i), T{iexp,icam}.d(i))
        end
        hold off
        
        % Just lines
        figure()
        t = T{iexp,icam}.time;
        hold on
        title("Exp-"+iexp+", Camera "+icam)
        xlabel("Время, c")
        ylabel("Параметры положения ШТ")
        x_poly = polyval(polyfit(t, T{iexp,icam}.x, POLY_DEGREE), t);
        y_poly = polyval(polyfit(t, T{iexp,icam}.y, POLY_DEGREE), t);
        d_poly = polyval(polyfit(t, T{iexp,icam}.d, POLY_DEGREE), t);
        plot(t, T{iexp,icam}.x)
        plot(t, T{iexp,icam}.y)
        plot(t, T{iexp,icam}.d)
        plot(t, x_poly)
        plot(t, y_poly)
        plot(t, d_poly)
        dx = sum((x_poly - T{iexp,icam}.x).^2) / length(x_poly);
        dy = sum((y_poly - T{iexp,icam}.y).^2) / length(y_poly);
        dd = sum((d_poly - T{iexp,icam}.d).^2) / length(d_poly);
        disp("exp="+num2str(iexp)+", cam="+num2str(icam)+"| Error of x: " + num2str(dx) + " pixels")
        disp("exp="+num2str(iexp)+", cam="+num2str(icam)+"| Error of y: " + num2str(dy) + " pixels")
        disp("exp="+num2str(iexp)+", cam="+num2str(icam)+"| Error of d: " + num2str(dd) + " pixels")
        disp(" ")

        legend({'x','y','d','x-approx','y-approx','d-approx'})
        hold off
    end
end




