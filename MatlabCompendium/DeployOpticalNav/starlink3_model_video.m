%% Params of display
w = warning ('off','all');

clear
clc
close all
import graphics.*
import project_utils.*
load('local/cameraParams')
config  % window_size, camera_angle

camera_pos = [0; 0; 1.5];
camera_up = unitVec([0; 1; 7]);
camera_dir = unitVec([1; 0; -0.4]);
camera_to = camera_pos + camera_dir;

ex = unitVec(cross(camera_up,camera_dir)); 
ey = unitVec(cross(camera_dir, ex)); 
M_orf2cam = [-1  0  0;
              0 -1  0;
              0  0  1] * [ex ey camera_dir]';
% M_orf2cam = [unitVec(cross(camera_up,camera_dir)) camera_up camera_dir]';

dx = 0.05;
d = dx/2;  % Semi-width of deputy spacecraft
D = 0.12;  % Distance between deputy spacecrafts
dims = [dx; 2; 2];
v_x = 0.1;
x0_ = 0.5;
all_counter = 20;  % 51;
dt = 0.2;

R_real = zeros(3,all_counter);
L_real = zeros(3,all_counter);
h_real = zeros(3,all_counter);
counter = 0;
for t=0:dt:10
    counter = counter + 1;
    r_orf = [x0_+v_x*t; 0; 0];
    R_real(:,counter) = r_orf + [0; dims(2)/2; dims(2)/2];
    L_real(:,counter) = [0; -dims(2); 0];
    h_real(:,counter) = [1; 0; 0];
    if counter == all_counter
        break
    end
end

%% Modeling
f = figure('Color', [0 0 0], 'Position', [1920 0 window_size]);

