function [e,i,om,Om,p,a] = dec2orb(r_irf,v_irf,mu)
    import utils.*
    [~, c, f] = motion_integrals(r_irf,v_irf,mu);

    e_c = unitVec(c);
    e_f = unitVec(f);
    e_r = unitVec(r_irf);

    i = acos(e_c(3));  % cos(i) = (c, Oz)
    asc_node = unitVec([-c(2);c(1);0]);  % node = [Oz,c]
    if asc_node(2) >= 0
        Om = acos(asc_node(1));
    else
        Om = 2*pi - acos(asc_node(1));
    end
    om = acos(dot(e_f, asc_node)); % cos(om) = (f, node)
    e = norm(f) / mu;
    p = norm(c)^2 / mu;
    a = p/(1 - e^2);
end