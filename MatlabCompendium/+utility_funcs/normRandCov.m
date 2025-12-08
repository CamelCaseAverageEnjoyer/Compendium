%	Version 1.0,
%	Author: Yaroslav Mashtakov
%   Developed by Keldysh Institute of Applied Mathematics of RAS
%   date: 20.07.2020
function [out] = normRandCov(cov_mat, diag_flag, check_mat_flag)
%NORMRANDCOV generates normally distributed vector from the given
%covariance matrix. Bias is supposed to be zero
%   cov_mat -- covariation matrix
%   diag_flag -- flag that indicates whether the covariation matrix 
%   is diagonal or not. Default value is zero
%   check_mat_flag -- 1 means that we check whether matrix is symmetrical
%   or not, 0 -- we skip it

if nargin == 1
    diag_flag = 0;
    check_mat_flag = 0;
elseif nargin == 2
    check_mat_flag = 0;
end

if check_mat_flag
    if ~(utility_funcs.validateSymmetric(cov_mat, 1e-10)) % 1e-10 -- tolerance
        error('covariation matrix must be symmetric!');
    end
end

cov_mat_size = size(cov_mat);
if cov_mat_size(1) ~= cov_mat_size(2) || length(size(cov_mat)) > 2
    error('input covariation matrix must be square')
end

out = zeros(cov_mat_size(1), 1);

if diag_flag
    % for diagonal case generation is simple
    for i = 1:cov_mat_size(1)
        out(i) = randn()*sqrt(cov_mat(i, i)); 
    end
else
    % for general case first we have to find eigen vectors and eigen values for
    % covariation matrix
    [V, D] = eig(cov_mat);
    for i = 1:cov_mat_size(1)
        out = out + V(:, i)*randn()*sqrt(D(i, i));
    end
end




end

