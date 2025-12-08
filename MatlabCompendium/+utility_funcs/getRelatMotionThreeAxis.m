%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [rel_motion] = getRelatMotionThreeAxis(ref_motion,...
                                                state_vector)
%GETRELMOTIONTHREEAXIS calculates relative motion parameters for control
%laws
%   ref_motion --  class with reference motion parameters (must 
%                 include information about quaternion and angular velocity)
%   state_vector -- class with the current state vector of the satellite (or estimated state)


IF2BF = utility_funcs.mQuat2dcm(state_vector.q);
rel_motion = data_containers.relatMotionThreeClass();
rel_motion.q = utility_funcs.mQuatMultiply(utility_funcs.mQuatConj(ref_motion.q), state_vector.q);
rel_motion.w = state_vector.w - IF2BF*ref_motion.w;
end

