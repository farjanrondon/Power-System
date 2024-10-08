
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

% creating the output data file
[output_file] = output_archive(input_file, parameters_c1{3});

% dc method
if strcmp(parameters_c1{4}, "Y") | strcmp(parameters_c2{4}, "Y")
    [dc_result] = dc_method(bus_table, lines_table, trx_table, P_esp);
    % dc_result is a table if the DC method is applied

    if strcmp(parameters_c2{4}, "Y")
        writetable(dc_result, output_file, ... 
               "Sheet", "DC_RESULTS", ...
               "Range", "A2", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );
    end

    % assign the dc angles to the bus_table and use it as start values
    if strcmp(parameters_c1{4}, "Y")
        bus_table.bus_angle_radians = dc_result.bus_angle * pi / 180;
    end
end

% methods errors
dict_err = dictionary();

% gauss seidel method
if strcmp(parameters_c2{1}, "Y")
    [gs_voltage, gs_parameters] = gs_method(parameters_c1, bus_table, YBUS, P_esp, S_esp);
    [gs_result, gs_flow, gs_balance] = s_calculus(bus_table, lines_table, trx_table, YBUS, P_dem, Q_dem, gs_voltage);
    write_data("GS", output_file, gs_parameters, gs_result, gs_flow, gs_balance);
    dict_err = insert(dict_err, "gs", gs_parameters{2});
end

% newton rhapson method
if strcmp(parameters_c2{2}, "Y")
    [nr_voltage, nr_parameters] = nr_method(parameters_c1, bus_table, YBUS, P_esp, Q_esp);
    [nr_result, nr_flow, nr_balance] = s_calculus(bus_table, lines_table, trx_table, YBUS, P_dem, Q_dem, nr_voltage);
    write_data("NR", output_file, nr_parameters, nr_result, nr_flow, nr_balance);
    dict_err = insert(dict_err, "nr", nr_parameters{2});
end

% fast-decoupled method
if strcmp(parameters_c2{3}, "Y")
    [fd_voltage, fd_parameters] = fd_method(parameters_c1, bus_table, YBUS, P_esp, Q_esp);
    [fd_result, fd_flow, fd_balance] = s_calculus(bus_table, lines_table, trx_table, YBUS, P_dem, Q_dem, fd_voltage);
    write_data("FD", output_file, fd_parameters, fd_result, fd_flow, fd_balance);
    dict_err = insert(dict_err, "fd", fd_parameters{2});
end


% angular transient stability analysis
if strcmp(parameters_c3{1}, "Y")

    % method with lower error
    method_ = keys(dict_err);
    method_ = method_( values(dict_err) == min(values(dict_err)) );

    % voltage and power data pre-fault
    volts_ = eval(method_ + "_voltage");
    rsult_ = eval(method_ + "_result");
    pflow_ = eval(method_ + "_flow");
    
    % femi and pre-fault current of the generators, admitances loads
    [gen_data, load_data] = angle_stability(bus_table, volts_, rsult_);

    % ppYBUS matrix, expanded matrix
    [ppYBUS, n_gens, new_buses] = pp_ybus_matrix(YBUS, gen_data, load_data, bus_table);
    % Kron reduction
    [Y_kron] = y_kron_matrix(ppYBUS, n_gens);
    % electrical power calculus
    [Pe_bf] = pe_calculus(gen_data, Y_kron, n_gens);

    % bus and time
    beep;
    fprintf("specify the buses between wihch the fault occurs and the time to solve the fault.\n");
    while true
        busi_ = input("bus i: ");
        % assum busi_ as the closest bus to the fault point in the system
        busj_ = input("bus j: ");
        if ( ~ismember(busi_, lines_table.bus_i) || ~ismember(busj_, lines_table.bus_i) || ~ismember(busj_, lines_table.bus_j) || ~ismember(busi_, lines_table.bus_j) ) && ( length(lines_table(lines_table.bus_i==busi_ & lines_table.bus_j==busj_,:).id) + length(lines_table(lines_table.bus_i==busj_ & lines_table.bus_j==busi_,:).id) == 0 )
            fprintf("\n\ninvalid bus\n");
            beep;
            continue;
        else
            break;
        end
    end
    while true
        time_ = input("time: ");
        if time_ <= 0
            fprintf("\n\ninvalid time\n");
            beep;
            continue;
        else
            break;
        end
    end

    % knowing bus_ it's possible to determinte the Y_kron matrix during
    % fault and post-fault.
    [Yk_f, Yk_af] = y_kron_fault(lines_table, ppYBUS, n_gens, busi_, busj_);
    
    % create the equation formula to solve numerically
    oscillation_eq(parameters_c3, gen_data, Pe_bf, time_, Yk_f, Yk_af, output_file);

end
