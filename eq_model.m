
function eq_eval = eq_model(gen_data, Pm, Ykron, ang_)
    
    gen_ = gen_data;
    gen_.E_angle = gen_.E_angle * pi / 180;
    gen_.I_abs = [];
    gen_.I_angle = [];
    gen_.P_m = Pm;
    gen_(~strcmp(gen_.bus_type, "SLACK"),:).E_angle = ang_;
    
    data_gens = gen_(~strcmp(gen_.bus_type, "SLACK"),:);
    data_slck = gen_(strcmp(gen_.bus_type, "SLACK"),:);

    eq_eval = zeros(length(data_gens.bus_i), 1);

    aux_v = [];
    
    for a = 1:1:length(gen_.bus_i)
        
        aux_ = 0;
        for b = 1:1:length(gen_.bus_i)
            aux_ = aux_ + gen_.E_abs(a) * gen_.E_abs(b) * abs(Ykron(a,b)) * cos(angle(Ykron(a,b)) - gen_.E_angle(a) + gen_.E_angle(b));
        end

        if strcmp(gen_.bus_type{a}, "SLACK")
            aux_s = aux_;
        else
            aux_v = [aux_v; aux_];
        end

    end
    
    for c = 1:1:length(data_gens.bus_i)
        
        Hi_ = data_gens.H(c);
        Hs_ = data_slck.H(1);
        f_o = 60;

        aux1_ = ( (pi*f_o*(Hi_ + Hs_)) / (Hi_ * Hs_) ) * ( ((Hs_*data_gens.P_m(c) - Hi_*data_slck.P_m(1)) / (Hi_ + Hs_)) - ((Hs_*aux_v(c) - Hi_*aux_s) / (Hi_ + Hs_)) );
        eq_eval(c) = aux1_;
        
    end
        
end