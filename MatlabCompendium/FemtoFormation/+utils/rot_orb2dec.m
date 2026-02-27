function S = rot_orb2dec(Om,u,i)
%ROT_ORB2DEC - матрица поворота ОСК(спец.) -> ИСК
%   ОСК(спец.): x-вертикаль, y-по скорости, z-угл.скорость орбиты
    S1 = [cos(Om) -sin(Om) 0; sin(Om) cos(Om) 0; 0 0 1];
    S2 = [1 0 0; 0 cos(i) -sin(i); 0 sin(i) cos(i)];
    S3 = [cos(u) -sin(u) 0; sin(u) cos(u) 0; 0 0 1];
    S = S1 * S2 * S3;
end