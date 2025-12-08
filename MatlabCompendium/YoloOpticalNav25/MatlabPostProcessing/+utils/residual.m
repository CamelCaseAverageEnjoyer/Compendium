function F = residual(x,cam,icam,isF1,isF2)
    % F1 - points
    % F2 - lines (dist to line)
    % F3 - lines (penalty horizontal/vertical)
    import utils.myget
    import utils.line_least_squares
    import utils.euler2mat
    F1 = 0;
    F2 = 0;
    F3 = 0;
    
    if isF1
        [f,c,eulerangs,k,campos] = myget(x);
        for i = 1:1:size(cam{icam}.points, 1)
            x1 = cam{icam}.points.pixels(i, 1);
            y1 = cam{icam}.points.pixels(i, 2);
            [x1, y1] = cam{icam}.undistort(x1,y1,k,c);
            [x0, y0] = cam{icam}.pos2pixel(cam{icam}.points.pos(i, :)',campos,eulerangs,f,c); 
            F1 = F1 + (x0 -  x1)^2 + (y0 - y1)^2;
        end
        F1 = sqrt(F1 / size(cam{icam}.points, 1));  % Normalize
    end
    
    if isF2
        if ~isF1
            c = [x(1), x(2)];
            k = [x(3), x(4)];
        end
        counter2 = 0;
        counter3 = 0;
        for i=1:size(cam{icam}.lines,2)
            xy = cam{icam}.lines{i};  % copy: + 0
            for j=1:size(xy,1)
                [xy(j,1),xy(j,2)] = cam{icam}.undistort(xy(j,1), xy(j,2), k, c);
            end
            [a,b] = line_least_squares(xy);
            for j=1:size(xy,1)
                F2 = F2 + (a*xy(j,1) + b*xy(j,2) - 1)^2 / (a^2 + b^2);
                counter2 = counter2 + 1;
            end
    
            if cam{icam}.lines_notes(i) == "h"  % should be horizontal
                F3 = F3 + 1e8*a^2;
                counter3 = counter3 + 1;
            elseif cam{icam}.lines_notes(i) == "v"  % should be vertical
                F3 = F3 + 1e8*b^2;
                counter3 = counter3 + 1;
            end
        end
        F2 = sqrt(F2 / counter2);  % Normalize
        F3 = sqrt(F3 / counter3);  % Normalize
    end
    
    % disp(num2str(F1) + " | " + num2str(F2) + " | " + num2str(F3))
    F = F1 + F2 + F3;
end

