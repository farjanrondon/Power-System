
% read data file
%

function [parameters_c1, parameters_c2, parameters_c3, bus_table, lines_table, trx_table, shunt_table] = read_data(name)
    
    % Parameters Sheet
    parameters_table = readtable(name, "Sheet", "PARAMETERS");
    
    setting_values = parameters_table.values;
    min_error = str2double(setting_values{1});
    max_iter = str2double(setting_values{2});
    output_name = setting_values{3};
    use_dc_angles = setting_values{4};
    parameters_c1 = {min_error; max_iter; output_name; use_dc_angles};
    % order: Convergence Error, Iterations Number, File Output Name,
    % Verfication to use the angles of DC method.
    
    parameters_c2 = parameters_table.run_Y_or_N;
    % order: Verification of the GS, NR, FD and DC method.

    stabil_analysis = parameters_table.run_Y_or_N_1;
    apply_analysis = stabil_analysis{1};
    analysis_method = stabil_analysis(3:4);
    parameters_c3 = [apply_analysis; analysis_method];
    % order: Verification to apply analysis, Heun, RK4.
    %
    
    
    % Bus Sheet
    bus_table = readtable(name, "Sheet", "BUS");
    % The angles needs to be expresed in radians
    bus_table.Properties.VariableNames{8} = 'bus_angle_radians';
    bus_table.bus_angle_radians = bus_table.bus_angle_radians .* pi ./ 180;
    %
    
    
    % Lines Sheet
    lines_table = readtable(name, "Sheet", "LINES");
    % Calculate the line admitances values for each nexus
    Y_lines = 1 ./ (lines_table.R_pu + (1j .* lines_table.X_pu));
    Y_shunt = 1j .* lines_table.B_shunt_pu;
    % Re-order the table
    lines_table.B_shunt_pu = [];
    lines_table.X_pu = [];
    lines_table.R_pu = [];
    lines_table.Y_lines = Y_lines;
    lines_table.Y_shunt = Y_shunt;
    %
    

    % TRX Sheet
    trx_table = readtable(name, "Sheet", "TRX");
    
    if ~isempty(trx_table) 
        % Calculate the pi model of the trx
        Y_cc = 1 ./ (1j .* trx_table.X_cc_pu);
        Y_ij = trx_table.TAP .* Y_cc;
        Y_io = (1 - trx_table.TAP) .* Y_cc;
        Y_jo = ((trx_table.TAP).^2 - trx_table.TAP) .* Y_cc;
        % Re-order the table
        trx_table.TAP = [];
        trx_table.Y_ij = Y_ij;
        trx_table.Y_io = Y_io;
        trx_table.Y_jo = Y_jo;
    else
        trx_table = "isempty";
        % if trx_table is empty, mean that have no trx elements in the
        % electrical system.
    end
    %


    % SHUNT_ELEMENTS Sheet
    shunt_table = readtable(name, "Sheet", "SHUNT_ELEMENTS");

    if ~isempty(shunt_table) 
        Y_element =  1 ./ (shunt_table.R_pu + (1j .* shunt_table.X_pu));
        % Re_order the table
        shunt_table.X_pu = [];
        shunt_table.R_pu = [];
        shunt_table.Y_element = Y_element;
    else
        shunt_table = "isempty";
        % It means that isn't shunt elements in the system.
    end
    %

end
