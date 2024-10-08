
function [J_matrix] = jacobian(table_, YBUS, var_angles, var_modules)
    
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
                    if c ~= var_angles(a)
                        aux = aux + table_.bus_voltage_pu(c) * abs(YBUS(var_angles(a),c)) * sin(table_.bus_angle_radians(var_angles(a)) - table_.bus_angle_radians(c) - angle(YBUS(var_angles(a),c)));
                    end
                end
                M_1(a,b) = table_.bus_voltage_pu(var_angles(a)) * aux;
            else
                M_1(a,b) = -1 * table_.bus_voltage_pu(var_angles(a)) * table_.bus_voltage_pu(var_angles(b)) * abs(YBUS(var_angles(a),var_angles(b))) * sin(table_.bus_angle_radians(var_angles(a)) - table_.bus_angle_radians(var_angles(b)) - angle(YBUS(var_angles(a),var_angles(b))));
            end

        end
    end

    % M_2
    for d = 1:1:n_ang
        for e = 1:1:n_mod

            if var_angles(d) == var_modules(e)
                aux = 0;
                for f = 1:1:n_buses
                    if f ~= var_angles(d)
                        aux = aux + table_.bus_voltage_pu(f) * abs(YBUS(var_angles(d),f)) * cos(table_.bus_angle_radians(var_angles(d)) - table_.bus_angle_radians(f) - angle(YBUS(var_angles(d),f)));
                    end
                end
                M_2(d,e) = -2 * table_.bus_voltage_pu(var_angles(d)) * abs(YBUS(var_angles(d),var_angles(d))) * cos(angle(YBUS(var_angles(d),var_angles(d)))) - aux;
            else
                M_2(d,e) = -1 * table_.bus_voltage_pu(var_angles(d)) * abs(YBUS(var_angles(d),var_modules(e))) * cos(table_.bus_angle_radians(var_angles(d)) - table_.bus_angle_radians(var_modules(e)) - angle(YBUS(var_angles(d), var_modules(e))));
            end

        end
    end

    % M_3
    for g = 1:1:n_mod
        for h = 1:1:n_ang

            if var_modules(g) == var_angles(h)
                aux = 0;
                for k = 1:1:n_buses
                    if k ~= var_modules(g)
                        aux = aux + table_.bus_voltage_pu(k) * abs(YBUS(var_modules(g), k)) * cos(table_.bus_angle_radians(var_modules(g)) - table_.bus_angle_radians(k) - angle(YBUS(var_modules(g), k)));
                    end
                end
                M_3(g,h) = -1 * table_.bus_voltage_pu(var_modules(g)) * aux;
            else
                M_3(g,h) = table_.bus_voltage_pu(var_modules(g)) * table_.bus_voltage_pu(var_angles(h)) * abs(YBUS(var_modules(g), var_angles(h))) * cos(table_.bus_angle_radians(var_modules(g)) - table_.bus_angle_radians(var_angles(h)) - angle(YBUS(var_modules(g), var_angles(h))));
            end

        end
    end

    % M_4
    for m = 1:1:n_mod
        for n = 1:1:n_mod

            if var_modules(m) == var_modules(n)
                aux = 0;
                for p = 1:1:n_buses
                    if p ~= var_modules(m)
                        aux = aux + table_.bus_voltage_pu(p) * abs(YBUS(var_modules(m), p)) * sin(table_.bus_angle_radians(var_modules(m)) - table_.bus_angle_radians(p) - angle(YBUS(var_modules(m), p)));
                    end
                end
                M_4(m,n) = 2 * table_.bus_voltage_pu(var_modules(m)) * abs(YBUS(var_modules(m), var_modules(m))) * sin(angle(YBUS(var_modules(m), var_modules(m)))) - aux;
            else
                M_4(m,n) = -1 * table_.bus_voltage_pu(var_modules(m)) * abs(YBUS(var_modules(m), var_modules(n))) * sin(table_.bus_angle_radians(var_modules(m)) - table_.bus_angle_radians(var_modules(n)) - angle(YBUS(var_modules(m), var_modules(n))));
            end

        end
    end

    J_matrix = [M_1, M_2; [M_3, M_4]];
    
end