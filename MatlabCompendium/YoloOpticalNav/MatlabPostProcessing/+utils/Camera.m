classdef Camera    
    properties
        pos  % Position in MLM
        eulerangs  % Euler angles RS -> MLM
        eulerangs_0
        f  % Focus
        c  % Principal poiint
        k  % Distortion
        points  % Table of calibration points params
        dt  % Frequency of capturing
        lines  % For calibration
        lines_notes  % For calibration
    end
    
    methods
        function obj = Camera()
            obj.c = [1920/2 1080/2];
            obj.k = [0 0];
        end

        function [x1,y1] = undistort(obj, x0, y0, k, c)
            if isempty(k)
                k = obj.k;
            end
            if isempty(c)
                c = obj.c;
            end
            ri = sqrt(((x0 - c(1))/1000).^2 + ((y0 - c(2))/1000).^2);
            l = 1 + k(1)*ri.^2 + k(2)*ri.^4;  %  + k(3)*ri.^6;
            x1 = (x0 - c(1)) .* l + c(1);
            y1 = (y0 - c(2)) .* l + c(2);
        end

        function r_mlm = cam2mlm(obj,r_cam,campos,eulerangs)
            import utils.euler2mat
            if isempty(eulerangs)
                eulerangs = obj.eulerangs;
            end
            if isempty(campos)
                campos = obj.pos;
            end

            M = euler2mat(eulerangs);
            r_mlm = M' * r_cam + campos;
        end

        function r_cam = mlm2cam(obj,r_mlm,campos,eulerangs)
            import utils.euler2mat
            if isempty(eulerangs)
                eulerangs = obj.eulerangs;
            end
            if isempty(campos)
                campos = obj.pos;
            end

            M = euler2mat(eulerangs);
            r_cam = M * (r_mlm - campos);
        end
        
        function [x,y] = pos2pixel(obj,r_point,campos,eulerangs,f,c)
            if isempty(f)
                f = obj.f;
            end
            if isempty(c)
                c = obj.c;
            end
            r = obj.mlm2cam(r_point, campos, eulerangs);  % [X,Y,Z]
            x = f*r(1)/r(3) + c(1);
            y = f*r(2)/r(3) + c(2);
        end
    end
end

