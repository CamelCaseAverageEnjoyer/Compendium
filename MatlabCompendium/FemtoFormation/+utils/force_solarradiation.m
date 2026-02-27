function F_s = force_solarradiation(name,S,e_sun,n,pressure,n_specularly,n_diffuse,n_absorbed,is_illuminated)
    %FORCE_SOLARWIND based on paper Archison J.A., Peck M.A. "Length Scaling in Spacecraft Dynamics"
    if is_illuminated
        if name == "PCBsat"
            % Radiation pressure force (30)
            cos_b = dot(e_sun, n);
            F_s = -pressure*S*((2*n_specularly*abs(cos_b) + 2/3*n_diffuse)*cos_b*n - (n_absorbed + n_diffuse)*abs(cos_b)*e_sun);  
        else
            F_s = -pressure*S*e_sun;
        end
    else
        F_s = zeros(3,1);
    end
end