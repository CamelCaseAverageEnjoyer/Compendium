function [r_grf,v_grf] = irf2grf(r_irf,v_irf,S_irf2grf,w_body)
    r_grf = S_irf2grf * r_irf;
    v_grf = S_irf2grf * v_irf - cross([0;0;w_body],r_grf);
end