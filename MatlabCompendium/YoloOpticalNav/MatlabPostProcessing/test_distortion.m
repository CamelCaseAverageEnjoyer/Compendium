%% 
clear
clc
close all
config  % const params loading
import utils.*  % my functions loading

%% Calculate
c = Camera();
a = [0;0];
b = [0;0];
i = 0;
for x = -500:50:500
    for y = -500:50:500
        i = i + 1;
        a(:, i) = [x;y];
    end
end

[x, y] = c.undistort(a(1,:), a(2,:), [-3e-1, 0], [0, 0]);
b = [x; y];


%% Visualize
figure()
hold on
scatter(b(1, :), b(2, :), 'r')
scatter(a(1, :), a(2, :), 'b')
hold off
axis equal
xlim([-600 600])
ylim([-600 600])