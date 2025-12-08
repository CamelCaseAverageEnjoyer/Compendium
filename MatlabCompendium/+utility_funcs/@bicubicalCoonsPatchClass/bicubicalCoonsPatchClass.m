classdef bicubicalCoonsPatchClass < handle
    %BICUBICALCOONSPATCH class used to describe and calculate coons patches
    % on a rectangular grid with equidistant steps along two axes (along 
    % each axis the step might be unique)
    % grid is
    % -------------> y
    % |
    % |
    % |
    % |
    % v  x

    
    properties
        x               % array of grid points on x axis
        y               % array of grid points on y axis
        x_step          % grid step along x
        y_step          % grid step along y
        value_mat       % matrix with values at grid points
        dx_mat          % matrix with d/dx partial derivatives at grid points
        dy_mat          % matrix with d/dy partial derivatives at grid points
        dxdy_mat        % matrix with d2/dxdy partial derivatives at grid points
    end
    
    methods
        function [] = getDerivativeMatrix(obj, type_patch)
            % calculates matrix with derivatives based on value_mat
            
            % internal points are calculated using simple formula
            % f' = (f(x + h) - f(x - h))/2h 
            x_length = length(obj.x);
            y_length = length(obj.y);
            if x_length < 3 || y_length < 3
                error('grid must include at least 3 points along each axis because we use second order numerical approximation')
            end
            obj.dx_mat = zeros(x_length, y_length);
            obj.dy_mat = zeros(x_length, y_length);
            obj.dxdy_mat = zeros(x_length, y_length);
            % derivatives are defined numerically, using second order
            % approximation f' = (f(x + h) - f(x - h))/2h
            for i = 2:x_length - 1
                for j = 2:y_length - 1
                    obj.dx_mat(i, j) = (obj.value_mat(i + 1, j) - obj.value_mat(i - 1, j))/(obj.x(i + 1) - obj.x(i - 1)); % maybe change it to (--||--)/(2*x_step)? Might be a little bit faster. At the moment statys this way, because it is planned to modify it for generic grid, not only rectangular one
                    obj.dy_mat(i, j) = (obj.value_mat(i, j + 1) - obj.value_mat(i, j - 1))/(obj.y(j + 1) - obj.y(j - 1));
                    obj.dxdy_mat(i, j) = (obj.value_mat(i + 1, j + 1) - obj.value_mat(i - 1, j + 1) - obj.value_mat(i + 1, j - 1) + obj.value_mat(i - 1, j - 1))/(obj.y(j + 1) - obj.y(j - 1))/(obj.x(i + 1) - obj.x(i - 1));
                end
            end
            
            
            if strcmp(type_patch, 'generic')
                % in generic case we define border tangents as zeros, i.e.
                % we do nothing
            elseif strcmp(type_patch, 'spherical') 
                % in spherical case (means that function is periodical 
                % along x and y) we determine border tangents using the
                % same formula as for the internal points, but include
                % information from both sides 
                
                % first, check if the grid is periodical
                for i = 1:x_length
                    if abs(obj.value_mat(i, 1) - obj.value_mat(i, end)) > 1e-10
                        error('You are trying to apply "spherical" type to a non-periodical grid. Do not do that')
                    end
                end
                
                for i = 1:y_length
                    if abs(obj.value_mat(1, i) - obj.value_mat(end, i)) > 1e-10
                        error('You are trying to apply "spherical" type to a non-periodical grid. Do not do that')
                    end
                end
                    
                % dy matrix
                for i = 1:x_length
                    obj.dy_mat(i, 1) = (obj.value_mat(i, 2) - obj.value_mat(i, end - 1))/(obj.y(2) - obj.y(1) + obj.y(end) - obj.y(end - 1));
                    obj.dy_mat(i, end) = obj.dy_mat(i, 1);
                end
                
                for j = 2:y_length - 1
                    obj.dy_mat(1, j) = (obj.value_mat(1, j + 1) - obj.value_mat(1, j - 1))/2/obj.y_step;
                    obj.dy_mat(end, j) = obj.dy_mat(1, j);
                end
                
                obj.dy_mat(1, 1) = (obj.value_mat(1, 2) - obj.value_mat(1, end - 1))/2/obj.y_step;
                obj.dy_mat(1, end) = obj.dy_mat(1, 1);
                obj.dy_mat(end, end) = obj.dy_mat(1, 1);
                obj.dy_mat(end, 1) = obj.dy_mat(1, 1);
                
                % dx matrix
                for i = 1:y_length
                    obj.dx_mat(1, i) = (obj.value_mat(2, i) - obj.value_mat(end - 1, i))/(obj.x(2) - obj.x(1) + obj.x(end) - obj.x(end - 1));
                    obj.dx_mat(end, i) = obj.dx_mat(i, 1);
                end
                                
                for i = 2:x_length - 1
                    obj.dx_mat(i, 1) = (obj.value_mat(i + 1) - obj.value_mat(i - 1))/2/obj.x_step; 
                end
                
                obj.dx_mat(1, 1) = (obj.value_mat(2, 1) - obj.value_mat(end - 1, 1))/2/obj.x_step;
                obj.dx_mat(1, end) =  obj.dx_mat(1, 1);
                obj.dx_mat(end, 1) =  obj.dx_mat(1, 1);
                obj.dx_mat(end, end) =  obj.dx_mat(1, 1);
                % dxdy matrix
                
                for i = 2:x_length - 1
                    obj.dxdy_mat(i, 1) = (obj.value_mat(i + 1, 2) - obj.value_mat(i - 1, 2) - obj.value_mat(i + 1, end - 1) + obj.value_mat(i - 1, end - 1))/4/obj.y_step/obj.x_step;
                    obj.dxdy_mat(i, end) = obj.dxdy_mat(i, 1);
                end
                
                for i = 2:y_length - 1
                    obj.dxdy_mat(1, i) = (obj.value_mat(2, i + 1) - obj.value_mat(end - 1, i + 1) - obj.value_mat(2, i - 1) + obj.value_mat(end - 1, i - 1))/4/obj.y_step/obj.x_step;
                    obj.dxdy_mat(end, i) = obj.dxdy_mat(1, i);
                end
                
                obj.dxdy_mat(1, 1) = (obj.value_mat(2, 2) - obj.value_mat(end - 1, 2) - obj.value_mat(2, end - 1) + obj.value_mat(end - 1, end - 1))/4/obj.y_step/obj.x_step;
                obj.dxdy_mat(end, 1) = obj.dxdy_mat(1, 1);
                obj.dxdy_mat(1, end) = obj.dxdy_mat(1, 1);
                obj.dxdy_mat(end, end) = obj.dxdy_mat(1, 1);
            else
                error('derivative might be calculated only in two cases: generic (rectangular grid) or spherical (when grid is for the angles). Affects the calculation of derivatives at the ends of the grid')
            end
        end
        
        function [f_u, f_w] = evaluatePolynomials(obj, u, w)
        % Evaluates Hermite's polynomials for the bicubical coons patch
            f_u = [2*u^3 - 3*u^2 + 1;
                   -2*u^3 + 3*u^2;
                   u^3 - 2*u^2 + u;
                   u^3 - u^2];
            f_w = [2*w^3 - 3*w^2 + 1;
                   -2*w^3 + 3*w^2;
                   w^3 - 2*w^2 + w;
                   w^3 - w^2];
        end
        
        function [i, j] = findCellIndexes(obj, x_p, y_p) % further will be replaced by binary search
            if x_p > obj.x(end) || y_p > obj.y(end) || x_p < obj.x(1) || y_p < obj.y(1)
                error('evaluated point must be within grid range')
            end
            i = floor(x_p/obj.x_step) + 1;
            j = floor(y_p/obj.y_step) + 1;
            
            % now we need to check if x or y are at the end of the grid --
            % if they are, we should decrease the cell number
            if x_p == obj.x(end)
                i = i - 1;
            end
            
            if y_p == obj.y(end)
                j = j - 1;
            end
            
        end
        
        function value = getValue(obj, x_p, y_p)
            % calculates value
            [i, j] = obj.findCellIndexes(x_p, y_p);
            P_part = obj.value_mat(i:i + 1, j:j + 1);
            dP_du_part = obj.dx_mat(i:i + 1, j:j + 1)*obj.x_step;
            dP_dw_part = obj.dy_mat(i:i + 1, j:j + 1)*obj.y_step;
            dP_dudw_part = obj.dxdy_mat(i:i + 1, j:j + 1)*obj.x_step*obj.y_step;
            u = (x_p - obj.x(i)) /obj.x_step;
            w = (y_p - obj.y(j)) /obj.y_step;
            [f_u, f_w] = obj.evaluatePolynomials(u, w);
            
            value = f_u'*[P_part, dP_dw_part;
                          dP_du_part, dP_dudw_part]*f_w;
        end
    end
end

