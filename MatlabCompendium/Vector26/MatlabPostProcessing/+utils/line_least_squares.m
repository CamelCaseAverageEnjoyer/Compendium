function [a,b] = line_least_squares(A, varargin)
    % if varargin{1} == false -> returns [a,b] (ax + by = 1)
    % if varargin{1} == true -> returns [x,y] line arrays (for plot)
    if isempty(varargin)
        varargin{1} = false;
    end

    y = ones(size(A,1),1);
    x = (A'*A)\A' * y;  % zeros(size(A,1),1)
    a = x(1); 
    b = x(2);

    if varargin{1}
        if (max(A(:,1)) - min(A(:,1))) > (max(A(:,2)) - min(A(:,2)))  % quazi-horizontal line
            x = min(A(:,1)):max(A(:,1));
            y = (1 - a*x)/b;
        else  % quazi-vertical line
            y = min(A(:,2)):max(A(:,2));
            x = (1 - b*y)/a;
        end
        a = x;
        b = y;
    end
end

