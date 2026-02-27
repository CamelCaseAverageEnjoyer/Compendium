function [r_orf,v_orf] = irf2orf(r_irf,v_irf,S_irf2orf)
    r_orf = S_irf2orf * r_irf - [0;norm(r_irf);0];
    v_orf = S_irf2orf * v_irf - [norm(v_irf);0;0];
end