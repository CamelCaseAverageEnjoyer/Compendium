function [r_irf,v_irf] = orf2irf(r_orf,v_orf,S_orf2irf,r_orb,v_orb)
    r_irf = S_orf2irf * (r_orf + [0;r_orb;0]);
    v_irf = S_orf2irf * (v_orf + [v_orb;0;0]);
end