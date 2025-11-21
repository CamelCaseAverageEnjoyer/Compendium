function F = residual3(x, T1, cam, ball)
    import utils.myget

    T = T1;
    for iexp=1:2
        for icam=1:3
            [f,c,eulerangs,k,campos] = myget(x(1 + 11*(icam-1):11 + 11*(icam-1)));

            df = T{iexp, icam};
            [df.x0_und, df.y0_und] = cam{icam}.undistort(df.x0, df.y0, k, c);
            [df.x1_und, df.y1_und] = cam{icam}.undistort(df.x1, df.y1, k, c);
            % Calculation
            df.x = (df.x0_und + df.x1_und)/2;
            df.y = (df.y0_und + df.y1_und)/2;
            df.d = (df.x1_und - df.x0_und + df.y1_und - df.y0_und) / 2;
    
            df.Z = f * ball.d{iexp} ./ df.d;
            df.X = df.x .* df.Z / f;
            df.Y = df.y .* df.Z / f;
            df.R_cam = [df.X df.Y df.Z];
    
            df.R_mlm = cam{icam}.cam2mlm(df.R_cam',campos,eulerangs)';
    
            % Docking
            T{iexp, icam} = df;
        end
    end

    F = 0;
    L = min([size(T{1,1},1), size(T{1,2},1), size(T{1,3},1), size(T{2,1},1), size(T{2,2},1), size(T{2,3},1)]);
    for iexp=2:2
        R.cam1 = T{iexp,1}.R_mlm(1:L,:);
        R.cam2 = T{iexp,2}.R_mlm(1:L,:);
        R.cam3 = T{iexp,3}.R_mlm(1:L,:);
        lns{1} = R.cam1 - R.cam2;
        lns{2} = R.cam1 - R.cam3;
        lns{3} = R.cam2 - R.cam3;
        for i=1:3
            F = F + sum(sum(lns{i}.^2));
        end
    end
    F = sqrt(F / L / 3 / 1);  % "/ 1" - iexp=2:2
end

