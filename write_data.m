
function write_data(method, output_file, parameters_cell, result_table, flow_table, balance_table)
    
    % parameters and result data
    result_ = method + "_RESULTS";
    writetable(table(parameters_cell{1}), output_file, ... 
               "Sheet", result_, ...
               "Range", "B1", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );
    writetable(table(parameters_cell{2}), output_file, ... 
               "Sheet", result_, ...
               "Range", "E1", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );
    writetable(table(parameters_cell{3}), output_file, ... 
               "Sheet", result_, ...
               "Range", "H1", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );
    writetable(result_table, output_file, ... 
               "Sheet", result_, ...
               "Range", "A3", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );

    % power flow data
    flow_ = method + "_POWER_FLOW";
    writetable(flow_table, output_file, ... 
               "Sheet", flow_, ...
               "Range", "A2", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );

    % power balance data
    balance_ = method + "_POWER_BALANCE";
    writetable(balance_table, output_file, ... 
               "Sheet", balance_, ...
               "Range", "A3", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );

end
