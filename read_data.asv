
% read data file
%

function [cell_settings, methods_to_apply, cell_stabil_analysis] = read_data(name)
    
    % Parameters Sheet
    parameters_table = readtable(name, "Sheet", "PARAMETERS");
    
    setting_values = parameters_table.values;
    min_error = str2double(setting_values{1});
    max_iter = str2double(setting_values{2});
    output_name = setting_values{3};
    use_dc_angles = setting_values{4};
    cell_settings = {min_error; max_iter; output_name; use_dc_angles};
    % order: Convergence Error, Iterations Number, File Output Name,
    % Verfication to use the angles of DC method.
    
    methods_to_apply = parameters_table.run_Y_or_N;
    % order: Verification of the GS, NR, FD and DC method.

    stabil_analysis = parameters_table.run_Y_or_N_1;
    apply_analysis = stabil_analysis{1};
    analysis_method = stabil_analysis(3:4);
    cell_stabil_analysis = [apply_analysis; analysis_method];
    % order: Verification to apply analysis, Heun, RK4.
    %


    % Bus Sheet
    
    %
    
end
