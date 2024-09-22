
function plots(velocity_, angle_, output_file)
    
    n_plots = length(velocity_(1, 2:end));
    
    % velocity subplot
    figure(1);
    legend1_label = cell(1, n_plots);
    for a = 1:1:n_plots
        plot(velocity_(:,1), velocity_(:,a+1));
        legend1_label{a} = "\omega_{" + num2str(a+1) + "}";
        hold on;
    end
    hold off;
    title("angular velocity");
    legend(legend1_label);
    xlabel("time in seconds");
    ylabel("velocity in radians per second");
    name1_ = output_file + "_velocity_plot.pdf";
    print(name1_, "-dpdf");

    % angle subplot
    figure(2);
    legend2_label = cell(1, n_plots);
    for b = 1:1:n_plots
        plot(angle_(:,1), angle_(:,b+1) .* 180 ./ pi);
        legend2_label{b} = "\phi_{" + num2str(b+1) + "}";
        hold on;
    end
    hold off;
    title("phase angle");
    legend(legend2_label);
    xlabel("time in seconds");
    ylabel("angle in degrees");
    name2_ = output_file + "_angle_plot.pdf";
    print(name2_, "-dpdf");
    
end