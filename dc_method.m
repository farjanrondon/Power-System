
function [dc_result] = dc_method(bus_table, lines_table, trx_table, P_esp)
    
    % lines and trx's data
    if istable(trx_table)
        data_table = table( ...
            [lines_table.bus_i; trx_table.bus_i], ...
            [lines_table.bus_j; trx_table.bus_j], ...
            [imag(1./(lines_table.Y_lines)); trx_table.X_cc_pu]);
    else
        data_table = table( ...
            lines_table.bus_i, ...
            lines_table.bus_j, ...
            imag(1./(lines_table.Y_lines)) ...
            );
    end
    % rename columns
    data_table.Properties.VariableNames = ["bus_i", "bus_j", "X_pu"];
    
    bus_num = length(bus_table.bus_i);
    X_matrix = zeros(bus_num, bus_num);

    for a = 1:1:bus_num
        for b = 1:1:bus_num
            
            if a == b
                to_addsup = [
                    data_table(data_table.bus_i==a,:);
                    data_table(data_table.bus_j==b,:)
                    ];
                inv_sum = sum( (1 ./ to_addsup.X_pu) );
            else
                to_addsup = [
                   data_table(data_table.bus_i==a & data_table.bus_j==b,:);
                   data_table(data_table.bus_i==b & data_table.bus_j==a,:)
                   ];
                inv_sum = -1 * sum( (1 ./ to_addsup.X_pu) );
            end

            X_matrix(a, b) = X_matrix(a, b) + inv_sum;
            
        end
    end

    % bus numbers of the slacks type
    slack_table = bus_table(strcmp(bus_table.bus_type,"SLACK"),:);
    slack_bus = slack_table.bus_i;
    % process of deleting the rows and columns of slack bus type
    to_delete = flip(sort(slack_bus));
    P_values = P_esp;
    for c = to_delete
        X_matrix(c,:) = [];
        X_matrix(:,c) = [];
        P_values(c) = [];
    end
    
    % angle calculus
    angles_dc = inv(X_matrix) * P_values;

    % preparing the output table, angles in degrees
    aux_angles = zeros(bus_num, 1);
    idx = 1;
    for d = 1:1:bus_num
        if ismember(d, slack_bus)
            aux_angles(d) = slack_table.bus_angle_radians(1);
        else
            aux_angles(d) = angles_dc(idx);
            idx = idx + 1;
        end
    end
    
    angles_degrees = aux_angles * 180 / pi;
    dc_result = table(bus_table.bus_i, angles_degrees);
    dc_result.Properties.VariableNames = ["bus_i", "bus_angle"];
    
end