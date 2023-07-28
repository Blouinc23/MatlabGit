function data = load_day_lpm_data2(date_choice)
    arguments
        date_choice (:, 1) datetime
    end
    
    instruments = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];    
    
    data = cell(length(date_choice), length(instruments)+1);
    data(:, 2:end) = {nan(1439, 440)};
    
    day_dur = minutes(0:1438);
    
    for i = 1:length(date_choice)
        d = date_choice(i);
        disp("Loading " + datestr(d) + "..." + " (" + i + " of " + length(date_choice) + ")")
        y  = year(d);
        data{i, 1} = d + day_dur;
        rel_path = "LPM_Data\" + y + "\";
        full_dir = dir(rel_path);
        pat = ["_" + pad(num2str(day(d, 'dayofyear')), 3, 'left', '0') + "_", "_" + day(d, 'dayofyear') + "_"];
        match_files = full_dir(contains({full_dir.name}, pat));
        for j = 1:length(match_files)
            f = match_files(j).name;
            disp("Loading " + f + "...")
            loaded_data = load(rel_path + f);
            splits = split(f, "_");
            time = splits{3};
            time = minutes(hours(str2double(time(1:2))) + minutes(str2double(time(3:4))));
            inst_idx = 1+strfind(instruments, extractBefore(f, 2));
            overwrite = data{i, inst_idx};
            overwrite(time+1:time+size(loaded_data, 1), :) = loaded_data;
            %Restrict data to 1 day's worth. Not clean but it works.
            if size(overwrite, 1) > 1439
                overwrite = overwrite(1:1439, :);
            end
            data(i, inst_idx) = {overwrite};
        end
    end
    for i = 1:size(data, 1)
        for j = 2:size(data, 2)
            data{i, j}(:, 1:40) = 0;%Remove first 2 speed classes
            data{i, j}(:, 421:end) = 0;%Remove last speed class
            data{i, j}(:, 1:20:end) = 0;%Remove first diameter class
            data{i, j}(:, 2:20:end) = 0;%Remove second diameter class
            data{i, j}(:, 20:20:end) = 0;%Remove last diameter class
        end
    end
    data = cell2table(data, 'VariableNames', {'Date', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'});
end