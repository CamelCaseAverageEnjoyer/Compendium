function show_cube(dims, A, tns, options)
    arguments
        dims (3,1) {mustBeNumeric}  % stretching vector
        A (3,3) {mustBeNumeric}     % rotation matrix from BRF to RF of plot
        tns (3,1) {mustBeNumeric}   % translation vector
        options.color (1,1) {mustBeNumeric} = 0.5  % B&W color [0,1]
        options.alpha (1,1) {mustBeNumeric} = 1    % Transparency [0,1]
    end
    h = 0.5;
    r = [-h -h -h h -h -h h h -h h h h h h -h h h h -h -h -h h -h -h;
         -h -h -h -h -h h -h -h h h -h h h h h h -h h h h -h -h -h h;
         -h h -h -h -h -h -h h -h -h -h -h -h h h h h h -h h h h h h];
    for i = 1:length(r(1,:))
        r(:,i) = r(:,i) .* dims;  % stretching
        r(:,i) = A * r(:,i);  % rotation
        r(:,i) = r(:,i) + tns;  % translation
    end
    x = reshape(r(1,:),[6,4])';
    y = reshape(r(2,:),[6,4])';
    z = reshape(r(3,:),[6,4])';
    patch(x, y, z, options.color, 'FaceAlpha', options.alpha);
end


