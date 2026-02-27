function S = rot_irf2grf(w_body, t0, t)
%ROT_IRF2GRF - матрица поворота ИСК -> ГСК
    a = w_body * (t - t0);
    S = [cos(a) -sin(a) 0;
         sin(a)  cos(a) 0;
         0       0      1];
end