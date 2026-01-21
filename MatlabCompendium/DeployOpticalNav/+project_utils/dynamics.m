classdef dynamics
    properties
        r_orb  % scalar value
        R_orb  % vector value
        w_orb {mustBePositive}  % orbital rate
        r_earth = 6371e3
        R_sun = [-15000000000;15000000000;-15000000]
        mu = 5.972e24 * 6.67408e-11  % standart gravitational parameter
        t = 0
        dt
    end

    methods
        function self = dynamics(h_orb, dt)
            self.r_orb = self.r_earth + h_orb;
            self.w_orb = sqrt(self.mu / self.r_orb^3);
            self.dt = dt;
        end

        function [dr, dv] = rhs(self, r, v)
            dr = v;
            dv = [-2 * self.w_orb * v(2);
                  3 * self.w_orb^2 * r(2) + 2 * self.w_orb * v(1);
                  -self.w_orb^2 * r(3)];
            % dq = quatmultiply(q, [0 w']) / 2;
            % dw = [0;0;0];
        end

        function [r, v, q, w] = rk4_integrate(self, obj)
            r = obj.r;
            v = obj.v;
            % q = obj.q;
            % w = obj.w;
            [k1r, k1v] = self.rhs(r, v);
            [k2r, k2v] = self.rhs(r+k1r*self.dt/2, v+k1v*self.dt/2);
            [k3r, k3v] = self.rhs(r+k2r*self.dt/2, v+k2v*self.dt/2);
            [k4r, k4v] = self.rhs(r+k3r*self.dt, v+k3v*self.dt);
            r = r + (k1r + 2*k2r + 2*k3r + k4r) * self.dt / 6;
            v = v + (k1v + 2*k2v + 2*k3v + k4v) * self.dt / 6;
            % q = q + (k1q + 2*k2q + 2*k3q + k4q) * self.dt / 6;
            % w = w + (k1w + 2*k2w + 2*k3w + k4w) * self.dt / 6;
            % q = q / norm(q);
        end

        function [self, objs] = time_step(self, objs, t_deploy)
            self.t = self.t + self.dt;

            for i=1:length(objs)
                if (i==1) 
                    % [objs(i).r, objs(i).v] = self.rk4_integrate(objs(i));
                elseif (self.t>=t_deploy(i-1))
                    [objs(i).r, objs(i).v] = self.rk4_integrate(objs(i));
                end
            end
        end    
    end
end
