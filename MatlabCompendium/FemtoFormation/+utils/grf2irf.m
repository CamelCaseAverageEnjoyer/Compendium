function [r_irf,v_irf] = grf2irf(r_grf,v_grf,S_grf2irf,w_body)
    r_irf = S_grf2irf * r_grf;
    v_irf = S_grf2irf * v_grf + cross([0;0;w_body],r_irf);
end