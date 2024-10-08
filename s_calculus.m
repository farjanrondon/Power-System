
function [result, s_flow, s_balance] = s_calculus(bus_table, lines_table, trx_table, YBUS, P_dem, Q_dem, voltg)
    
    % lines and trx's data
    if istable(trx_table)
        data_table = table( [lines_table.bus_i; trx_table.bus_i], ...
            [lines_table.bus_j; trx_table.bus_j], [lines_table.Y_lines; trx_table.Y_ij], ...
            [lines_table.Y_shunt; trx_table.Y_io], [lines_table.Y_shunt; trx_table.Y_jo] );
    else
        data_table = table( lines_table.bus_i, lines_table.bus_j, ...
            lines_table.Y_lines, lines_table.Y_shunt, lines_table.Y_shunt );
    end
    data_table.Properties.VariableNames = ["bus_i", "bus_j", "Y_ij", "Y_io", "Y_jo"];

    % power flow for the nexus of the system
    S_ij_ji = zeros(length(data_table.bus_i), 2);
    for a = 1:1:length(data_table.bus_i)
        S_ij_ji(a, 1) = power_flow( ...
            voltg(data_table.bus_i(a)), voltg(data_table.bus_j(a)), ...
            data_table.Y_ij(a), data_table.Y_io(a) );

        S_ij_ji(a, 2) = power_flow( ...
            voltg(data_table.bus_j(a)), voltg(data_table.bus_i(a)), ...
            data_table.Y_ij(a), data_table.Y_jo(a) );
    end

    function [pflow_value] = power_flow(Vi, Vj, Yij, Yo)
        pflow_value = (abs(Vi)^2) * conj(Yo) + Vi * conj((Vi - Vj) * Yij);
    end
    
    S_losses = S_ij_ji(:,1) + S_ij_ji(:,2);
    s_flow_values = [S_ij_ji, S_losses];

    if ~istable(trx_table)
        trx_table = table([], [], []);
        trx_table.Properties.VariableNames = ["id", "bus_i", "bus_j"];
    end

    s_flow = table( [lines_table.id; trx_table.id], ...
        [lines_table.bus_i; trx_table.bus_i], [lines_table.bus_j; trx_table.bus_j], ...
        real(s_flow_values(:,1)), imag(s_flow_values(:,1)), real(s_flow_values(:,2)), ...
        imag(s_flow_values(:,2)), real(s_flow_values(:,3)), imag(s_flow_values(:,3))...
        );
    s_flow.Properties.VariableNames = ["id", "bus_i", "bus_j", "P_ij_pu", ...
                "Q_ij_pu", "P_ji_pu", "Q_ji_pu", "P_loss_pu", "Q_loss_pu"];

    % caculated power in every bus of the system
    n_buses  = length(bus_table.bus_i);

    P_calc = zeros(n_buses, 1);
    for b = 1:1:n_buses
        aux_sum = 0;
        for c = 1:1:n_buses
            if c ~= b
                aux_ = abs(voltg(c)) * abs(YBUS(b,c)) * cos(angle(voltg(b)) - angle(voltg(c)) - angle(YBUS(b,c)));
                aux_sum = aux_sum + aux_;
            end
        end
        P_calc(b) = ( (abs(voltg(b))^2) * abs(YBUS(b,b)) * cos(angle(YBUS(b,b))) ) + (abs(voltg(b)) * aux_sum);
    end

    Q_calc = zeros(n_buses, 1);
    for d = 1:1:n_buses
        aux_sum = 0;
        for e = 1:1:n_buses
            if e ~= d
                aux_ = abs(voltg(e)) * abs(YBUS(d,e)) * sin(angle(voltg(d)) - angle(voltg(e)) - angle(YBUS(d,e)));
                aux_sum = aux_sum + aux_;
            end
        end
        Q_calc(d) = ( (-1) * (abs(voltg(d))^2) * abs(YBUS(d,d)) * sin(angle(YBUS(d,d))) ) + (abs(voltg(d)) * aux_sum);
    end

    % generated power in the buses
    S_gen = zeros(n_buses, 1);
    for f = 1:1:n_buses
        if strcmp(bus_table.bus_type{f}, "SLACK")
            S_gen(f) = complex(P_calc(f), Q_calc(f)) + complex(P_dem(f), Q_dem(f));
        elseif strcmp(bus_table.bus_type{f}, "PV")
            S_gen(f) = complex(bus_table.P_gen_pu(f), Q_calc(f)+Q_dem(f));
        else
            S_gen(f) = 0;
        end
    end
    
    result = table(bus_table.id, bus_table.bus_i, abs(voltg), ...
        angle(voltg)*180/pi, P_calc, Q_calc, real(S_gen), imag(S_gen), ...
        P_dem, Q_dem);
    result.Properties.VariableNames = ["id", "bus_i", "bus_voltage_pu", ...
        "bus_angle_degrees", "P_i_pu", "Q_i_pu", "P_gen_pu", "Q_gen_pu", ...
        "P_load_pu", "Q_load_pu"];
    
    % power balance of the entire system
    S_gen_t = sum(S_gen);
    S_dem_t = sum(complex(P_dem, Q_dem));
    S_loss_t = sum(S_losses);
    power_balanc = S_gen_t - (S_dem_t + S_loss_t);

    s_balance = table( real(S_gen_t), imag(S_gen_t), real(S_dem_t), imag(S_dem_t), ...
        real(S_loss_t), imag(S_loss_t), real(power_balanc), imag(power_balanc) );
    s_balance.Properties.VariableNames = ["P_gen_pu", "Q_gen_pu", "P_load_pu", ...
        "Q_load_pu", "P_loss_pu", "Q_loss_pu", "delta_P_pu", "delta_Q_pu"];

end
