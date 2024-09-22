
function oscillation_eq(parameters_c3, gen_data, Pm, time_d, Yk_f, Yk_af, output_file)
    
    % time values
    h = 1e-3;
    t_1 = 0:h:time_d;
    t_2 = time_d+h:h:10;
    
    % start values
    ang_values = gen_data(~strcmp(gen_data.bus_type, "SLACK"),:).E_angle - gen_data(strcmp(gen_data.bus_type, "SLACK"),:).E_angle;
    ang_values = ang_values .* pi ./ 180;
    spd_values = zeros(length(gen_data(~strcmp(gen_data.bus_type, "SLACK"),:).bus_i), 1);
    
    if strcmp(parameters_c3{2}, "Y")
        
        [heun_speed, heun_angle] = heun_method(gen_data, Pm, Yk_f, Yk_af, t_1, t_2, h, time_d, ang_values, spd_values);
        plots(heun_speed, heun_angle, output_file, "heun");
        % plots is the function to plot the velocity and the angle
        
    end
    
    if strcmp(parameters_c3{3}, "Y")

        [rk4_speed, rk4_angle] = rk4_method(gen_data, Pm, Yk_f, Yk_af, t_1, t_2, h, time_d, ang_values, spd_values);
        plots(rk4_speed, rk4_angle, output_file, "rk4");

    end
    
end
