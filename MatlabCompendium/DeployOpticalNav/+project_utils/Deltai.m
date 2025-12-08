function D = Deltai(t,i,phi,theta,dr,dv,v0,r,camr,w)
%DELTAI is line segment visiable by camera
arguments (Input)
    t (1,1)  % time of flight
    i (1,1)  % number of deputy
    phi (1,1) % elevation of e_deploy
    theta (1,1) % azimuth of e_deploy
    dr (1,1)
    dv (1,1)
    v0 (1,1)
    r (3,1)  % pos of 1st deputy (ORF)
    camr (3,1)  % pos of camera in any t (ORF)
    w (1,1)  % ang vel of ORF rel to IRF
end

import project_utils.LOSvec

e = [cos(theta)*cos(phi);
     cos(theta)*sin(phi);
     sin(theta)];
j = i-1;
LOS1 = LOSvec(t,r+j*dr*e,v0*e+j*dv*e,camr,w);
j = i;
LOS2 = LOSvec(t,r+j*dr*e,v0*e+j*dv*e,camr,w);
cos_a = dot(LOS1,LOS2) / norm(LOS1) / norm(LOS2);
D = norm(LOS2) * sqrt(1 - cos_a^2);  % Без учёта поворота к камере
end