function f = force_gravity_central(r_irf,mu)
    %Ускорение от центрального поля тяжести в ИСК
    f = -r_irf*mu / norm(r_irf)^3;
end
