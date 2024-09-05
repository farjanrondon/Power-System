
function [J_matrix] = jacobian(table_, YBUS, values, var_angles, var_modules)
    
    n_ang = length(var_angles);
    n_mod = length(var_modules);
    n_buses = length(table_.bus_i);

    M_1 = zeros(length(n_ang));
    M_2 = zeros(length(n_ang), length(n_mod));
    M_3 = zeros(length(n_mod), length(n_ang));
    M_4 = zeros(length(n_mod));
    % M_i are sub-matrix of the jacobian
    
    % M_1
    for a = 1:1:n_ang
        for b = 1:1:n_ang

            if var_angles(a) == var_angles(b)
                aux = 0;
                for c = 1:1:n_buses
                    if c ~= var_angles(b)
                        aux = aux + table_.bus_voltage_pu(c) * abs(YBUS(var_angles(b),c)) * sin(table_.bus_angle_radians(var_angles(b)) - table_.bus_angle_radians(c) - angle(YBUS(var_angles(b),c)));
                    end
                end
                M_1(a,b) = table_.bus_voltage_pu(var_angles(b)) * aux;
            else
                M_1(a,b) = -1 * table_.bus_voltage_pu(var_angles(b)) * table_.bus_voltage_pu(var_angles(a)) * abs(YBUS(var_angles(b),var_angles(a))) * sin(table_.bus_angle_radians(var_angles(b)) - table_.bus_angle_radians(var_angles(a)) - angle(YBUS(var_angles(b),var_angles(a))));
            end

        end
    end

    % M_2
    for d = 1:1:n_ang
        for e = 1:1:n_mod

            if var_angles(d) == var_modules(e)
                aux = 0;
                for f = 1:1:n_buses
                    if f ~= var_modules(e)
                        aux = aux + table_.bus_voltage_pu(f) * abs(YBUS(var_modules(e),f)) * cos(table_.bus_angle_radians(var_modules(e)) - table_.bus_angle_radians(f) - angle(YBUS(var_modules(e),f)));
                    end
                end
                M_2(d,e) = -2 * table_.bus_voltage_pu(var_modules(e)) * abs(YBUS(var_modules(e),var_modules(e))) * cos(angle(YBUS(var_modules(e),var_modules(e)))) - aux;
            else
                M_2(d,e) = -1 * table_.bus_voltage_pu(var_modules(e)) * abs(YBUS(var_modules(e),var_angles(d))) * cos(table_.bus_angle_radians(var_modules(e)) - table_.bus_angle_radians(var_angles(d)) - angle(YBUS(var_modules(e), var_angles(d))));
            end

        end
    end

    % M_3
    for g = 1:1:n_mod
        for h = 1:1:n_ang

            if var_modules(g) == var_angles(h)
                aux = 0;
                for k = 1:1:n_buses
                    if k ~= var_angles(h)
                        aux = aux + table_.bus_voltage_pu(k) * abs(YBUS(var_angles(h), k)) * cos(table_.bus_angle_radians(var_));
    
end