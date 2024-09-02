
function [nr_voltage, nr_parameters] = nr_method(parameters_c1, bus_table, YBUS, P_esp, Q_esp)
    
    % start values
    start_values = [ ...
        bus_table(strcmp(bus_table.bus_type, "PQ"),:).bus_angle_radians; ...
        bus_table(strcmp(bus_table.bus_type, "PV"),:).bus_angle_radians; ...
        bus_table(strcmp(bus_table.bus_type, "PQ"),:).bus_voltage_pu ...
        ];
    aux_values = start_values;
    % iterations counter
    nr_iter = 1;
    % unknow buses number
    var_angles = [
        bus_table(strcmp(bus_table.bus_type, "PQ"),:).bus_i; ...
        bus_table(strcmp(bus_table.bus_type, "PV"),:).bus_i ...
        ];
    var_modules = bus_table(strcmp(bus_table.bus_type, "PQ"),:).bus_i;

    tic;
    while true
        
        % define jacobian
        [J_matrix] = jacobian(aux_values, var_angles, var_modules);
        
        nr_error = max(abs(start_values - aux_values));
        if nr_error <= parameters_c1{1} || nr_iter == parameters_c1{2}
            break;
        end

        start_values = aux_values;
        nr_iter = nr_iter + 1;

    end
    nr_time = toc;
    
    nr_voltage = 0;
    nr_parameters = 0;
    
end