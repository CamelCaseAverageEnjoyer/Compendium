function S = rot_orf2irf(S_orb2dec)
%ROT_ORF2IRF - матрица поворота ОСК -> ИСК
%   ОСК: x-по скорости, y-вертикаль, z-против угл.скорость орбиты
    S = [0 1 0;
         1 0 0;
         0 0 -1] * S_orb2dec;
end