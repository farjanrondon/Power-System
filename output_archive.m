
function [output_file] = output_archive(input_file, output_name)
    
    % copy of the file
    output_file = output_name + ".xlsx";
    copyfile(input_file, output_file);
    
    % updating the nex output name in the original archive
    re_exp = "[a-z]+[|.*+?-_$]";
    str_ = regexp(output_name, re_exp, "match");
    str_len = length(str_{1});

    num_ = str2double(output_name(str_len+1:end));
    new_num = num_ + 1;

    file_output_name = convertCharsToStrings(strcat(output_name(1:str_len), num2str(new_num)));
    writetable(table(file_output_name), input_file, ... 
               "Sheet", "PARAMETERS", ...
               "Range", "B4:B4", ...
               "AutoFitWidth", false, ...
               "PreserveFormat", true, ...
               "WriteVariableNames", false ...
               );

end
