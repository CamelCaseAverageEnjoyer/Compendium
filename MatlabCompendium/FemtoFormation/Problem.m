classdef Problem
    %PROBLEM - класс для всего: задание параметров, КА, интегрирование
    properties (Constant)
        % PCBsat параметры
        PCBsat_len = 0.05;                  % Сторона чипсата - 5*5 cm2
        PCBsat_thikness = 0.002;            % Толщина чипсата - 2 mm
        PCBsat_dims = [Problem.PCBsat_len;Problem.PCBsat_len;Problem.PCBsat_thikness];   
        PCBsat_rho = 2000;                  % Плотность кремния
        PCBsat_S = Problem.PCBsat_len^2;    % Миделева площадь
        PCBsat_V = Problem.PCBsat_len^2 * Problem.PCBsat_thikness;  % Объём
        PCBsat_mass = Problem.PCBsat_V * Problem.PCBsat_rho;        % Масса
        PCBsat_I = Problem.PCBsat_thikness * Problem.PCBsat_len^4 / 12 ...
                 * Problem.PCBsat_rho * diag([1,1,2]);  % Тензор инерции
        % CubeSat 3U параметры
        Cubesat_dims = [0.1;0.1;0.3];   
        Cubesat_mass = 3;  
        Cubesat_S = Problem.Cubesat_dims(2)*Problem.Cubesat_dims(3);
        Cubesat_V = Problem.Cubesat_dims(1)*Problem.Cubesat_dims(2)*Problem.Cubesat_dims(3);
        Cubesat_I = 1/3*Problem.Cubesat_mass*diag([ ...
            Problem.Cubesat_dims(2)^2 + Problem.Cubesat_dims(3)^2, ...
            Problem.Cubesat_dims(1)^2 + Problem.Cubesat_dims(3)^2, ...
            Problem.Cubesat_dims(1)^2 + Problem.Cubesat_dims(2)^2]);  % Тензор инерции
        % Объединение параметров
        mass = [Problem.Cubesat_mass, Problem.PCBsat_mass];
        dims = {Problem.Cubesat_dims; Problem.PCBsat_dims};
        S = [Problem.Cubesat_S, Problem.PCBsat_S];
        V = [Problem.Cubesat_V, Problem.PCBsat_V];
        I = {Problem.Cubesat_I; Problem.PCBsat_I};
        
        % 0189 (Archison J.A., Peck M.A.) "Length Scaling in Spacecraft Dynamics"
        light_speed = 299792458;  % скорость света, м/с
        
        solarradio_n_absorbed = 0.1;
        solarradio_n_diffuse = 0.1;
        solarradio_n_specularly = 1 - Problem.solarradio_n_absorbed - Problem.solarradio_n_diffuse;
        solarradio_pressure = 1368 / Problem.light_speed;
        
        solarwind_flux = 2.3 * 1e-9;  % ВЕРНО ДЛЯ ЗЕМЛИ! Поток солнечного ветра

        aero_n_normalaccomo = 0.7      % к-т нормальной аккомодации (0189)
        aero_n_tangentialaccomo = 0.7  % к-т тангенциальной аккомодации (0189)
        aero_reflection_ratio = 0.05   % v_reflected / v (0189)
    end

    properties
        % Параметры интегрирования
        t_simulation    % Полное время симуляции
        dt = 0.1;       % Шаг по времени
        t = 0.0;        % Настоящее время симуляции (меняется)
        iter = 0;        % Итерация симуляции (меняется)

        % Параметры небесного тела
        celestial_body  % Название
        a_body          % Большая полуось эллипса тела
        f_body          % Знаменатель сжатия эллипсоида тела
        w_body          % Угловая скорость собственного вращения
        v_body          % Скорость вращения точки на экваторе
        mu              % Гравитационный параметр
        J2              % Вторая гармоника

        % Параметры КА
        satnames = ["CubeSat", "PCBsat"];
        sat             % СЛОВАРЬ из СТРУКТУР с кин. параметрами
        satamount       % Кол-во [кубсатов, чипсатов]
        antennatypes    % Типы антенн
        measure_model   % МАССИВ - список измерений
        measure_variants = ['RSS Cube-PCB', 'RSS PCB-PCB', 'Sun sensor', ...
            'Magnetic sensor', 'TDOA', 'AOA'];
        deploy_model    % Вариант отделения PCBsat (random / linear)

        % Постоянно изменяющиеся параметры
        S_orb2dec
        S_orf2irf
        S_irf2grf
        H
        rho_atm
        e_sun
        is_illuminated
        v_atm
    end

    methods
        %% Инициализация
        function o = Problem(t_simulation,body,satamount,antennatypes, ...
                deploy_model,H,e,i,om,Om)
            import utils.*
            o.t_simulation = t_simulation;
            o.celestial_body = body;
            o.satamount = satamount;
            o.antennatypes = antennatypes;

            % Настройка параметров небесного тела
            switch body
               case "Earth"
                  o.a_body = 6378136;                   % ПЗ-90
                  o.f_body = 298.257839303;             % ПЗ-90
                  o.J2 = -484164.953e-9;                % ПЗ-90
                  o.w_body = 7292115e-11;               % ПЗ-90  
                  o.mu = 398600.44e9;                   % ПЗ-90
               case "Moon"
                  error("я ещё не написал")
               case "Asteroid"
                  error("я ещё не написал")
               otherwise
                  error("Некорректно задано небесное тело!")
            end
            o.v_body = o.a_body * o.w_body;  % Скорость вращения экватора


            % Инициализация структур КА
            N = round(o.t_simulation / o.dt);
            o.sat = struct;
            for j=1:2  % [CubeSat, PCBsat]
                for k=1:o.satamount(j)
                    s = struct;
                    s.r_orb = NaN(1,N);  % Местный радиус орбиты
                    s.v_orb = NaN(1,N);  % Местная скорость орбиты
                    s.r_irf = NaN(3,N);  % ИСК
                    s.v_irf = NaN(3,N);
                    s.r_grf = NaN(3,N);  % ГСК
                    s.v_grf = NaN(3,N);
                    s.r_orf = NaN(3,N);  % ОСК
                    s.v_orf = NaN(3,N);
                    s.w = NaN(3,N);      % ИСК->ССК в ССК
                    s.q = NaN(4,N);
                    s.a = NaN(1,N);      % Большая полуось
                    s.p = NaN(1,N);      % Фокальный параметр
                    s.e = NaN(1,N);      % Экцентриситет
                    s.i = NaN(1,N);      % Наклонение орбиты
                    s.u = NaN(1,N);      % Аргумент широты
                    s.om = NaN(1,N);     % Аргумент перицентра
                    s.nu = NaN(1,N);     % Истинная аномалия
                    s.Om = NaN(1,N);     % Долгота восходящего узла
                    s.h = NaN(1,N);      % Интеграл энергии
                    s.f = NaN(3,N);      % Интеграл Лапласа
                    s.c = NaN(3,N);      % Интеграл площадей
                    s.const.name=o.satnames(j); 
                    s.const.dims=o.dims{j};
                    s.const.mass=o.mass(j); 
                    s.const.S=o.S(j); 
                    s.const.V= o.V(j); 
                    s.const.I=o.I{j};
                    o.sat.(o.satnames(j))(k) = s;
                end
            end
            % Задание движение 1-го МКА
            rp = o.a_body + H;
            p = rp*(1 + e);
            u = 0;
            v = u - om;
            o.S_orb2dec = rot_orb2dec(Om,u,i);
            o.S_orf2irf = rot_orf2irf(o.S_orb2dec);
            o.S_irf2grf = rot_irf2grf(o.w_body, 0, o.t);
            [r_irf, v_irf] = orb2dec(o.mu,Om,u,i,v,e,p);
            o.H = height(o.a_body,o.f_body,r_irf);
            o.rho_atm = density_aero_0007(o.H, "Earth");
            o.v_atm = cross(normalize(r_irf), [0;0;1]) * o.v_body;
            o.e_sun = [0;1;0];  % const in IRF
            o.is_illuminated = or(dot(r_irf,o.e_sun)>0, norm(r_irf-dot(r_irf,o.e_sun)*o.e_sun)>o.a_body);
            
            o.sat.("CubeSat")(1).r_irf(:,1) = r_irf;
            o.sat.("CubeSat")(1).v_irf(:,1) = v_irf;
            o.sat.("CubeSat")(1).w(:,1) = zeros(3,1);
            o.sat.("CubeSat")(1).q(:,1) = normalize(rand(4,1));
            % Задание движение остальных МКА
            if satamount(1) > 1
                error("Код ещё не написан для нескольких МКА!")
            end
            % Задание движение ДКА
            for k=1:satamount(2)
                r_irf = o.sat.("CubeSat")(1).r_irf(:,1);
                v_irf = o.sat.("CubeSat")(1).v_irf(:,1);
                switch deploy_model
                    case "random"
                        r_irf = r_irf + 100 * (2*rand(3,1)-1);
                        v_irf = v_irf +   1 * (2*rand(3,1)-1);
                    case "linear"
                        s = unitVec(v_irf);
                        dr = o.PCBsat_thikness * 3;
                        dv = 0.01;
                        r_irf = r_irf + s * dr * (k+1);
                        v_irf = v_irf + s * dv * (k+1);
                    otherwise
                        error("Некорректно задан вариант отделения")
                end
                o.sat.("PCBsat")(k).r_irf(:,1) = r_irf;
                o.sat.("PCBsat")(k).v_irf(:,1) = v_irf;
                o.sat.("PCBsat")(k).w(:,1) = zeros(3,1);
                o.sat.("PCBsat")(k).q(:,1) = normalize(rand(4,1));
            end
        end


        %% Моделирование
        function o = simulate(o)
            import utils.*
            % Основная функция численного моделирования
            N = round(o.t_simulation / o.dt);
            for i_t = 1:(N-1)
                % Шаг по времени
                o.iter = o.iter + 1; o.t = o.iter * o.dt;
                for j=1:2  % [CubeSat, PCBsat]
                    for k=1:o.satamount(j)
                        co = o.sat.(o.satnames(j))(k).const;
                        i = o.iter;
                        
                        x = [o.sat.(o.satnames(j))(k).r_irf(:,i); 
                             o.sat.(o.satnames(j))(k).v_irf(:,i); 
                             o.sat.(o.satnames(j))(k).q(:,i); 
                             o.sat.(o.satnames(j))(k).w(:,i)];
    
                        % ode4
                        k1 = o.rhs(x, o.t, co);
                        k2 = o.rhs(x+k1*o.dt/2, o.t, co);
                        k3 = o.rhs(x+k2*o.dt/2, o.t, co);
                        k4 = o.rhs(x+k3*o.dt, o.t, co);
                        dx = o.dt/6 * (k1 + 2*k2 + 2*k3 + k4);
            
                        r = x(1:3) + dx(1:3);
                        v = x(4:6) + dx(4:6);
                        q = normalize(x(7:10) + dx(7:10)); q = q*q(1);
                        w = x(11:13) + dx(11:13);   
    
                        o.sat.(o.satnames(j))(k).r_irf(:,i+1) = r; 
                        o.sat.(o.satnames(j))(k).v_irf(:,i+1) = v;
                        o.sat.(o.satnames(j))(k).q(:,i+1) = q;
                        o.sat.(o.satnames(j))(k).w(:,i+1) = w;
                    end
                end
                % Обновление орбитальных параметров по [r,v,w,q]
                % НЕ обновляются истинная аномалия, аргумент широты [v,u]
                l = o.iter + 1;
                [e,i,om,Om,~,a] = dec2orb(o.sat.CubeSat(1).r_irf(:,l),o.sat.CubeSat(1).v_irf(:,l),o.mu);
                M = sqrt(o.mu/a^3)*(o.t - 0);
                E = 0;
                for k=1:10
                    E = e*sin(E) + M;
                end
                if (-pi/2 < E) && (E < pi/2)
                    nu = 2*atan(sqrt((1+e)/(1-e))*tan(E/2));
                else
                    nu = pi - 2*atan(sqrt((1+e)/(1-e))*tan(E/2));
                end
                o.S_orb2dec = rot_orb2dec(Om,om + nu,i);
                o.S_orf2irf = rot_orf2irf(o.S_orb2dec);
                o.S_irf2grf = rot_irf2grf(o.w_body, 0, o.t);
                for j=1:2  % [CubeSat, PCBsat]
                    for k=1:o.satamount(j)
                        r = o.sat.(o.satnames(j))(k).r_irf(:,l);
                        v = o.sat.(o.satnames(j))(k).v_irf(:,l);
                        [e,i,om,Om,p,a] = dec2orb(r,v,o.mu);
                        [r_orf,v_orf] = irf2orf(r,v,o.S_orf2irf');
                        [r_grf,v_grf] = irf2grf(r,v,o.S_irf2grf,o.w_body);
                        [h, c, f] =  motion_integrals(r,v,o.mu);
                        
                        o.sat.(o.satnames(j))(k).r_orb(l) = norm(r);
                        o.sat.(o.satnames(j))(k).v_orb(l) = norm(v);
                        o.sat.(o.satnames(j))(k).e(l) = e;
                        o.sat.(o.satnames(j))(k).i(l) = i;
                        o.sat.(o.satnames(j))(k).v(l) = nu;
                        o.sat.(o.satnames(j))(k).u(l) = om + nu;
                        o.sat.(o.satnames(j))(k).om(l) = om;
                        o.sat.(o.satnames(j))(k).Om(l) = Om;
                        o.sat.(o.satnames(j))(k).p(l) = p;
                        o.sat.(o.satnames(j))(k).a(l) = a;
                        o.sat.(o.satnames(j))(k).r_orf(:,l) = r_orf;
                        o.sat.(o.satnames(j))(k).v_orf(:,l) = v_orf;
                        o.sat.(o.satnames(j))(k).r_grf(:,l) = r_grf;
                        o.sat.(o.satnames(j))(k).v_grf(:,l) = v_grf;
                        o.sat.(o.satnames(j))(k).h(l) = h;
                        o.sat.(o.satnames(j))(k).c(:,l) = c;
                        o.sat.(o.satnames(j))(k).f(:,l) = f;
                    end
                end
                r = o.sat.("CubeSat")(1).r_irf(:,l);
                i = o.sat.("CubeSat")(1).i(l);
                u = o.sat.("CubeSat")(1).u(l);
                Om = o.sat.("CubeSat")(1).om(l);
                o.H = height(o.a_body,o.f_body,r);
                o.rho_atm = density_aero_0007(o.H, "Earth");
                o.v_atm = cross(normalize(r), [0;0;1]) * o.v_body;
                o.e_sun = [0;1;0];  % const in IRF
                o.is_illuminated = or(dot(r,o.e_sun)>0, norm(r-dot(r,o.e_sun)*o.e_sun)>o.a_body);
                
                % Измерения

                % Оценка состояния
            end
            
        end

        function dx = rhs(o,x,t,co)
            import utils.*
            r = x(1:3);
            v = x(4:6);
            q = x(7:10);
            w = x(11:13);

            n = quat2dcm(q')' * [0;0;1];
            % S_irf2grf_ = rot_irf2grf(o.w_body, 0, t);
            a = ... % force_gravity_full(r, S_irf2grf_) + ...
                force_gravity_central(r, o.mu) + ...
                force_aerodynamic_0345(co.name,co.mass,co.S,o.v_atm - v,n,o.rho_atm,o.aero_reflection_ratio) + ...
                force_solarradiation(co.name,co.S,o.e_sun,n,o.solarradio_pressure,o.solarradio_n_specularly,o.solarradio_n_diffuse,o.solarradio_n_absorbed,o.is_illuminated);
            M = torque_gravity(o.mu,quat2dcm(q'),r,co.I);

            dr = v;
            dv = a;
            dq = 1/2 * quatmultiply(q', [0,w']);
            dw = co.I \ (M - cross(w, co.I * w));

            dx = [dr; dv; dq'; dw];
        end

        %% Измерения
        function y = RSS(o,s1,s2)
            import utils.antenna_gain
            y = NaN;
        end   

        function y = RSS_PCB2Cube(o)
            y = []; i = 0;
            for i_c=1:o.satamount(1)  % 1..N(CubeSat)
                for i_f=1:o.satamount(2)  % 1..N(PCBsat)
                    i = i + 1;
                    y(i) = o.RSS(o.sat.(o.satnames(1))(i_c), o.sat.(o.satnames(2))(i_f));
                end
            end
        end   

        %% Отображение
        function plot_3(o)
            figure("Position",[100 500 500 400]);
            hold on
            for j=1:2  % [CubeSat, PCBsat]
                for k=1:o.satamount(j)
                    s = o.sat.(o.satnames(j))(k);
                    plot3(s.r_irf(1,:),s.r_irf(2,:),s.r_irf(3,:),'LineWidth',1)                    
                end
            end
            hold off
            title("Траектории в ИСК")

            figure("Position",[600 500 500 400]);
            hold on
            for j=1:2  % [CubeSat, PCBsat]
                for k=1:o.satamount(j)
                    s = o.sat.(o.satnames(j))(k);
                    plot3(s.r_orf(1,:),s.r_orf(2,:),s.r_orf(3,:),'LineWidth',1)                    
                end
            end
            hold off
            title("Траектории в ОСК")
        end
    end
end