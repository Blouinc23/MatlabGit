%Returns the wind data from the given date, averaged over num_minutes
%intervals.
function wind_data = get_wind_summary(date, num_minutes)
    times = date+minutes(0:num_minutes:1440-num_minutes);
    %Find files
    wind_files = dir(['WindData/', num2str(year(date))]);
%     wind_filenames = strings(length(wind_files), 1);
%     for i = 1:length(wind_files)
%         wind_filenames(i) = wind_files(i).name;
%     end
%     wind_filenames = wind_filenames(contains(wind_filenames, num2str(yyyymmdd(date))));
    idx = contains({wind_files.name}, num2str(yyyymmdd(date)));
    matching_files = {wind_files(idx, :).name}';

    inst_data = cell(length(matching_files), 4);
    %Read data from files
    for i = 1:length(matching_files)
%         d(i).file_data = readmatrix(fullfile(wind_files(1).folder, matching_files{i}));
        disp(matching_files{i})
        file_data = readmatrix(fullfile(wind_files(1).folder, matching_files{i}));
        %Only use the relevant columns
        disp("NOTE: NEED TO CHECK IF THESE ARE THE CORRECT COLUMNS")
        inst_data{i, 1} = file_data(:, [15:21, 81:85]);%AB
        inst_data{i, 2} = file_data(:, [22:28, 86:90]);%CD
        inst_data{i, 3} = file_data(:, [50:56, 106:110]);%EF
        inst_data{i, 4} = file_data(:, [64:70, 116:120]);%GH
    end
        
%     %Force data into 30 minute 50hZ chunks and average for each minute
%     minute_data = cell(size(inst_data));
%     for i = 1:size(inst_data, 1)
%         for j = 1:size(inst_data, 2)
%             nan_arr = NaN(90000, 12);
%             nan_arr(1:min(90000, size(inst_data{i, j}, 1)), :) = inst_data{i, j}(1:min(90000, size(inst_data{i, j}, 1)), :);
% %             minute_data{i, j} = squeeze(mean(reshape(nan_arr, 90000/minutes_in_data, minutes_in_data, 12), 1, 'omitnan'));
%             minute_data{i, j} = nan_arr;
%         end
%     end
    
    %Concatnate the data into a single array per instrument pair
    full_day_data = cell(1, 4);
    for i = 1:4
        full_day_data{i} = NaN(4320000, 12);
        for j = 1:size(inst_data, 1)
            file_name_split = split(matching_files{j}, '_');
            time_split = file_name_split{6}(2:end);
            period = 1 + (hours(str2double(time_split(1:2)))+minutes(str2double(time_split(3:4))))/minutes(30);
            nan_arr = NaN(90000, 12);
            nan_arr(1:min(90000, size(inst_data{j, i}, 1)), :) = inst_data{j, i}(1:min(90000, size(inst_data{j, i}, 1)), :);
            full_day_data{i}(90000*(period-1)+1:90000*period, :) = nan_arr;
        end
    end
    
    
   
    %Properly find mean for wind direction. Currently not working
    %find_wind_mean = @(t) atan2d(mean(t(:, 1:2:end).*sind(t(:, 2:2:end))), mean(t(:, 1:2:end).*cosd(t(:, 2:2:end))));
    %minute_winds(:, [85, 90, 110, 120]) = blockproc(full_day_data(:, [84, 85, 89, 90, 109, 110, 119, 120]), [50*60*num_minutes, 2], @(t) find_wind_mean(t.data));
    
    averaged_winds = cell(1, 4);
    for i = 1:4
        t = reshape(full_day_data{i}, 50*60*num_minutes, [], 12);
        t_x = mean(t(:, :, 11) .* cosd(t(:, :, 12)), 1, 'omitnan');
        t_y = mean(t(:, :, 11) .* sind(t(:, :, 12)), 1, 'omitnan');
        t_mag = sqrt(t_x.^2 + t_y.^2);
        t_deg = atan2d(t_y, t_x);
        %averaged_winds{1, i} = table(t_deg', t_mag', 'VariableNames', {'Magnitude', 'Degrees'});
        averaged_winds{i} = [t_deg', t_mag'];
    end
    %Extract correct columns for data and combine them into a table
%     wind_AB = minute_winds(:, [15:21, 81:85]);
%     wind_CD = minute_winds(:, [22:28, 86:90]);
%     wind_EF = minute_winds(:, [50:56, 106:110]);
%     wind_GH = minute_winds(:, [64:70, 116:120]);
    

    table_names = {'interval_start_time', 'AB_degrees', 'AB_magnitude', 'CD_degrees', 'CD_magnitude', 'EF_degrees', 'EF_magnitude', 'GH_degrees', 'GH_magnitude'};
    table_cells = cell(length(times), 9);
    for i = 1:length(times)
        table_cells{i, 1} = times(i);
    end
    table_cells(:, 2:3) = num2cell(averaged_winds{1});
    table_cells(:, 4:5) = num2cell(averaged_winds{2});
    table_cells(:, 6:7) = num2cell(averaged_winds{3});
    table_cells(:, 8:9) = num2cell(averaged_winds{4});
    wind_data = cell2table(table_cells, 'VariableNames', table_names);

end