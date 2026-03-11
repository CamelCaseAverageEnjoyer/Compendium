function [f,c,eulerangs,k,campos] = myget(x)
    f = x(1); 
    c = [x(2) x(3)];
    eulerangs = [x(4) x(5) x(6)];
    k = [x(7) x(8)];  %  x(9)
    campos = [x(9);x(10);x(11)];
end
