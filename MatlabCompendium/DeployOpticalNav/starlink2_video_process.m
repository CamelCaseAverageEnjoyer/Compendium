%% Video process
clear;
clc;
close all;

vid = VideoReader('local/starlink_deployment_1.mp4');
vid1Frames = read(vid);
%Nframes = size(vid1Frames,4);
Nframes = 150;

lines = {};
edgeims = {};
counter = 0;
figure
for frame=1:1:Nframes
    counter = counter + 1;
    f_rgb = vid1Frames(:,:,:,frame);
    f_grey = rgb2gray(f_rgb);
    f_adapthisteq = adapthisteq(f_grey);
    imshow(f_adapthisteq);
    edgeim = edge(f_adapthisteq,'canny', [0.0 0.05], 1);  % Определение границ
    edgeims{counter} = f_adapthisteq;  % edgeim;
    [H, theta, rho] = hough(edgeim, 'Theta', -60:0.1:-40);  % Преобразование Хафа
    P = houghpeaks(H, 1000, 'Threshold', ceil(0.3*max(H(:))), 'NHoodSize', [11,11]);  % Поиск пиков в пространстве Хафа
    lines{counter} = houghlines(edgeim, theta, rho, P, 'FillGap', 7, 'MinLength', 100);  % Извлечение линий
end

save("local/video_lines", "lines")
save("local/video_edgeims", "edgeims")


%% Animate
load("local/video_lines")
load("local/video_edgeims")
for i=1:length(lines)
    % draw stuff
    clf;
    imshow(edgeims{i});
    hold on;
    for k = 1:length(lines{i})
        xy = [lines{i}(k).point1; lines{i}(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'red');
    end

    frame = getframe(gcf);
    img =  frame2im(frame);
    [img,cmap] = rgb2ind(img,256);
    if i == 1
        imwrite(img,cmap,'local/animation_1_lines.gif','gif','LoopCount',Inf,'DelayTime',0.003);
    else
        imwrite(img,cmap,'local/animation_1_lines.gif','gif','WriteMode','append','DelayTime',0.003);
    end
end
close all;

%% Proccess trajectories
load("local/video_lines")
load("local/video_edgeims")
figure
for i=1:length(lines)
    clf;
    hold on
    for k = 1:length(lines{i})
        plot(lines{i}(k).theta, lines{i}(k).rho, 'b+')
    end
    hold off;
    xlabel('\theta (degrees)')
    ylabel('\rho')
    xlim([-60 -40])
    ylim([-180 20])
    axis on
    axis normal 
    frame = getframe(gcf);
    img =  frame2im(frame);
    [img,cmap] = rgb2ind(img,256);
    if i == 1
        imwrite(img,cmap,'local/animation_2_lineparams.gif','gif','LoopCount',Inf,'DelayTime',0.003);
    else
        imwrite(img,cmap,'local/animation_2_lineparams.gif','gif','WriteMode','append','DelayTime',0.003);
    end
end
close all;

%% DBSCAN кластеризация
clc
close all;

i = 1;
numFrames = 150;
% Собираем все точки в один массив с меткой времени
all_points = [];
time_labels = [];

% theta_rho_data - массив ячеек, где каждый элемент содержит [theta, rho] для кадра
theta_rho_points = zeros(length(lines{i}), 2);
for k = 1:length(lines{i})
    theta_rho_points(k, :) = [lines{i}(k).theta, lines{i}(k).rho];
end

% Нормализация данных
points_norm = [theta_rho_points(:,1)/180, theta_rho_points(:,2)/max(abs(theta_rho_points(:,2)))];

% DBSCAN кластеризация
epsilon = 0.008; % Максимальное расстояние между точками
minPts = 5; % Минимальное количество точек в кластере
labels = dbscan(points_norm, epsilon, minPts);

% Формирование кластеров
unique_labels = unique(labels);
clusters = cell(length(unique_labels), 1);

for i = 1:length(unique_labels)
    if unique_labels(i) == -1
        continue; % Пропускаем шум
    end
    cluster_mask = (labels == unique_labels(i));
    clusters{i} = theta_rho_points(cluster_mask, :);
end

% Удаляем пустые ячейки
clusters = clusters(~cellfun('isempty', clusters));

figure;
hold on;

% Цвета для кластеров
colors = lines(length(clusters));

% Отображение шумовых точек
noise_mask = (labels == -1);
if any(noise_mask)
    scatter(theta_rho_points(noise_mask, 1), theta_rho_points(noise_mask, 2), 30, 'k', 'filled', 'MarkerFaceAlpha', 0.3);
end

% Отображение кластеров
for i = 1:length(clusters)
    cluster_points = clusters{i};
    
    % Сортировка по theta для построения кривых
    [sorted_theta, sort_idx] = sort(cluster_points(:,1));
    sorted_rho = cluster_points(sort_idx, 2);
    
    % Построение точек
    scatter(cluster_points(:,1), cluster_points(:,2), 50);  % , colors(i,:), 'filled');
    
    % Построение кривой через точки (если достаточно точек)
    if length(sorted_theta) >= 3
        % Интерполяция для гладкой кривой
        theta_interp = linspace(min(sorted_theta), max(sorted_theta), 100);
        rho_interp = interp1(sorted_theta, sorted_rho, theta_interp, 'spline');
        plot(theta_interp, rho_interp, 'LineWidth', 2, 'Color');  % , colors(i,:));
    else
        % Просто соединяем точки линией
        plot(sorted_theta, sorted_rho, 'LineWidth', 2, 'Color');  % , colors(i,:));
    end
end

xlabel('Theta (градусы)');
ylabel('Rho');
title(sprintf('Кластеризация кривых (найдено %d кластеров)', length(clusters)));
grid on;