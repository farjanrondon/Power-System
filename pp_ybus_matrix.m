
function [ppYBUS, n_gens, new_buses] = pp_ybus_matrix(YBUS, gen_data, load_data, bus_table)
    
    M_ = YBUS;
    % M_ is an auxliar matrix
    n_gens = length(gen_data.bus_i);
    n_buses = length(bus_table.bus_i);
    
    % load buses
    idx = load_data.bus_i;
    % adding up the loads
    for a = 1:1:length(idx)
        M_(idx(a), idx(a)) = M_(idx(a), idx(a)) + load_data.Y_loads(a);
    end

    % matrix expantion
    Y_bb = M_;
    Y_ba = zeros(n_buses, n_gens);
    Y_ab = zeros(n_gens, n_buses);
    diag_terms = 1 ./ (1j .* gen_data.X_prime_d_pu);
    Y_aa = diag(diag_terms);

    % ppYBUS
    ppYBUS = [Y_bb, Y_ba; [Y_ab, Y_aa]];

    % new buses
    new_buses = n_buses+1:1:n_buses+n_gens;
    for b = 1:1:n_gens
        idx1 = new_buses(b);
        idx2 = gen_data.bus_i(b);
        ppYBUS(idx2, idx2) = ppYBUS(idx2, idx2) + diag_terms(b);
        ppYBUS(idx1, idx2) = ppYBUS(idx1, idx2) + (-1 * diag_terms(b));
        ppYBUS(idx2, idx1) = ppYBUS(idx2, idx1) + (-1 * diag_terms(b));
    end

end
