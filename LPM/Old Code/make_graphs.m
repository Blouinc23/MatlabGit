%Master function for creating graphs. Used by main.m
function data = make_graphs(data, num_minutes)
    %Find max rainrate
    rr_max = 0;
    for i = 1:4
            rr_max = max([rr_max, max([data(i).all.rain_rates_left; data(i).all.rain_rates_right])]);
    end
    %Graph wind and rain rate for user to get overview of day
    close all
    figure('Name', 'Rain Rate and Vertical Wind Speed vs Time', 'NumberTitle', 'off')
    for i = 1:4
        subplot(2, 2, i)
        yyaxis left
        scatter(data(i).all.times, data(i).all.rain_rates_left, 'o')
        scatter(data(i).all.times, data(i).all.rain_rates_right, 'o')
        ylim([0, rr_max])
        yyaxis right
        scatter(data(1).all.times, abs(data(1).all.wind(:, 12)), '.');
        grid on
        title("Rain Rate and Vertical Wind Speed vs Time, Height " + i)
    end
    set(gcf, 'Position', get(0, 'Screensize'));

    %Get times to graph from user
    user_selected_date_range = get_times(data, num_minutes);

    min_diameters = [.125, .25, .375, .5, .75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8];

    %List of potential graphs to plot. Adding new graphs requires adding name
    %to graph_options and case in switch/case block below.
    graph_options = {
        'Rain Rate vs Wind Speed', ...
        'Rain Rate vs Total Drops', ...
        'Rain Rate vs Portion Super Terminal Drops', ...
        'Rain Rate vs Portion Sub Terminal Drops', ...
        'Rain Rate vs Non Terminal Drops'...
        'Vertical Wind vs Portion Super Terminal Drops', ... 
        'Vertical Wind vs Portion Sub Terminal Drops', ... 
        'Drops-Rain Rate Xcorr', ...
        'Drops-Vertical Wind Xcorr', ... %Typically ~.5, not very centered at 0
        'Rain Rate-Vertical Wind Xcorr', ...
        'Mean Weighted Diameters- Vertical Wind Xcorr',...
        'Sub Terminal Count-Vertical Wind Xcorr',...
        'Super Terminal Count-Vertical Wind Xcorr'};
    %Request user select types of graphs to create graphs
    [chosen_graphs, ~] = listdlg('PromptString', {'Select type of graph'}, 'ListString', graph_options);
    %Graph each of the selected graph types in separate figures
    diam_class = -1;
    if ~isempty(intersect(chosen_graphs, [3, 4, 5, 6, 7]))
        [diam_class, ~] = listdlg('PromptString', {'Which diameter class',  'for sub/super terminal?'}, 'ListString', ['All  '; num2str(min_diameters')], 'SelectionMode', 'single');
        if diam_class == 1
            diam_class = 1:22;
        else
            diam_class = diam_class-1;
        end
    end
    for g = chosen_graphs
        to_graph = char(graph_options(g));
        figure('Name', to_graph, 'NumberTitle', 'off')
        for i = 1:1
            subplot(1, 1, i)
        %for i = 1:4
            %subplot(2, 2, i)
            non_nan = find(~isnan(data(i).all.wind(:, 10)) & ~isnan(data(i).all.total_drops_left) & ~isnan(data(i).all.total_drops_right));
            idx = intersect(non_nan, user_selected_date_range);
            wind_mean = mean(data(i).all.wind(idx, 10));
            title_addon = "";
            switch to_graph
                case 'Rain Rate vs Wind Speed'
                    x1 = data(i).all.rain_rates_left(idx);
                    x2 = data(i).all.rain_rates_right(idx);
                    y1 = data(i).all.wind(idx, 10);
                    y2 = y1;
                    x_label = 'Rain Rates (mm/h)';
                    y_label = 'Wind Speed (mph)';
                    graph_type = 'vs';
                case 'Rain Rate vs Total Drops'
                    x1 = data(i).all.rain_rates_left(idx);
                    x2 = data(i).all.rain_rates_right(idx);
                    y1 = data(i).all.total_drops_left(idx);
                    y2 = data(i).all.total_drops_right(idx);
                    x_label = 'Rain Rates (mm/h)';
                    y_label = 'Total Drops';
                    graph_type = 'vs';
                case 'Rain Rate vs Portion Super Terminal Drops' %Mostly in size bins 1 and 2
                    x1 = data(i).all.rain_rates_left(idx);
                    x2 = data(i).all.rain_rates_right(idx);
                    y1 = nanmean(data(i).all.super_terminal_drops_left(idx, diam_class) ./ data(i).all.diam_drops_left(idx, diam_class), 2);
                    y2 = nanmean(data(i).all.super_terminal_drops_right(idx, diam_class) ./ data(i).all.diam_drops_right(idx, diam_class), 2);
                    x_label = 'Rain Rates (mm/h)';
                    y_label = 'Portion Super Terminal Drops';
                    graph_type = 'vs';
                    title_addon = ", diameter class " + diam_class(1);
                case 'Rain Rate vs Portion Sub Terminal Drops'  %mostly in size bins 3 and 4
                    x1 = data(i).all.rain_rates_left(idx);
                    x2 = data(i).all.rain_rates_right(idx);
                    y1 = nanmean(data(i).all.sub_terminal_drops_left(idx, diam_class) ./ data(i).all.diam_drops_left(idx, diam_class), 2);
                    y2 = nanmean(data(i).all.sub_terminal_drops_right(idx, diam_class) ./ data(i).all.diam_drops_right(idx, diam_class), 2);
                    x_label = 'Rain Rates (mm/h)';
                    y_label = 'Portion Sub Terminal Drops';
                    graph_type = 'vs';
                    title_addon = ", diameter class " + diam_class(1);
                case 'Rain Rate vs Non Terminal Drops'
                    x1 = data(i).all.rain_rates_left(idx);
                    x2 = data(i).all.rain_rates_right(idx);
                    y1 = nanmean((data(i).all.sub_terminal_drops_left(idx, diam_class)+data(i).all.super_terminal_drops_left(idx, diam_class)) ./ data(i).all.diam_drops_left(idx, diam_class), 2);
                    y2 = nanmean((data(i).all.sub_terminal_drops_right(idx, diam_class)+data(i).all.super_terminal_drops_right(idx, diam_class)) ./ data(i).all.diam_drops_right(idx, diam_class), 2);
                    x_label = 'Rain Rates (mm/h)';
                    y_label = 'Portion Non Terminal Drops';
                    graph_type = 'vs';
                    title_addon = ", diameter class " + diam_class(1);
                case 'Vertical Wind vs Portion Super Terminal Drops'
                    x1 = data(i).all.wind(idx, 10);
                    x2 = x1;
                    y1 = nanmean(data(i).all.super_terminal_drops_left(idx, diam_class) ./ data(i).all.diam_drops_left(idx, diam_class), 2);
                    y2 = nanmean(data(i).all.super_terminal_drops_right(idx, diam_class) ./ data(i).all.diam_drops_right(idx, diam_class), 2);
                    x_label = 'Vertical Wind Speed (mph)';
                    y_label = 'Portion Super Terminal Drops';
                    graph_type = 'vs';
                    title_addon = ", diameter class " + diam_class(1);
                case 'Vertical Wind vs Portion Sub Terminal Drops'
                    x1 = data(i).all.wind(idx, 10);
                    x2 = x1;
                    y1 = nanmean(data(i).all.sub_terminal_drops_left(idx, diam_class) ./ data(i).all.diam_drops_left(idx, diam_class), 2);
                    y2 = nanmean(data(i).all.sub_terminal_drops_right(idx, diam_class) ./ data(i).all.diam_drops_right(idx, diam_class), 2);
                    x_label = 'Vertical Wind Speed (mph)';
                    y_label = 'Portion Sub Terminal Drops';
                    graph_type = 'vs';
                    title_addon = ", diameter class " + diam_class(1);
                otherwise %Unknown or xcorr graph
                    x_label = 'Lag';
                    y_label = 'Correlation';
                    graph_type = 'xcorr';
                    switch to_graph
                        case 'Drops-Rain Rate Xcorr'
                            rain_rate_mean = mean(data(i).all.rain_rates_left(idx)+data(i).all.rain_rates_right(idx));
                            drop_mean = mean(data(i).all.total_drops_left(idx)+data(i).all.total_drops_right(idx));
                            [y, x] = xcorr((data(i).all.total_drops_left(idx)+data(i).all.total_drops_right(idx)) ./ drop_mean, (data(i).all.rain_rates_left(idx)+data(i).all.rain_rates_right(idx)) ./ rain_rate_mean, 50, 'coeff');
                        case 'Drops-Vertical Wind Xcorr'
                            drop_mean = mean(data(i).all.total_drops_left(idx)+data(i).all.total_drops_right(idx));
                            [y, x] = xcorr(data(i).all.wind(idx, 10) ./ wind_mean, (data(i).all.total_drops_left(idx)+data(i).all.total_drops_right(idx)) ./ drop_mean, 50, 'coeff');
                        case 'Rain Rate-Vertical Wind Xcorr'
                            rain_rate_mean = mean(data(i).all.rain_rates_left(idx)+data(i).all.rain_rates_right(idx));
                            [y, x] = xcorr(data(i).all.wind(idx, 10) ./ wind_mean, (data(i).all.rain_rates_left(idx)+data(i).all.rain_rates_right(idx)) ./ rain_rate_mean, 50, 'coeff');
                        case 'Mean Weighted Diameters- Vertical Wind Xcorr'
                            weighted_diameter_mean = mean(data(i).all.mean_weighted_diameters_left(idx)+data(i).all.mean_weighted_diameters_right(idx));
                            [y, x] = xcorr(data(i).all.wind(idx, 10) ./ wind_mean, (data(i).all.mean_weighted_diameters_left(idx)+data(i).all.mean_weighted_diameters_right(idx)) ./ weighted_diameter_mean, 50, 'coeff');
                        case 'Sub Terminal Count-Vertical Wind Xcorr'
                            sub_terminal_mean = mean(data(i).all.sub_terminal_drops_left(idx)+data(i).all.sub_terminal_drops_right(idx));
                            [y, x] = xcorr(data(i).all.wind(idx, 10) ./ wind_mean, (data(i).all.sub_terminal_drops_left(idx)+data(i).all.sub_terminal_drops_right(idx)) ./ (2 * sub_terminal_mean), 50, 'coeff');
                        case 'Super Terminal Count-Vertical Wind Xcorr'
                            super_terminal_mean = mean(data(i).all.super_terminal_drops_left(idx)+data(i).all.super_terminal_drops_right(idx));
                            [y, x] = xcorr(data(i).all.wind(idx, 10) ./ wind_mean, (data(i).all.super_terminal_drops_left(idx)+data(i).all.super_terminal_drops_right(idx)) ./ (2 * super_terminal_mean), 50, 'coeff');
                        otherwise 
                            graph_type = 'none';
                    end
            end
            switch graph_type
                case 'xcorr'
                    plot(x, y)
                case 'vs'
                    hold on
                    scatter(x1, y1)
                    scatter (x2, y2)
                    hold off
                otherwise
                    disp('Error: unknown graph type')
            end
            title(char(graph_options(g)) + " at Height " + i + title_addon)
            xlabel(x_label)
            ylabel(y_label)
            set(gcf, 'Position', get(0, 'Screensize'));
        end
    end
end

function date_range = get_times(data, num_minutes)
    %Request user select datetimes for further inspection
    [index, ~] = listdlg('PromptString', {'Select continuous block of', 'datetimes for rain event'}, 'ListString', data(1).all.times(1:floor(10 / num_minutes):end));
    %Default to first time if user selected 'cancel'
    if isempty(index)
        index = 1;
    end
    %Default to end of data if only one time is selected
    if length(index) == 1
        index(2) = length(data(1).all.times(1:floor(10 / num_minutes):end));
    end
    date_range = index(1)*floor(10 / num_minutes) - 9 : index(end)*floor(10 / num_minutes) - 9;

end
