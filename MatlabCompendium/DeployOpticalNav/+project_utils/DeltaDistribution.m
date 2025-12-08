function D = DeltaDistribution(t,i,dr,dv,v0,w,r_camera)
%DELTADISTRIBUTION Summary of this function goes here
%   Detailed explanation goes here
arguments (Input)
    t (1,1)  % time of flight
    i (1,1)  % number of deputy
    dr (1,1)
    dv (1,1)
    v0 (1,1)
    w (1,1)  % ang vel of ORF rel to IRF | from dynamics
    r_camera  % from config
end

import project_utils.Deltai
import my_utils.unitVec

N = 30;
D = zeros(N,N);
phi = 0:(2*pi/N):(2*pi);
theta = (-pi):(2*pi/N):(pi);
for iPhi=1:N
    for iTheta=1:N
        e = [cos(theta(iTheta))*cos(phi(iPhi));
             cos(theta(iTheta))*sin(phi(iPhi));
             sin(theta(iTheta))];
        r = 0.15*e;  % pos of 1st deputy (ORF)
        
        ey = unitVec(cross([0;0;1], e));
        ez = unitVec(cross(e, ey));
        M_orf2brf = [e ey ez]';
        % camr = [0;0;0] + M_orf2brf'*r_camera;
        camr = [0;0;0];
        D(iPhi,iTheta) = Deltai(t,i,phi(iPhi),theta(iTheta),dr,dv,v0,r,camr,w);
    end
end
end