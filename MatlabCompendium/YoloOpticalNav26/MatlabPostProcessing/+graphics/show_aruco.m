function show_aruco(dims, rot, pos, marker)

    n = size(marker, 1);
    h = 1 / n;
    % disp('Размеры ячейки: ['+ string(hx*dims(1)) + ', ' + string(hy*dims(2)) + '] м')
    
    x = zeros(4, n^2);
    y = zeros(4, n^2);
    z = zeros(4, n^2);
    c = zeros(1, n^2);
    
    for i = 1:n
        for j = 1:n
            x(:, n*(i-1)+j) = [h*(i-1); h*i; h*i; h*(i-1)];
            y(:, n*(i-1)+j) = [h*(j-1); h*(j-1); h*j; h*j];
            z(:, n*(i-1)+j) = [0; 0; 0; 0];
            c(n*(i-1)+j) = marker(n-j+1,i); % ШАМАНИЗМ
        end
    end
    x = x - 0.5;
    y = y - 0.5;

    % BRF -> IRF
    x = reshape(x, 1, []);
    y = reshape(y, 1, []);
    z = reshape(z, 1, []);
    for i = 1:length(x)
        r = [x(i); y(i); z(i)] * dims;  % stretching
        r = rot * r;  % rotation
        r = r + pos;  % translation
        x(i) = r(1);
        y(i) = r(2);
        z(i) = r(3);
    end
    x = reshape(x, 4, []);
    y = reshape(y, 4, []);
    z = reshape(z, 4, []);

    patch(x,y,z,c,"EdgeColor", 'none');
end


