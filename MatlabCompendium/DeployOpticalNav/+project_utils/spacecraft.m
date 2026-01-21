classdef spacecraft
    properties
        r  % Position in ORF
        v  % Velocity in ORF
        dims  % dims
    end

    methods
        function self = spacecraft(r, v, dims)
            self.r = r;
            self.v = v;
            self.dims = dims;
        end

        function show_chief(self, options)
            arguments
                self 
                options.alpha (1,1) {mustBeNumeric} = 1 % Transparency [0,1]
            end
            import graphics.show_cube
            config  % M_orf2brf
            show_cube(self.dims, M_orf2brf', self.r, alpha=options.alpha);
        end

        function show_deputy(self, j)
            import project_utils.*
            import graphics.*
            config  % M_orf2dep, markerSize, marker_pos

            % Corpus show (box)
            show_cube(self.dims, M_orf2dep', self.r, "color", 0.9); 

            % Aruco show
            marker = generateArucoMarker(markerFamily,j,6) / 255;
            show_aruco(markerSize, M_orf2dep', self.r, marker_pos, marker);  
        end
    end
end
