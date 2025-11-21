%% Init
clc
close all
clear
config  % const params loading
import utils.*  % my functions loading

%% Manual enumeration
% for icam = 1:3
%     lb = [cam{icam}.c - 100, -1, -1];
%     ub = [cam{icam}.c + 100,  1,  1];
%     fun = @(x)residual(x,cam,icam,false,true);
%     
%     c = 0;
%     for icx = lb(1):20:ub(1)
%     for icy = lb(2):20:ub(2)
%     for ik1 = lb(3):0.02:ub(3)
%     for ik2 = lb(4):0.02:ub(4)
%         c = c + 1;
%         tmp = fun([icx, icy, ik1, ik2]);
%         f{icam}(c,:) = [ik1, ik2, tmp];
%     end
%     end
%     end
%     end
% end
% save('local/test_line_calibr', 'f')

%%
close all
load('local/test_line_calibr')
for icam = 1:3
    if icam == 2
        for i=1:length(f{icam}(:,3))
            f{icam}(i,3) = min(f{icam}(i,3), 200);
        end
    end

    fig = figure('Position', [(20 + 500*(icam-1)) 50 500 500]);
    tb = cameratoolbar(fig);
    scatter3(f{icam}(:,1), f{icam}(:,2), f{icam}(:,3), 1, ".")
    hold on
    mn = min(f{icam}(:,3));
    mx = max(f{icam}(:,3));
    i = find(f{icam}(:,3)==mn);
    scatter3(f{icam}(i,1), f{icam}(i,2), f{icam}(i,3), 100, "r.")
    % plot3([f{icam}(i,1),f{icam}(i,1)], [f{icam}(i,2),f{icam}(i,2)], [mn,mx], "k")
    hold off
    xlabel('k1')
    ylabel('k2')
    zlabel('F')

    disp("For cam="+num2str(icam)+" min(F)="+num2str(mn))
    
%     d = 0.1;
%     xlim([f{icam}(i,1) - d, f{icam}(i,1) + d])
%     ylim([f{icam}(i,2) - d, f{icam}(i,2) + d])
end

