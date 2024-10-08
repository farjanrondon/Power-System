
function [gen_data, load_data] = angle_stability(bus_table, volts_, rsult_)
    
    % table of the slack and pv buses
    gen_buses = bus_table;
    gen_buses(strcmp(gen_buses.bus_type, "PQ"),:) = [];
    % result table for slack and pv buses
    gen_rsult = rsult_(rsult_.bus_i(gen_buses.bus_i),:);
    % voltages of the buses with generators
    gen_volts = volts_(gen_buses.bus_i);
    
    % current given by each generator
    I_gen = conj((gen_rsult.P_gen_pu + 1j .* gen_rsult.Q_gen_pu) ./ gen_volts);
    % femi 
    E_gen = gen_volts + I_gen .* ( 1j .* gen_buses.X_prime_d_pu );

    % gen_data table
    gen_data = table(gen_buses.id, gen_buses.bus_i, gen_buses.H, ...
                     gen_buses.X_prime_d_pu, gen_buses.bus_type, abs(E_gen), ...
                     angle(E_gen)*180/pi, abs(I_gen), angle(I_gen)*180/pi);
    gen_data.Properties.VariableNames = ["id", "bus_i", "H", "X_prime_d_pu", "bus_type", "E_abs", "E_angle", "I_abs", "I_angle"];
    
    
    % table of buses with loads
    load_buses = rsult_(rsult_.P_load_pu ~= 0 & rsult_.Q_load_pu ~= 0,:);
    % voltages of the buses with loads
    load_volts = volts_(load_buses.bus_i);

    % expressing the load as admitances
    Y_loads = conj(load_buses.P_load_pu + 1j .* load_buses.Q_load_pu) ./ (abs(load_volts) .^ 2);

    % load_data table
    load_data = table(load_buses.id, load_buses.bus_i, Y_loads);
    load_data.Properties.VariableNames = ["id", "bus_i", "Y_loads"];
    
end