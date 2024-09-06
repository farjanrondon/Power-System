
function [delta_P, delta_Q] = delta_functions(P_esp, Q_esp, table_, YBUS, var_angles, var_modules)

    % number of buses
    n_buses = length(table_.bus_i);

    delta_P = zeros(length(var_angles), 1);
    for a = 1:1:length(var_angles)

        idx = var_angles(a);
        aux_sum = 0;

        for b = 1:1:n_buses
            if b ~= idx
                aux_sum = aux_sum + table_.bus_voltage_pu(b) * abs(YBUS(idx,b)) * cos(table_.bus_angle_radians(idx) - table_.bus_angle_radians(b) - angle(YBUS(idx, b)));
            end
        end

        delta_P(a) = P_esp(idx) - ( (table_.bus_voltage_pu(idx)^2) * abs(YBUS(idx,idx)) * cos(angle(YBUS(idx,idx))) + table_.bus_voltage_pu(idx) * aux_sum );

    end

    delta_Q = zeros(length(var_modules), 1);
    for c = 1:1:length(var_modules)

        idx = var_modules(c);
        aux_sum = 0;

        for d = 1:1:n_buses
            if d ~= idx
                aux_sum = aux_sum + table_.bus_voltage_pu(d) * abs(YBUS(idx,d)) * sin(table_.bus_angle_radians(idx) - table_.bus_angle_radians(d) - angle(YBUS(idx, d))) ;
            end
        end

        delta_Q(c) = Q_esp(idx) - ( -1 * (table_.bus_voltage_pu(idx)^2) * abs(YBUS(idx,idx)) * sin(angle(YBUS(idx,idx))) + table_.bus_voltage_pu(idx) * aux_sum );

    end
    
end
