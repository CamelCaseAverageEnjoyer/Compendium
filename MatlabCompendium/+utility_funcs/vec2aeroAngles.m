function [alpha, beta] = vec2aeroAngles(vec)
% calculates euler angle in some sequence (атака, скольжение). Returns
% degrees!!!!!!!!!!!!!!!
vec = vec/norm(vec);
Vxy=(vec(1)^2+vec(2)^2)^.5;
if abs(Vxy) < 1e-10
    alpha = 0;
else
    alpha=acos(vec(1)/Vxy);
    if vec(2)>0
        alpha = -alpha;
    end
end

beta=acos(Vxy);
if vec(3)<0
    beta=2*pi-beta;
end

alpha=alpha*180/pi;
beta=beta*180/pi;

end

