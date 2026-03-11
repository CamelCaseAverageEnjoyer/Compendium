function [r_orf,v_orf] = irf2orf(r_irf,v_irf,S_irf2orf,r_orb,v_orb)
    r_orf = S_irf2orf * r_irf - [0;r_orb;0];
    v_orf = S_irf2orf * v_irf - [v_orb;0;0];
end