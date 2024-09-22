
function [Y_kron_f, Y_kron_af] = y_kron_fault(lines_table, ppYBUS, n_gens, busi_, busj_)
    
    % Pe_f --> electrical power during the faut, implies make cero voltage
    % in the closest bus to the fault point
    aux1_ppYBUS = ppYBUS;
    aux1_ppYBUS(busi_,:) = [];
    aux1_ppYBUS(:,busi_) = [];
    % kron matrix for this condition (during the fault)
    [Y_kron_f] = y_kron_matrix(aux1_ppYBUS, n_gens);
    
    % Pe_af --> electrical power after fault, implies take out of the
    % operation the line where the fault did happen
    aux2_ppYBUS = ppYBUS;

    aux_v1 = [...
        lines_table(lines_table.bus_i==busi_ & lines_table.bus_j==busj_,:); ...
        lines_table(lines_table.bus_i==busj_ & lines_table.bus_j==busi_,:) ...
        ];

    if length(aux_v1.bus_i) > 1
        to_print = [table((1:1:length(aux_v1.bus_i))'), aux_v1];
        to_print.Properties.VariableNames{1} = "option";
        fprintf("there are multiple links between the selected buses, chose the required option for the analysis: \n ");
        fprintf(to_print);
        opt = input("option: ");
    else
        opt = 1;
    end
    
    aux2_ppYBUS(busi_, busj_) = aux2_ppYBUS(busi_, busj_) + aux_v1.Y_lines(opt);
    aux2_ppYBUS(busj_, busi_) = aux2_ppYBUS(busj_, busi_) + aux_v1.Y_lines(opt);
    aux2_ppYBUS(busi_, busi_) = aux2_ppYBUS(busi_, busi_) - aux_v1.Y_lines(opt) - aux_v1.Y_shunt(opt);
    aux2_ppYBUS(busj_, busj_) = aux2_ppYBUS(busj_, busj_) - aux_v1.Y_lines(opt) - aux_v1.Y_shunt(opt);

    % kron matrix for this condition
    [Y_kron_af] = y_kron_matrix(aux2_ppYBUS, n_gens);
    
end
