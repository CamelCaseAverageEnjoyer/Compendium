function myplot3(mat,varargin)
    plot3(mat(:,1), mat(:,2), mat(:,3), varargin{:})
    xlabel('x, м')
    ylabel('y, м')
    zlabel('z, м')
    grid on
    axis equal
end

