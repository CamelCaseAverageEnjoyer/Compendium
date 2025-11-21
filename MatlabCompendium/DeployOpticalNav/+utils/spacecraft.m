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
            import utils.q2dcm
            M_IRF_BRF = q2dcm(self.q);
            [M_IRF_ORF, ~] = d.get_transition();
            M_ORF_BRF = M_IRF_ORF' * M_IRF_BRF;
        end

        function show_chief(self, d)
            import utils.get_cube
            % Chief spacecraft is box
            [x, y, z] = get_cube(self.dims, self.ORF2BRF(d), self.r);        
            patch(x,y,z,0.5);
        end

        function show_deputy(self, j, d, markerSize)
            import utils.*

            % Corpus show (box)
            M = ORF2BRF(self, d);
            [x, y, z] = get_cube(self.dims, M', self.r);        
            patch(x,y,z,0.5);

            % Aruco show
            r_brf = [self.dims(1)/2 - markerSize(1)/1.5; % Its position on deputy spacecraft
                     self.dims(2)/2 - markerSize(2)/1.5; 
                     self.dims(3)/2 + 0.0001];
            markerFamily = "DICT_4X4_50";
            marker = generateArucoMarker(markerFamily,j,6) / 255;
            show_aruco(markerSize, M', self.r, r_brf, marker);  
        end
    end
end
