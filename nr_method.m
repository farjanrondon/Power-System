
function [nr_voltage, nr_parameters] = nr_method(parameters_c1, bus_table, YBUS, P_esp, Q_esp)
    
    aux_table = table(bus_table.bus_i, bus_table.bus_type, bus_table.bus_voltage_pu, bus_table.bus_angle_radians);
    aux_table.Properties.VariableNames = ["bus_i", "bus_type", "bus_voltage_pu", "bus_angle_radians"];
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
        [J_matrix] = jacobian(aux_table, YBUS, var_angles, var_modules);
        % define the functions
        [delta_P, delta_Q] = delta_functions(P_esp, Q_esp, aux_table, YBUS, var_angles, var_modules);

        % newton raphson method
        aux_values = aux_values - inv(J_matrix) * [delta_P; delta_Q];
        
        nr_error = max(abs(start_values - aux_values));
        if nr_error <= parameters_c1{1} || nr_iter == parameters_c1{2}
            aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_angle_radians = aux_values(1:length(var_modules));
            aux_table(strcmp(aux_table.bus_type, "PV"),:).bus_angle_radians = aux_values(length(var_modules)+1:length(var_angles));
            aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_voltage_pu = aux_values(length(var_angles)+1:end);
            break;
        end

        start_values = aux_values;
        aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_angle_radians = aux_values(1:length(var_modules));
        aux_table(strcmp(aux_table.bus_type, "PV"),:).bus_angle_radians = aux_values(length(var_modules)+1:length(var_angles));
        aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_voltage_pu = aux_values(length(var_angles)+1:end);
        nr_iter = nr_iter + 1;

    end
    nr_time = toc;
    
    nr_voltage = aux_table.bus_voltage_pu .* exp(1j .* aux_table.bus_angle_radians);
    nr_parameters = {nr_iter; nr_error; nr_time};
    
end