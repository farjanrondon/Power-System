
function [A_matrix, Y_primitive, YBUS] = ybus_matrix(bus_table, lines_table, trx_table, shunt_table)
    
    % nodal incidence matrix (A_matrix)
    n = length(bus_table.bus_i);
    % n is the number of buses in the system
    A_matrix = [];
    M_aux = [];
    % M_aux is an auxiliar matrix

    A_num_rows = sum(linspace(1, n, n));
    % "A_num_rows" and "n" define the shape of the matrix to determinate

    for a = linspace(1, A_num_rows, A_num_rows)
        while n-a > 0

            if a == 1
                M_aux(1:n-a, 1) = ones(n-a, a);
                M_aux = [M_aux, (-1)*eye(n-a)];
                A_matrix = [A_matrix, M_aux];
            else
                M_aux = [];
                M_aux(1:n-a, 1:a-1) = zeros(n-a, a-1);
                M_aux = [M_aux, ones(n-a, 1), (-1)*eye(n-a)];
                A_matrix = [A_matrix; M_aux];
            end

            break;

        end

        if n-a == 0
            A_matrix = [A_matrix; eye(n)];
        end
    end

    % primitive admitance matrix (Y_primitive)
    Y_primitive = zeros(sum(linspace(1, n, n)));

    % lines and trx (elements between buses) contribution to Y_primitive
    b = 1;
    idx = 1;
    while true

        for d = b+1:1:n
            lines_addsup = [
                lines_table(lines_table.bus_i==b & lines_table.bus_j==d,:);
                lines_table(lines_table.bus_i==d & lines_table.bus_j==b,:)
                ];

            if istable(trx_table)
                trx_addsup = [
                    trx_table(trx_table.bus_i==b & trx_table.bus_j==d,:);
                    trx_table(trx_table.bus_i==d & trx_table.bus_j==b,:)
                    ];
            end

            sum_var = sum(lines_addsup.Y_lines) + sum(trx_addsup.Y_ij);
            Y_primitive(idx, idx) = Y_primitive(idx, idx) + sum_var;
            idx = idx + 1;
        end

        b = b + 1;
        if b == n
            break;
        end
    end
    
    % shunt elements (between bus and ground) contribution to Y_primitive
    for e = 1:1:n
        % lines shunts adds up
        shunt_lines = [
            lines_table(lines_table.bus_i==e,:);
            lines_table(lines_table.bus_j==e,:)
            ];
        
        sum_lines = sum(shunt_lines.Y_shunt);
        
        % trx shunts adds up
        if istable(trx_table)
            shunt_trx_i = trx_table(trx_table.bus_i==e,:);
            shunt_trx_j = trx_table(trx_table.bus_j==e,:);

            sum_trx_i = sum(shunt_trx_i.Y_io);
            sum_trx_j = sum(shunt_trx_j.Y_jo);
            sum_trx = sum_trx_i + sum_trx_j;

        else
            sum_trx = 0;
        end
        
        % shunt elements adds up
        if istable(shunt_table)
            shunt_elemts = shunt_table(shunt_table.bus_i==e,:);
            sum_shunts = sum(shunt_elemts.Y_element);
        else
            sum_shunts = 0;
        end
        
        sum_var_ = sum_lines + sum_trx + sum_shunts;
        Y_primitive(idx, idx) = Y_primitive(idx, idx) + sum_var_;
        idx = idx + 1;
    end

    % YBUS calculus
    YBUS = transpose(A_matrix) * Y_primitive * A_matrix;
    
end