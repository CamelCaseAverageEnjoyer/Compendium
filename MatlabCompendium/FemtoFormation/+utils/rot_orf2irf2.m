function S = rot_orf2irf2(r,v)
%ROT_ORB2DEC2 Summary of this function goes here
%   Detailed explanation goes here
import utils.unitVec
ey = unitVec(r);
ez = unitVec(cross(v,r));
ex = unitVec(cross(ey, ez));
S = [ex ey ez];
end