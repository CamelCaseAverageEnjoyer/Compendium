%% Framge processig
clear
clc
close all

vid = VideoReader('local/starlink_deployment_1.mp4');
vid1Frames = read(vid);

% for frame=1:size(vid1Frames,4)
frame = 300;
f_rgb = vid1Frames(:,:,:,frame);
f_grey = rgb2gray(f_rgb);
figure
imshow(f_grey)
%%
edgeim = edge(f_grey,'canny'); % , [0.05 0.06]);
figure
imshow(edgeim)

%% Преобразования Хафа / Hough Transform
[H, theta, rho] = hough(edgeim, 'Theta', -60:0.1:-40);  % Преобразование Хафа
figure
imshow(imadjust(rescale(H)),[],'XData',theta,'YData',rho,'InitialMagnification','fit');
xlabel('\theta (degrees)')
ylabel('\rho')
axis on
axis normal 
hold on
colormap(gca,hot)

% Поиск пиков в пространстве Хафа
P = houghpeaks(H, 1000, 'Threshold', ceil(0.3*max(H(:))), 'NHoodSize', [15,15]);
x = theta(P(:,2));
y = rho(P(:,1));
plot(x,y,'k+');
xlabel('\theta (degrees)')
ylabel('\rho')

% Извлечение линий
lines = houghlines(edgeim, theta, rho, P, 'FillGap', 10, 'MinLength', 180);

% Визуализация результата
figure;
% imshow(f_rgb);
imshow(edgeim);
hold on;
for k = 1:length(lines)
    % if (-60 < lines(k).theta) && (lines(k).theta < -40)
        xy = [lines(k).point1; lines(k).point2];
        plot(xy(:,1), xy(:,2), 'LineWidth', 2, 'Color', 'red');
    % end
end
