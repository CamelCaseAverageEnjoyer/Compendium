function rho_a = density_aero_0007(h_orb, planet)
    %DENSITY_AERO_0007 based on paper Сухой Ю.Г. "Аналитическая модель 
    % плотности верхней атмосферы земли для баллистико-навигационного 
    % обеспечения полётов КА"
    %  Средняя статистичесая часть модели плотности атмосферы
    
    if planet == "Earth"
        A = 2.519e-10; 
        H_m = 200e3; 
        H_0 = 290e3; 
        K_0 = 0.26; 
        a_1 = 100e3; 
        a_2 = 141.13e3;
        n_0 = 6.34; 
        n_01 = 4.25; 
        n_02 = 4.37;
        
        if h_orb < 290e3
            n_ = n_0 + K_0 * ((H_0-h_orb)/a_1)^n_01;
            rho_a = A * (H_m/h_orb)^n_; 
        elseif h_orb < 600e3
            n_ = n_0 + K_0 * ((h_orb-H_0)/a_1)^n_01 - ((h_orb-H_0)/a_2)^n_02;
            rho_a = A * (H_m/h_orb)^n_; 
        else
            rho_a = 0;
        end
        
    else
        rho_a = 0;
    end
end