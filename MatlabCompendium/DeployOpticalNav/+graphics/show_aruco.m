function show_aruco(dims, A, r_irf, r_brf, marker)  % (r, r1, q, d)

    marker_clr = [0; 1];
    nx = size(marker, 1);
    ny = size(marker, 2);
    hx = 1 / nx;
    hy = 1 / ny;
    % disp('Размеры ячейки: ['+ string(hx*dims(1)) + ', ' + string(hy*dims(2)) + '] м')
    
    x = zeros(4, nx*ny);
    y = zeros(4, nx*ny);
    z = zeros(4, nx*ny);
    c = zeros(1, nx*ny);
    
    for i = 1:nx
        for j = 1:ny
            x(:, ny*i+j) = [hx*i; hx*i+hx; hx*i+hx; hx*i];
            y(:, ny*i+j) = [hy*j; hy*j; hy*j+hy; hy*j+hy];
            z(:, ny*i+j) = [0; 0; 0; 0];
            c(ny*i+j) = marker_clr(marker(i,j) + 1);
        end
    end
    x = x - 0.5;
    y = y - 0.5;

    % BRF -> IRF
    x = reshape(x, 1, []);
    y = reshape(y, 1, []);
    z = reshape(z, 1, []);
    for i = 1:length(x)
        r = [x(i) .* dims(1); y(i) .* dims(2); z(i)];  % stretching
        r = r + r_brf;  % translation
        r = A * r;  % rotation
        r = r + r_irf;  % translation
        x(i) = r(1);
        y(i) = r(2);
        z(i) = r(3);
    end
    x = reshape(x, 4, []);
    y = reshape(y, 4, []);
    z = reshape(z, 4, []);

    patch(x,y,z,c,"EdgeColor", 'none');
end


