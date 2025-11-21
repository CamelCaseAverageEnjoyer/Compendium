function x = diff_evolve(func,lb,ub,Nvec,Niter)
F = 0.2;
p = 0.5;
if isempty(Nvec)
    Nvec = 300;
end
if isempty(Niter)
    Niter = 50;
end

for j=1:Nvec
    w(j, :) = rand(size(ub)) .* (ub - lb) + lb;
end

for i=1:Niter
    v = w;
    for j=1:Nvec
        all_ind = 1:Nvec;
        req_ind = all_ind(all_ind ~= j);
        rand_ind = req_ind(randperm(numel(req_ind), 3));
        v_3 = v(rand_ind, :);

        mutant = v_3(1,:) + F * (v_3(2,:) - v_3(3,:));
        % Limitation
        for ii=1:size(v,2)
            if mutant(ii) > ub(ii)
                mutant(ii) = ub(ii);
            end
            if mutant(ii) < lb(ii)
                mutant(ii) = lb(ii);
            end
        end

        % Screshivanie
        for ii=1:size(v,2)
            if rand() > p
                mutant(ii) = v(j,ii);
            end
        end
        trial = mutant;

        % Sravnenie
        if func(trial) < func(v(j,:))
            v(j,:) = trial;
        end
    end
    w = v;
end

Fmin = inf;
for j=1:Nvec
    F1 = func(w(j,:));
    if Fmin > F1
        Fmin = F1;
        x = w(j,:);
    end
end

disp("DiffEvolve residual = "+num2str(Fmin))

end

