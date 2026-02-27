function f = relative_hcw(obj,n)
    %RELATIVE_HCW считает ускорение в ОСК
    %   n - среднее движение (угловая скорость) 1-го МКА (центра ОСК)
    f = [-2*n*obj.v_orf(2);
          3*n^2*obj.r_orf(2)+2*n*obj.v_orf(1);
         -n^2*obj.r_orf(3)];
end