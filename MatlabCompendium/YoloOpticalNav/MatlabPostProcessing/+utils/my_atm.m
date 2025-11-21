function rho = my_atm(h)
%     H = 50;  % Scale height
%     h0 = 500;  % Reference height
%     rho0 = 1.225;  % on sea level
%     rho = rho0 * exp(-(h/1e3-h0)*H);
    h = h/1e3;
    if h < 100
        error('??????????? atmosisa ??? h < 100 ??');
    elseif h <= 200
        rho0 = 4.46e-7;  h0 = 100;  H = 8;
    elseif h <= 400
        rho0 = 1.59e-10; h0 = 200;  H = 35;
    elseif h <= 700
        rho0 = 3.73e-12; h0 = 400;  H = 55;
    else
        rho0 = 1.52e-14; h0 = 700;  H = 120;
    end
    rho = rho0 * exp(-(h - h0) / H);
end

