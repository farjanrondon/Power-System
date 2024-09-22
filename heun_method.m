
function [speed_results, angle_results] = heun_method(gen_data, P_m, Yk_f, Yk_af, t_1, t_2, h, time_d, ang_values, spd_values)
    
    eq_eval = @(gen_data, Pm, Ykron, ang_) eq_model(gen_data, Pm, Ykron, ang_);
    
    % output data structures
    speed_results = zeros(length(t_1) + length(t_2), length(gen_data(~strcmp(gen_data.bus_type, "SLACK"),:).bus_i) + 1);
    speed_results(:,1) = [transpose(t_1); transpose(t_2)];
    angle_results = speed_results;
    % auxiliar start values
    aux_ang = ang_values;
    aux_spd = spd_values;
    
    for a = 1:1:length(speed_results(:,1))
    
        if speed_results(a,1) <= time_d
            Ykron = Yk_f;
        else
            Ykron = Yk_af;
        end
        
        K1_ = eq_eval(gen_data, P_m, Ykron, aux_ang);
        Y_p = aux_spd + K1_ * h;
        aux1_d = aux_ang + Y_p * h;

        K2_ = eq_eval(gen_data, P_m, Ykron, aux1_d);

        K_ = 0.5 .* (K1_ + K2_);
        w_ = 0.5 .* (aux_spd + Y_p);

        aux_spd = aux_spd + K_ * h;
        aux_ang = aux_ang + w_ * h;

        % saving values
        speed_results(a,2:end) = transpose(aux_spd);
        angle_results(a,2:end) = transpose(aux_ang);
        
    end
    
end