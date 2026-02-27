close all; clc; clear; import utils.*

%% EarthRSSNavigation
% Известны параметры окружения
% Известна ориентация PCBsat
% Неизвестны орбиты PCBsat

tic
p = Problem(1000, "Earth", ...      % время интегрированя, сек
    [1, 2], ...                     % кол-во  [кубсатов, чипсатов]
    ['isotropic','isotropic'], ...  % антенны [кубсатов, чипсатов]
    'random', ...                   % способ отделения (НУ PCBsat)
    400e3, ...                      % H, высота орбиты
    0.01, ...                       % e, экцентриситет
    deg2rad(10), ...                % i, наклонение
    deg2rad(0), ...                 % om, аргумент перицентра
    deg2rad(10));                   % Om, долгота восходящего узла
toc; disp("Задача инициализирована");

tic; p = p.simulate(); toc; 
disp("Инегрирование на "+string(round(p.t_simulation / p.dt))+" итераций закончено")

tic; p.plot_3(); toc; 
disp('Графики отображены')

