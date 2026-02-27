function f_a = force_aerodynamic_0345(name,mass,S,v,n,rho_a,aero_reflection_ratio)
    % На основе статьи Ткачев С.С., Мухачев Б.О. "Методика расчета ...аэродинамического сопротивления ..."
    ev = v / norm(v);
    d = dot(ev,n);
    e = 0.1;
    if name == "PCBsat"
        f_a = S/mass*rho_a*norm(v)^2 * ((1-e)*abs(d)*ev + (2*e*abs(d) + (1-e)*aero_reflection_ratio)*d*n);
    else
        f_a = 2.2 * S/mass*rho_a*norm(v)*v;
    end
end