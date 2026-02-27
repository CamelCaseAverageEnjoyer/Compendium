function F_sw = force_solarwind(name,S,e_sun,n,solarwind_flux)
    %FORCE_SOLARWIND based on paper Archison J.A., Peck M.A. "Length Scaling in Spacecraft Dynamics"
    if name == "PCBsat"
        F_sw = - solarwind_flux * S * e_sun * dot(e_sun,n);  % Solar wind force
    else
        F_sw = - solarwind_flux * S * e_sun;
    end
end