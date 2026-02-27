function u = unitVec(a)
%UNITVEC makes unit vector frob vector
arguments (Input)
    a {mustBeNumeric}
end

u = a / norm(a);

end