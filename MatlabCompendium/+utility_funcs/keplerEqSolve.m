function [ecc_an, true_an] = keplerEqSolve(M, e)
%KEPLEREQSOLVE calculates eccentric anomaly, true anomaly for a given
%eccentricity and mean anomaly
%   M -- mean anomaly
%   e -- eccentricity
D = M;
misclosure = D - e*sin(D) - M;
while abs(misclosure) > 1e-14
    D = (M - D*e*cos(D) + e*sin(D))/(1 - e*cos(D));
    misclosure = D - e*sin(D) - M;
end
ecc_an = D;
true_an = 2*atan( sqrt((1 + e)/(1 - e))*tan(ecc_an/2) );
end

