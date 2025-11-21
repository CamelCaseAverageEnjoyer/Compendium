classdef dynamics
    properties
        r_orb  % scalar value
        R_orb  % vector value
        w_orb {mustBePositive}  % orbital rate
        M_IRF_ORF  % rotation IRF->ORF
        r_earth = 6371 * 1000
        R_sun = [-15000000000;15000000000;-15000000]
        mu = 5.972e24 * 6.67408e-11  % standart gravitational parameter
        t = 0
        dt
    end

    methods
        function self = dynamics(h_orb, dt)
            self.r_orb = self.r_earth + h_orb;
            self.w_orb = sqrt(self.mu / self.r_orb^3);
            [self.M_IRF_ORF, self.R_orb] = self.get_transition();
            self.dt = dt;
        end

        function [M_IRF_ORF, R_orb] = get_transition(self)
            w = self.t * self.w_orb;
            M_IRF_ORF = [cos(w), -sin(w), 0;
                         sin(w), cos(w), 0;
                         0, 0, 1];
            R_orb = M_IRF_ORF.' * [self.r_orb; 0; 0];
        end

        function [dr, dv, dq, dw] = rhs(self, r, v, q, w)
            import utils.qdot
            dr = v;
            dv = [-2 * self.w_orb * v(2);
                  3 * self.w_orb^2 * r(2) + 2 * self.w_orb * v(1);
                  -self.w_orb^2 * r(3)];
            dq = qdot(q, [0;w]) / 2;
            dw = [0;0;0];
        end

        function [r, v, q, w] = rk4_integrate(self, obj)
            r = obj.r;
            v = obj.v;
            q = obj.q;
            w = obj.w;
            [k1r, k1v, k1q, k1w] = self.rhs(r, v, q, w);
            [k2r, k2v, k2q, k2w] = self.rhs(r+k1r*self.dt/2, v+k1v*self.dt/2, ...
                                            q+k1q*self.dt/2, w+k1w*self.dt/2);
            [k3r, k3v, k3q, k3w] = self.rhs(r+k2r*self.dt/2, v+k2v*self.dt/2, ...
                                            q+k2q*self.dt/2, w+k2w*self.dt/2);
            [k4r, k4v, k4q, k4w] = self.rhs(r+k3r*self.dt, v+k3v*self.dt, ...
                                            q+k3q*self.dt, w+k3w*self.dt);
            r = r + (k1r + 2*k2r + 2*k3r + k4r) * self.dt / 6;
            v = v + (k1v + 2*k2v + 2*k3v + k4v) * self.dt / 6;
            q = q + (k1q + 2*k2q + 2*k3q + k4q) * self.dt / 6;
            w = w + (k1w + 2*k2w + 2*k3w + k4w) * self.dt / 6;
            q = q / norm(q);
        end

        function [self, objs] = time_step(self, objs)
            self.t = self.t + self.dt;

            [self.M_IRF_ORF, self.R_orb] = self.get_transition();

            for i=1:length(objs)
                [objs(i).r, objs(i).v, objs(i).q, objs(i).w]...
                    = self.rk4_integrate(objs(i));
            end
        end    
    end
end
