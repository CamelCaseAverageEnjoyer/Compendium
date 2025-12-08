function LOS = LOSvec(t,r,v,camr,w)
%LOSVEC is line of sight (non-unit!)
arguments (Input)
    t  % time of flight
    r  % pos in t=0 (ORF)
    v  % vel in t=0 (ORF)
    camr  % pos of camera in any t (ORF)
    w  % ang vel of ORF rel to IRF
end

LOS = [r(1) - 2*v(2)/w - (6*r(2)*w + 3*v(1))*t + 2*v(2)/w*cos(w*t) + (6*r(2) + 4*v(1)/w)*sin(w*t);
       4*r(2) + 2*v(1)/w + v(2)/w*sin(w*t) - (3*r(2) + 2*v(1)/w)*cos(w*t);
       r(3)*cos(w*t) + v(3)/w*sin(w*t)];

LOS = LOS - camr;
end