function f = force_gravity_full(r_irf, S_irf2grf)
    %Ускорение от всех гармоник в ИСК
    r_grf = S_irf2grf * r_irf;
    [fx,fy,fz] = gravitysphericalharmonic(r_grf', 'EGM2008', 2);
    f = S_irf2grf' * [fx;fy;fz];
end