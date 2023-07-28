function data = load_day_lpm_data(date_choice)
    arguments
        date_choice (:, 1) datetime
    end
    
    instruments = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];    
    
    data = cell(length(date_choice), length(instruments)+1);
    data(:, 1) = num2cell(date_choice);
    
    for i = 1:length(date_choice)
        d = date_choice(i);
        disp("Loading " + datestr(d) + "..." + " (" + i + " of " + length(date_choice) + ")")
        y  = year(d);
        rel_path = "LPM_Data\" + y + "\";
        full_dir = dir(rel_path);
        pat = ["_" + pad(num2str(day(d, 'dayofyear')), 3, 'left', '0') + "_", "_" + day(d, 'dayofyear') + "_"];
        match_files = full_dir(contains({full_dir.name}, pat));
        for j = 1:length(match_files)
            f = match_files(j).name;
            loaded_data = load(rel_path + f);
            %Restrict data to 1 day's worth. Not clean but it works.
            if size(loaded_data, 1) > 1439
                loaded_data = loaded_data(1:1439, :);
            end
            data(i, 1+strfind(instruments, extractBefore(f, 2))) = {loaded_data};
            disp(f)
        end
    end
    data = cell2table(data, 'VariableNames', {'Date', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'});
end