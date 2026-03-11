clear; 
for N = 1:3
    clc; close all;
    figure('Toolbar', 'none', 'Menubar', 'none');
    myfolder = "local/camcal/cam"+string(N)+"_calibrate_checkboard_changed/";
    listing = dir(myfolder);
    for i = 3:size(listing,1)  % ['.', '..', ...]
        clf; 
        filename = myfolder+string(listing(i).name);
        disp(filename)
        frame = imread(filename);
        [m, n, ~] = size(frame);
        imshow(frame)
        XY = ginput(4);
        mask = poly2mask(XY(:, 1), XY(:, 2), m, n);
        gray_background = uint8(128 * ones(m, n, size(frame, 3)));
        result = frame .* uint8(mask) + gray_background .* uint8(~mask);
        imwrite(result, filename)
    end
end