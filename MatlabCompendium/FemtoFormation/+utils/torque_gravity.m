function M = torque_gravity(mu, S_irf2brf, r_irf, J)
    % Момент силы тяжести, выраженный в ССК
    % mu - гравитационный параметр
    % S_irf2brf - матрица поворота ИСК -> ССК (quat2dcm(q))
    % r_irf - положение КА в ИСК
    % J - тензор инерции в ССК
    r = S_irf2brf * r_irf;  % положение КА отн. ССК
    M = 3*mu/norm(r)^5 * cross(r, J*r);
end