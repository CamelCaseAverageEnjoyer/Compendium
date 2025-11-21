function myscatter(mat,varargin)
    scatter(mat(:,1), mat(:,2), varargin{:})
    grid on
    axis equal
end

