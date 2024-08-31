
function [P_esp, P_dem, Q_esp, Q_dem, S_esp] = load_model(bus_table)
    
    % Voltage values
    volt_val = bus_table.bus_voltage_pu;
    % P values
    P_gen = bus_table.P_gen_pu;
    P_load = bus_table.P_load_pu;
    % Q values
    Q_gen = bus_table.Q_gen_pu;
    Q_load = bus_table.Q_load_pu;
    % ZIP values
    Z_ = bus_table.Z_percent;
    I_ = bus_table.I_percent; 
    P_ = bus_table.P_percent;

    % power demanded
    P_dem = P_load .* ( (Z_ .* (volt_val .^ 2)) + (I_ .* volt_val) + P_ );
    Q_dem = Q_load .* ( (Z_ .* (volt_val .^ 2)) + (I_ .* volt_val) + P_ );

    % specific power
    P_esp = P_gen - P_dem;
    Q_esp = Q_gen - Q_dem;
    S_esp = P_esp + (1j .* Q_esp);
    
end