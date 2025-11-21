%% Params of display
clear
clc
close all
import utils.*
load('local/cameraParams')

window_size = [1280 720];
camera_angle = 90;
camera_pos = [0; 0; 2];
camera_up = [0; sqrt(1/2); sqrt(1/2)];
camera_dir = [1; 0; -0.01];
camera_to = camera_pos + camera_dir;

dx = 0.05;
dh = 0.12;
dims = [dx; 2; 2];
A = eye(3);
v_x = 0.1;

%% Modeling
f = figure('Color', [0 0 0], 'Position', [1920 0 window_size]);

counter = 0;
for t=0:0.1:2
    clf
    set(gca,'Color','white');
    colormap('gray');
    camva(camera_angle);
    camproj('perspective');
    cameratoolbar("SetMode","pan");
    set(gca,'visible','off');
    axis equal;
    light('Style', 'infinite', 'Position', [0; 0; 1000]);
    campos(camera_pos');
    camup(camera_up');
    camtarget(camera_to);
    hold on
    
    for x0 = 1.1:dh:4
        r_irf = [x0+v_x*t; 0; 0];
        [x, y, z] = get_cube(dims, A, r_irf);        
        patch(x,y,z,0.5);
    end
    hold off
    % pause(0.1)

    counter = counter + 1;
    saveas(f, 'local/modeling/' + string(counter) + '.jpg');
end

%% Detect and proces each frame
clc
close all;
Rs = [];
Ls = [];
hs = [];
counter = 21;
f = figure('Color', [0 0 0], 'Position', [1920 0 window_size]);
for c =1:counter
    % Find edges
    I = imread('local/modeling/' + string(c) + '.jpg');
    I = undistortImage(I,cameraParams);
    edgeim = edge(rgb2gray(I),'canny', [0.2,0.3], 2);  % Определение границ
    
    % Hough
    [H, theta, rho] = hough(edgeim, 'Theta', -55:0.01:-45);  % Преобразование Хафа
    if c==1
        disp(size(H)/50)
    end
    P = houghpeaks(H, 50, 'Threshold', ceil(0.2*max(H(:))), 'NHoodSize', [51, 71]);  % Поиск пиков в пространстве Хафа
    lines = houghlines(edgeim, theta, rho, P, 'FillGap', 50, 'MinLength', 300);  % Извлечение линий    
    
    % Find k-sequence
    [blah, order] = sort([lines(:).rho],'ascend');
    newlines = {lines(order(1))};
    d_prev = 0;
    k = 0;
    counter = 0;
    tresh_lines = 6;  % 2 - достаточно, 7 - больше лучше не надо
    for i=1:min(length(order)-1, tresh_lines-1)
        counter = counter + 1;
        d = blah(i+1)-blah(i);
        if (i>1) && (abs(d - d_prev) > abs(d_prev)*0.5)
            counter = counter + 1;
            d_prev = abs(d - d_prev) / 2;
        else
            d_prev = d;
        end
        k = [k counter];
        newlines{i+1} = lines(order(i+1));
    end
    
    % Animation    
    clf;
    imshow(I); 
    hold on

    for i = 1:length(newlines)
        xy = [newlines{i}.point1; newlines{i}.point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2);
    end

    frame = getframe(gcf);
    img =  frame2im(frame);
    [img,cmap] = rgb2ind(img,256);
    if c == 1
        imwrite(img,cmap,'local/animation_3_model.gif','gif','LoopCount',Inf,'DelayTime',0.03);
    else
        imwrite(img,cmap,'local/animation_3_model.gif','gif','WriteMode','append','DelayTime',0.03);
    end
    % THE A L G O R Y T H M !!!!!!!!!!!!!!!!!!!
    f = cameraParams.Intrinsics.FocalLength(1);
    A = [];
    b = [];
    cx = 3000/2;
    cy = 1615/2;
    
    hz = 1;
    for i=1:length(k)
        x1 = newlines{i}.point1(1) - cx;
        y1 = newlines{i}.point1(2) - cy;
        x2 = newlines{i}.point2(1) - cx;
        y2 = newlines{i}.point2(2) - cy;
        A = [A;
             -f*k(i), 0, 0,  0, 0,  -f, 0, x1;
             0, -f*k(i), 0,  0, 0,  0, -f, y1;
             -f*k(i), 0, -f, 0, x2, -f, 0, x2;
             0, -f*k(i), 0, -f, y2, 0, -f, y2];
        b = [b;
             -hz*x1*k(i);
             -hz*y1*k(i);
             -hz*x2*k(i);
             -hz*y2*k(i)];
    end
    disp('Ранг матрицы А: '+string(rank(A))+', размер матрицы A: (' + string(size(A,1))+', '+string(size(A,2))+')')
    
    % A = A(1:9,:);
    % xi = linsolve(A,zeros(size(A,1),1));
    xi = linsolve(A,b);
    
    h = [xi(1); xi(2); hz];
    L = [xi(3); xi(4); xi(5)];
    R0 = [xi(6); xi(7); xi(8)];
    
    C = dx / norm(h);
    h = h * C;
    L = L * C;
    R0 = R0 * C;

    hs(:,c) = h;
    Ls(:,c) = L;
    Rs(:,c) = R0;
    
    disp('Начальная точка: ['+string(R0(1))+','+string(R0(2))+','+string(R0(3))+']')
    disp('Длина грани: '+string(norm(L)))
    disp('Направление модулей: ['+string(h(1)/norm(h))+','+string(h(2)/norm(h))+','+string(h(3)/norm(h))+']')
end

%% Analyze all frames
close all
figure('Position', [150 200 900 600]); hold on
a = [];
b = [];
for i=1:size(Ls,2)
    a = [a norm(Ls(:,i))];
    b = [b 2];
end
plot(a)
plot(b)
legend('Оцениваемый |L|, м', 'Истинный |L|, м')
grid
hold off

figure('Position', [1000 250 900 600]); hold on
x = [];
y = [];
z = [];
for i=1:size(Rs,2)
    x = [x Rs(1,i)];
    y = [y Rs(2,i)];
    z = [z Rs(3,i)];
end
plot(x)
plot(y)
plot(z)
legend('x, м', 'y, м', 'z, м')
grid
hold off