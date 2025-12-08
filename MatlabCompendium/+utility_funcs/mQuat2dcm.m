%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function dcm = mQuat2dcm(qin, normalize)
% mQuat2dcm calculates direction cosine matrix from quaternion qin.
% Resulting matrix describes transition of coordinates, i.e. if qin is the
% quaternion from IF to BF then 
% r_BF = dcm*r_IF
% qin -- unit quaternion [4x1]
% normalize -- flag that tell if we have to normalize input quaternion
if nargin == 1
    normalize = false;
end

if ~isequal(size(qin), [4, 1])
    error('input must be 4x1 array');
end

if normalize
    if norm(qin) < 1e-8
        error('input quaternion almost zero, cannot even normalize it')
    end
    qin = qin/norm(qin);
end

dcm = zeros(3,3);
% see wiki on rotation matrices for example. NB: in wiki this expression is transposed, since
% they utilize different notation for dcm
dcm(1,1) = qin(1)^2 + qin(2)^2 - qin(3)^2 - qin(4)^2;
dcm(1,2) = 2*(qin(2)*qin(3) + qin(1)*qin(4));
dcm(1,3) = 2*(qin(2)*qin(4) - qin(1)*qin(3));
dcm(2,1) = 2*(qin(2)*qin(3) - qin(1)*qin(4));
dcm(2,2) = qin(1)^2 - qin(2)^2 + qin(3)^2 - qin(4)^2;
dcm(2,3) = 2*(qin(3)*qin(4) + qin(1)*qin(2));
dcm(3,1) = 2*(qin(2)*qin(4) + qin(1)*qin(3));
dcm(3,2) = 2*(qin(3)*qin(4) - qin(1)*qin(2));
dcm(3,3) = qin(1)^2 - qin(2)^2 - qin(3)^2 + qin(4)^2;
    
end
