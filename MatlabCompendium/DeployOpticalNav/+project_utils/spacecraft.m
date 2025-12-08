classdef spacecraft
    properties
        r  % Position in ORF
        v  % Velocity in ORF
        q = [1; 0; 0; 0];  % Rotation quaternion IRF->BRF
        w  % Angular velocity in BRF
        mass  % mass
        dims  % dims
        J  % tensor of inertia
    end

    methods
        function self = spacecraft(r, v, q, w, mass, dims)
            self.r = r;
            self.v = v;
            self.q = q;
            self.w = w;
            self.mass = mass;
            self.dims = dims;
            self.J = 1/12 * mass * [dims(2)^2 + dims(3)^2, 0, 0;
                                    0, dims(1)^2 + dims(3)^2, 0;
                                    0, 0, dims(1)^2 + dims(2)^2];
        end

        function M_ORF_BRF = ORF2BRF(self, d)
            M_IRF_BRF = quat2dcm(self.q);
            [M_IRF_ORF, ~] = d.get_transition();
            M_ORF_BRF = M_IRF_ORF' * M_IRF_BRF;
        end

        function show_chief(self, d, options)
            arguments
                self 
                d 
                options.alpha (1,1) {mustBeNumeric} = 1 % Transparency [0,1]
            end
            import graphics.show_cube
            show_cube(self.dims, self.ORF2BRF(d)', self.r, alpha=options.alpha);
        end

        function show_deputy(self, j, d, markerSize)
            import my_utils.*
            import graphics.*
            config

            % Corpus show (box)
            M = ORF2BRF(self, d);
            show_cube(self.dims, M', self.r); 

            % Aruco show
            r_brf = [self.dims(1)/2 - markerSize(1)/1.5; % Its position on deputy spacecraft
                     self.dims(2)/2 - markerSize(2)/1.5; 
                     self.dims(3)/2 + 0.0001];
            marker = generateArucoMarker(markerFamily,j,6) / 255;
            show_aruco(markerSize, M', self.r, r_brf, marker);  
        end
    end
end
