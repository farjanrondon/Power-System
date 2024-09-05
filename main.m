
% main archive
%

clc;
clear;

input_file = "sys_val.xlsx";
% function to read input data from the input_file
[parameters_c1, parameters_c2, parameters_c3, bus_table, lines_table, trx_table, shunt_table] = read_data(input_file);

% function to determinate the ybus matrix
[A_matrix, Y_primitive, YBUS] = ybus_matrix(bus_table, lines_table, trx_table, shunt_table);

% function of loads modeling
[P_esp, P_dem, Q_esp, Q_dem, S_esp] = load_model(bus_table);

% dc method
if strcmp(parameters_c1{4}, "Y") | strcmp(parameters_c2{4}, "Y")
    [dc_result] = dc_method(bus_table, lines_table, trx_table, P_esp);
    % dc_result is a table if the DC method is applied

    if strcmp(parameters_c2{4}, "Y")
        % ---> write_data
    end

    % assign the dc angles to the bus_table and use it as start values
    if strcmp(parameters_c1{4}, "Y")
        bus_table.bus_angle_radians = dc_result.bus_angle * pi / 180;
    end
end

% gauss seidel method
if strcmp(parameters_c2{1}, "Y")
    [gs_voltage, gs_parameters] = gs_method(parameters_c1, bus_table, YBUS, P_esp, S_esp);
    [gs_result, gs_flow, gs_balance] = s_calculus(bus_table, lines_table, trx_table, YBUS, P_dem, Q_dem, gs_voltage);
end

% newton rhapson method
if strcmp(parameters_c2{2}, "Y")
    %[nr_voltage, nr_parameters] = nr_method(parameters_c1, bus_table, YBUS, P_esp, Q_esp);
    %[nr_result, nr_flow, nr_balance] = s_calculus(bus_table, lines_table, trx_table, YBUS, P_dem, Q_dem, nr_voltage);
end
