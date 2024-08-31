
function [gs_voltage, gs_parameters] = gs_method(parameters_c1, bus_table, YBUS, P_esp, S_esp)
    
    % start values
    start_values = bus_table.bus_voltage_pu .* exp(1j .* bus_table.bus_angle_radians);
    aux_values = start_values;
    % number of iterations
    gs_iter = 1;
    % buses info
    n = length(bus_table.bus_i);
    type = bus_table.bus_type;
    
    tic;
    while true
        for a = 1:1:n
            
            aux_sum = 0;
            for b = 1:1:n
                if b ~= a
                    aux_sum = aux_sum + aux_values(b) * YBUS(a,b);
                end
            end

            if strcmp(type{a}, "PQ")

                aux_v = inv(YBUS(a,a)) * ( conj( ( S_esp(a) / aux_values(a) ) ) - aux_sum );
                aux_values(a) = aux_v;

            elseif strcmp(type{a}, "PV")

                add_term = aux_values(a) * YBUS(a,a);
                aux_q = -imag( conj(aux_values(a)) * (aux_sum + add_term) );
                aux_v = inv(YBUS(a,a)) * ( conj( (P_esp(a) + (1j * aux_q)) / aux_values(a) ) - aux_sum );
                aux_values(a) = (aux_v / abs(aux_v)) * abs(start_values(a));

            end

        end
        
        gs_error = max(abs(start_values - aux_values));
        if gs_error <= parameters_c1{1} || gs_iter == parameters_c1{2}
            break;
        end

        start_values = aux_values;
        gs_iter = gs_iter + 1;

    end
    gs_time = toc;
    
    gs_voltage = aux_values;
    gs_parameters = {gs_iter; gs_error; gs_time};
    
end
