function [r_irf, v_irf] = orb2dec(mu,Om,u,i,v,e,p)
%ORB2DEC ищет пложение и скорость КА в ИСК по орбитальным элементам
    import utils.rot_orb2dec
    S = rot_orb2dec(Om,u,i);
    
    r = p/(1 + e*cos(v));
    r_irf = r * S*[1;0;0];
    vr = sqrt(mu/p) * e * sin(v);
    vt = sqrt(mu/p) * (1 + e*cos(v));
    v_irf = S*[vr; vt; 0];
end