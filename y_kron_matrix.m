
function [Y_kron] = y_kron_matrix(ppYBUS, n_gens)
    
    n_buses = length(ppYBUS) - n_gens;

    % sub-arrays
    Y_bb = ppYBUS(1:n_buses, 1:n_buses);
    Y_ba = ppYBUS(1:n_buses, n_buses+1:end);
    Y_ab = ppYBUS(n_buses+1:end, 1:n_buses);
    Y_aa = ppYBUS(n_buses+1:end, n_buses+1:end);

    % Kron reduction
    Y_kron = Y_aa - (Y_ab * inv(Y_bb) * Y_ba);
    
end
