function im1 = undistort(im0,cam,icam)
    [X0, Y0] = meshgrid(1:size(im0,2), 1:size(im0,1));
    X1 = zeros(size(X0));
    Y1 = zeros(size(Y0));
    for i=1:size(im0,1)
        for j=1:size(im0,2)
            [X1(i,j), Y1(i,j)] = cam{icam}.undistort(X0(i,j), Y0(i,j),[],[]);
        end
    end
    for c = 1:3
        im1(:, :, c) = griddata(X1, Y1, double(im0(:, :, c)), X0, Y0, 'linear');
    end
    im1 = uint8(im1);
end

