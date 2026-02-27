function h = height(a_body,f_body,r_irf)
    %HEIGHT считает высоту над эллипсоидом геоида
    %   theta - широта над экватором
    r = r_irf / norm(r_irf);
    theta = asin(r(3));
    h = norm(r_irf) - sqrt(a_body^2*cos(theta)^2 + (a_body/(1+f_body))^2*sin(theta)^2);
end