counter = 0;
dv = v_x/20 * (rand(3,100)*2 - 1);
% dv = zeros(3,100);
for t=0:0.2:10
    clf
    set(gca,'Color','white');
    colormap('gray');
    camva(camera_angle);
    camproj('perspective')
    cameratoolbar("SetMode","pan");
    set(gca,'visible','off');
    axis equal;
    light('Style', 'infinite', 'Position', [0; 0; 1000]);
    campos(camera_pos');
    camup(camera_up');
    camtarget(camera_to);

    hold on
    i = 0;
    for x0 = x0_:D:4
        i = i + 1;
        r_orf = [x0+(v_x+dv(1,i))*t; dv(2,i)*t; dv(3,i)*t];
        show_cube(dims, eye(3), r_orf);
    end
    hold off

    counter = counter + 1;
    saveas(f, 'local/modeling_starlink/' + string(counter) + '.jpg');
end

%% Detect and proces each frame  | RUN "Params of display" !
clc
close all;
Rs = []; Ls = []; hs = [];
counter = all_counter;  
tresh_lines = 12;  % Сколькими линиями ограничиться | size(lines,2)
L_sep = zeros(3,all_counter,tresh_lines);
R_sep = zeros(3,all_counter,tresh_lines);
f = figure('Color', [0 0 0]);  % , 'Position', [1920 0 window_size]);
for c =1:counter
    % Find edges
    I = imread('local/modeling_starlink/' + string(c) + '.jpg');
    I = undistortImage(I,cameraParams);
    edgeim = edge(rgb2gray(I),'canny', [0.2,0.3], 2);  % Определение границ
    % figure
    % imshow(edgeim)
    
    % Hough
    [H, theta, rho] = hough(edgeim, 'Theta', -85:0.01:-75);  % Преобразование Хафа
    % [H, theta, rho] = hough(edgeim, 'Theta', -90:0.1:89);  % Преобразование Хафа
    if c==1
        disp(size(H)/50)
    end
    P = houghpeaks(H, 50, 'Threshold', ceil(0.4*max(H(:))), 'NHoodSize', [11, 201]);  % Поиск пиков в пространстве Хафа
    lines = houghlines(edgeim, theta, rho, P, 'FillGap', 150, 'MinLength', 300);  % Извлечение линий  

    % Отображение функции Хафа
    % figure
    % imshow(imadjust(rescale(H)),[],'XData',theta,'YData',rho,'InitialMagnification','fit');
    % xlabel('\theta (градусы)'); ylabel('\rho')
    % axis on; axis normal; colormap(gca,hot); hold on
    % x = theta(P(:,2)); y = rho(P(:,1)); plot(x,y,'s','color','white','MarkerSize',10);
    
    % Find k-sequence
    [blah, order] = sort([lines(:).rho],'ascend');
    newlines = {lines(order(1))};
    d_prev = 0;
    k = 1;
    counter = 1;
    treshold_between = 0.7;
    for i=1:min(length(order)-1, tresh_lines-1)
        counter = counter + 1;
        d_ = abs(blah(i+1)-blah(i));
        if (i>1) && ((d_ - d_prev) > d_prev*treshold_between)
            counter = counter + 1;
            d_prev = abs(d_ - d_prev) * treshold_between;
        else
            d_prev = d_;
        end
        k(i+1) = counter;
        newlines{i+1} = lines(order(i+1));
    end
    
    % Animation    
    clf;
    imshow(I); 
    hold on
    for i = 1:length(newlines)
        xy = [newlines{i}.point1; newlines{i}.point2];
        tmp = plot(xy(:,1), xy(:,2), 'LineWidth', 2);
        % text(xy(1,1)-10, xy(1,2)-10-3*(-1)^i, 'линия '+string(i), 'Color',tmp.Color,'FontSize',16);
    end
    frame = getframe(gcf);
    img =  frame2im(frame);
    % img = imresize(img,0.3);
    [img,cmap] = rgb2ind(img,256);
    if c == 1
        imwrite(img,cmap,'local/animation_3_model.gif','gif','LoopCount',Inf,'DelayTime',0.1);
    else
        imwrite(img,cmap,'local/animation_3_model.gif','gif','WriteMode','append','DelayTime',0.1);
    end

    % THE A L G O R Y T H M !!!!!!!!!!!!!!!!!!!
    fx = cameraParams.Intrinsics.FocalLength(1);
    fy = cameraParams.Intrinsics.FocalLength(1);
    cx = cameraParams.Intrinsics.PrincipalPoint(1);
    cy = cameraParams.Intrinsics.PrincipalPoint(2);
    % cx = cameraParams.Intrinsics.ImageSize(2) / 2;
    % cy = cameraParams.Intrinsics.ImageSize(1) / 2;
    A = [];
    b = [];

    % КОСТЫЛЬ
    k = 1:length(k);
    
    hz = 1;
    disp('k:'); disp(k)
    for i=1:length(k)
        x1 = newlines{i}.point1(1) - cx;  % Здесь x2 - x1 > 0
        x2 = newlines{i}.point2(1) - cx;
        y1 = newlines{i}.point1(2) - cy;
        y2 = newlines{i}.point2(2) - cy;
        k_ = ((-1)^k(i)*d + (floor((k(i)-1)/2))*D);
        A = [A;
            -fx*k_, 0,     0,  0,  0,  -fx,  0,  x1;
            -fx*k_, 0,    -fx, 0,  x2, -fx,  0,  x2;
             0,    -fy*k_, 0,  0,  0,   0,  -fy, y1;
             0,    -fy*k_, 0, -fy, y2,  0,  -fy, y2];
        b = [b;
             -hz*x1*k_;
             -hz*x2*k_;
             -hz*y1*k_;
             -hz*y2*k_];
        tmp_123123 = 1;
        % NEW CODE
        % D1 = zeros(200,200);
        L_best = [0;0;0];
        error_min = 1e5;
        counter_x = 0; 
        L = 2; xy = sqrt((x1-x2)^2+(y1-y2)^2); f=(fx+fy)/2;
        Z = f*L/xy; X = x1*L/xy; Y = y1*L/xy;
        for Lx= 0:0.01:2
            counter_x  = counter_x + 1;
            counter_y  = 0;
            for Ly= 0:0.01:2
                counter_y  = counter_y + 1;
                if Lx^2+Ly^2<=L^2
                    current_error = abs(x2*(Z + sqrt(L^2-Lx^2-Ly^2))-f*(X+Lx))^2 + ...
                                    abs(y2*(Z + sqrt(L^2-Lx^2-Ly^2))-f*(Y+Ly))^2;
                    % D1(counter_x, counter_y) = current_error;
                    if current_error < error_min
                        error_min = current_error;
                        L_best = [Lx;Ly;sqrt(L^2-Lx^2-Ly^2)];
                    end
                % else
                %     D1(counter_x, counter_y) = nan;
                end
                
            end
        end
        L_sep(:,c,i) = M_orf2cam' * L_best;
        R_sep(:,c,i) = M_orf2cam' * [X;Y;Z] + camera_pos;
        % NEW CODE
    end
    disp('Ранг матрицы А: '+string(rank(A))+', размер матрицы A: (' + string(size(A,1))+', '+string(size(A,2))+')')
    
    xi = linsolve(A,b);
    
    h =  [xi(1); xi(2); hz];
    L =  [xi(3); xi(4); xi(5)];
    R0 = [xi(6); xi(7); xi(8)];
    
    L = M_orf2cam' * L / norm(h);
    R0 = M_orf2cam' * R0 / norm(h) + camera_pos;
    h = M_orf2cam' * h / norm(h);

    hs(:,c) = h;
    Ls(:,c) = L;
    Rs(:,c) = R0;
    
    disp('Начальная точка: ['+string(R0(1))+','+string(R0(2))+','+string(R0(3))+']')
    disp('Направление модулей: ['+string(h(1)/norm(h))+','+string(h(2)/norm(h))+','+string(h(3)/norm(h))+']')
    disp('Длина грани: '+string(norm(L)))
end

%%
new_window_size = [300 300];
correct_frames = 14;
t = 0:dt:(dt*(correct_frames-1));

figure('Position', [850 650 new_window_size]); hold on
e = norm(L_real(:,1));
r1 = L_sep(:,1:correct_frames,1); r2 = L_real(:,1:correct_frames);
plot(t,(r1(1,:)-r2(1,:))/e, 'r-'); 
plot(t,(r1(2,:)-r2(2,:))/e, 'g-'); 
plot(t,(r1(3,:)-r2(3,:))/e, 'b-');
xlabel('Время, с'); ylabel('Координаты L, безразм.')
legend('ошибка Lˣ', 'ошибка Lʸ', 'ошибка Lᶻ')
grid; hold off

figure('Position', [250 150 new_window_size]); hold on
e = norm(R_real(:,1));
r1 = R_sep(:,1:correct_frames,1); r2 = R_real(:,1:correct_frames);
plot(t,(r1(1,:)-r2(1,:))/e, 'r-'); 
plot(t,(r1(2,:)-r2(2,:))/e, 'g-'); 
plot(t,(r1(3,:)-r2(3,:))/e, 'b-');
xlabel('Время, с'); ylabel('Координаты R, безразм.')
legend('ошибка Rˣ', 'ошибка Rʸ', 'ошибка Rᶻ')
grid; hold off

%% Analyze all frames
close all
new_window_size = [300 300];
t = 0:dt:(dt*(all_counter-1));

figure('Position', [100 600 new_window_size]); hold on
a = []; b = [];
for i=1:size(Ls,2)
    a = [a norm(Ls(:,i))];
    b = [b 2];
end
plot(t,a); plot(t,b)
xlabel('Время, с'); ylabel('Длина линии |L|, м')
legend('оцениваемая', 'истинная')
grid; hold off

figure('Position', [800 600 new_window_size]); hold on
x = []; y = []; z = [];
for i=1:size(Ls,2)
    tmp = Ls(:,i);
    x(i) = tmp(1);
    y(i) = tmp(2);
    z(i) = tmp(3);
end
L_est = [x; y; z];
e = norm(L_real(:,1));
plot(t,(x-L_real(1,:))/e, 'r-'); plot(t,(y-L_real(2,:))/e, 'g-'); plot(t,(z-L_real(3,:))/e, 'b-');
xlabel('Время, с'); ylabel('Координаты L, безразм.')
legend('ошибка Lˣ', 'ошибка Lʸ', 'ошибка Lᶻ')
grid; hold off

figure('Position', [200 100 new_window_size]); hold on
x = []; y = []; z = [];
for i=1:size(Rs,2)
    tmp = Rs(:,i);
    x(i) = tmp(1);
    y(i) = tmp(2);
    z(i) = tmp(3);
end
R_est = [x; y; z];
e = norm(R_real(:,1));
plot(t,(x-R_real(1,:))/e, 'r-'); plot(t,(y-R_real(2,:))/e, 'g-'); plot(t,(z-R_real(3,:))/e, 'b-'); 
xlabel('Время, с'); ylabel('Координаты R₁, безразм.')
legend('ошибка X₁', 'ошибка Y₁', 'ошибка Z₁')
grid; hold off

figure('Position', [900 100 new_window_size]); hold on
x = []; y = []; z = [];
for i=1:size(hs,2)
    tmp = hs(:,i);
    x(i) = tmp(1);
    y(i) = tmp(2);
    z(i) = tmp(3);
end
plot(t,x, 'r-');           plot(t,y, 'g-');           plot(t,z, 'b-');
xlabel('Время, с'); ylabel('Координаты h в СК камеры, м')
legend('оценка hˣ', 'оценка hʸ', 'оценка hᶻ')
grid; hold off

figure('Position', [950 100 new_window_size]); hold on
x = []; y = []; z = [];
for i=1:size(hs,2)
    tmp = hs(:,i);
    x(i) = tmp(1);
    y(i) = tmp(2);
    z(i) = tmp(3);
end
h_est = [x; y; z];
plot(x-h_real(1,:), 'r-'); plot(y-h_real(2,:), 'g-'); plot(z-h_real(3,:), 'b-'); 
xlabel('Время, с'); ylabel('Координаты h, безразм.')
legend('ошибка hˣ', 'ошибка hʸ', 'ошибка hᶻ')
grid; hold off

%% Рассчёт оценки орбиты

correct_frames = 14;

ft = fittype('a*x + b');
x = 1:correct_frames;
[paramx,~] = fit(x',R_est(1,1:correct_frames)',ft);
[paramy,~] = fit(x',R_est(2,1:correct_frames)',ft);
[paramz,~] = fit(x',R_est(3,1:correct_frames)',ft);
R_mnk = [paramx.a * x + paramx.b;
         paramy.a * x + paramy.b;
         paramz.a * x + paramz.b];

L_mnk = [mean(L_est(1,1:correct_frames)); mean(L_est(2,1:correct_frames)); mean(L_est(3,1:correct_frames))];
h_mnk = [mean(h_est(1,1:correct_frames)); mean(h_est(2,1:correct_frames)); mean(h_est(3,1:correct_frames))];

figure('Position', [100 600 new_window_size]); hold on
plot(R_real(1,1:correct_frames), 'r:'); plot(R_real(2,1:correct_frames), 'g:'); plot(R_real(3,1:correct_frames), 'b:'); 
plot(R_mnk(1,1:correct_frames), 'r-');  plot(R_mnk(2,1:correct_frames), 'g-');  plot(R_mnk(3,1:correct_frames), 'b-'); 
xlabel('Кадры'); ylabel('Координаты R, м')
legend('Rˣ', 'Rʸ', 'Rᶻ', 'оценка Rˣ', 'оценка Rʸ', 'оценка Rᶻ')
grid; hold off

R_center_real = zeros(3,correct_frames);
R_center_est  = zeros(3,correct_frames);
for i=1:correct_frames
    R_center_real(:,i) = R_real(:,i) - L_real(:,1)/2 - cross(L_real(:,1),h_real(:,1))/2;
    R_center_est(:,i)  = R_mnk(:,i)  - L_mnk/2       - cross(L_mnk,      h_mnk)/2;
end
figure('Position', [400 600 new_window_size]); hold on
plot(R_center_real(1,:), 'r:'); plot(R_center_real(2,:), 'g:'); plot(R_center_real(3,:), 'b:'); 
plot(R_center_est(1,:), 'r-');  plot(R_center_est(2,:), 'g-');  plot(R_center_est(3,:), 'b-'); 
xlabel('Кадры'); ylabel('Координаты центра масс ДКА, м')
legend('x', 'y', 'z', 'оценка x', 'оценка y', 'оценка z')
grid; hold off


import graphics.*
t_modeling = 10000;
dt = 1;
h_orb = 400e3;
d = dynamics(h_orb, dt);
N = round(1 * t_modeling / dt);
R_r = zeros(3,N+1); V_r = zeros(3,N+1);
R_e = zeros(3,N+1); V_e = zeros(3,N+1);
R_r(:,1) = R_center_real(:,1); R_e(:,1) = R_center_est(:,1);
V_r(:,1) = (R_center_real(:,correct_frames) - R_center_real(:,1))/3;
V_e(:,1) = (R_center_est(:,correct_frames) - R_center_est(:,1))/3;
for i=1:N
    [dr_, dv_] = d.rhs(R_r(:,i), V_r(:,i));
    V_r(:,i+1) = V_r(:,i) + dv_*dt;  
    R_r(:,i+1) = R_r(:,i) + dr_*dt;
    [dr_, dv_] = d.rhs(R_e(:,i), V_e(:,i));
    V_e(:,i+1) = V_e(:,i) + dv_*dt;  
    R_e(:,i+1) = R_e(:,i) + dr_*dt;
end
figure('Position', [100 100 new_window_size]); hold on
myplot3(R_r, 'b')
myplot3(R_e, 'r')
xlabel('x, м');    ylabel('y, м');    zlabel('z, м')
legend('Действительная траектория', 'Оцениваемая траектория')
grid; hold off;

figure('Position', [100 400 new_window_size]); hold on
myplot3(R_e-R_r, 'b')
xlabel('x, м');    ylabel('y, м');    zlabel('z, м')
legend('Ошибка траектории')
grid; hold off;