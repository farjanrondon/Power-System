
function [Pe_] = pe_calculus(gen_, Y_, n_gens)
    
    Pe_ = zeros(n_gens, 1);

    for a = 1:1:n_gens
        aux = 0;
        for b = 1:1:n_gens
            aux = aux + gen_.E_abs(b) * abs(Y_(a,b)) * cosd(angle(Y_(a,b))*180/pi - gen_.E_angle(a) + gen_.E_angle(b));
        end
        Pe_(a) = gen_.E_abs(a) * aux;
    end
    
end
