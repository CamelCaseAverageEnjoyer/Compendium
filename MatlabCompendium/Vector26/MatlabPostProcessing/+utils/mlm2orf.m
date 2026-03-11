function r_orb = mlm2orf(r_mlm)
    import utils.*
    config
    
    r_rs = R_mlm + M_rs_mlm' * r_mlm;

    r_brf = r_rs + R_iss;

    r_orb = M_orb_brf' * r_brf;
end

