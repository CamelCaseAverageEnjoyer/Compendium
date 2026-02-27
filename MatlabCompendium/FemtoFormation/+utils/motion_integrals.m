function [h, c, f] = motion_integrals(r_irf,v_irf,mu)
% Интегралы энергии, площади, Лапласа
    h = norm(v_irf)^2 - 2*mu/norm(r_irf);
    c = cross(r_irf, v_irf);
    f = cross(v_irf, c) - mu*r_irf/norm(r_irf);
end