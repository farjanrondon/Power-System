
function [fd_voltage, fd_parameters] = fd_method(parameters_c1, bus_table, YBUS, P_esp, Q_esp)
    
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
    fd_iter = 1;
    % unknow buses number
    var_angles = [ ...
        bus_table(strcmp(bus_table.bus_type, "PQ"),:).bus_i; ...
        bus_table(strcmp(bus_table.bus_type, "PV"),:).bus_i ...
        ];
    n_angles = length(var_angles);
    var_modules = bus_table(strcmp(bus_table.bus_type, "PQ"),:).bus_i;
    
    n_buses = length(aux_table.bus_i);
    % susceptance matrix
    B = imag(YBUS);
    
    pB = B;
    for a = flip(1:1:n_buses)
        if ~ismember(a, var_angles)
            pB(a,:) = [];
            pB(:,a) = [];
        end
    end
    
    ppB = B;
    for b = flip(1:1:n_buses)
        if ~ismember(b, var_modules)
            ppB(b,:) = [];
            ppB(:,b) = [];
        end
    end
    
    tic;
    while true
        
        % define the functions
        [delta_P, delta_Q] = delta_functions(P_esp, Q_esp, aux_table, YBUS, var_angles, var_modules);

        % fast decoupled method for the angles
        aux_volt_1 = [ ...
            aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_voltage_pu; ...
            aux_table(strcmp(aux_table.bus_type, "PV"),:).bus_voltage_pu ...
            ];
        aux_angles = aux_values(1:n_angles) - inv(pB) * (delta_P ./ aux_volt_1);
        % fast decoupled method for the modules
        aux_volt_2 = aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_voltage_pu;
        aux_modules = aux_values(n_angles+1:end) - inv(ppB) * (delta_Q ./ aux_volt_2);

        aux_values = [aux_angles; aux_modules];
        
        fd_error = max(abs(start_values - aux_values));
        if fd_error <= parameters_c1{1} || fd_iter == parameters_c1{2}
            aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_angle_radians = aux_values(1:length(var_modules));
            aux_table(strcmp(aux_table.bus_type, "PV"),:).bus_angle_radians = aux_values(length(var_modules)+1:length(var_angles));
            aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_voltage_pu = aux_values(length(var_angles)+1:end);
            break;
        end

        start_values = aux_values;
        aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_angle_radians = aux_values(1:length(var_modules));
        aux_table(strcmp(aux_table.bus_type, "PV"),:).bus_angle_radians = aux_values(length(var_modules)+1:length(var_angles));
        aux_table(strcmp(aux_table.bus_type, "PQ"),:).bus_voltage_pu = aux_values(length(var_angles)+1:end);
        fd_iter = fd_iter + 1;

    end
    fd_time = toc;
    
    fd_voltage = aux_table.bus_voltage_pu .* exp(1j .* aux_table.bus_angle_radians);
    fd_parameters = {fd_iter; fd_error; fd_time};
    
end
