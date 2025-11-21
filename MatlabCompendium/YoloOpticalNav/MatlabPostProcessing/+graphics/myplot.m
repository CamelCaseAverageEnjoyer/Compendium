function myplot(mat,varargin)
    plot(mat(:,1), mat(:,2), varargin{:})
    grid on
    axis equal
end

