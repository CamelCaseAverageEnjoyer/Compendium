function f = force_gravity_J2(r_irf,u,i,S_orf2irf,mu,J2,a_body)
    %Ускорение от второй зональной гармоники J2 в ИСК
    % S_orf2irf - rotation matrix ORF -> IRF
    % По сути неважно в какой СК r - считается модуль
    tmp = 3*J2*a_body^2*mu / (2*norm(r_irf)^4);
    S_ =  tmp * (3*sin(u)^2*sin(i)^2 - 1);
    T_ = -tmp * sin(2*u)*sin(i)^2;
    W_ = -tmp * sin(2*i)*sin(u);
    f = S_orf2irf * [T_; S_; -W_];
end