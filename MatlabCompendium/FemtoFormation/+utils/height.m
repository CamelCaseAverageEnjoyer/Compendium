function h = height(a,f,r_irf)
    %HEIGHT считает высоту над эллипсоидом геоида
    %   theta - широта над экватором
    import utils.b_body
    r = r_irf / norm(r_irf);
    theta = asin(r(3));
    h = norm(r_irf) - sqrt(a^2*cos(theta)^2 + b_body(a,f)^2*sin(theta)^2);
end