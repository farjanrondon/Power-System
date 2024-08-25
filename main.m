
% main archive
%

clc;
clear;

input_file = "sys_val.xlsx";
% function to read input data from the input_file
[parameters_c1, parameters_c2, parameters_c3, bus_table, lines_table, trx_table, shunt_table] = read_data(input_file);

% function to determinate the ybus matrix
[A_matrix, Y_primitive, YBUS] = ybus_matrix(bus_table, lines_table, trx_table, shunt_table);
