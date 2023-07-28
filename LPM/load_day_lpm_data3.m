%Returns a table with the data from each instrument for the input array of
%datetimes. date_choice can be an array of datetimes or a single datetime.
function data = load_day_lpm_data3(date_choice)
    arguments
        date_choice (:, 1) datetime
    end
    
    instruments = ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'];    
    
    %The empty cell array we will put the data and datetimes in.
    data = cell(length(date_choice), length(instruments)+1);
    %Put empty arrays in each instrument column that we will overwrite as
    %we add read data.
    data(:, 2:end) = {nan(1439, 440)};
    
    day_dur = minutes(0:1438);
    
    %Process each day given
    for i = 1:length(date_choice)
        d = date_choice(i);
        disp("Loading " + datestr(d) + "..." + " (" + i + " of " + length(date_choice) + ")")
        y  = year(d);
        %Make the date column the array of datetimes for the whole day.
        data{i, 1} = d + day_dur;
        %Find files for that day (one for each instrument hopefully)
        working_dir=pwd;
        full_dir=[working_dir '\LPM'];
        rel_path = full_dir+"\LPM_Data\" + y + "\";
        full_dir = dir(rel_path);
        pat = ["_" + pad(num2str(day(d, 'dayofyear')), 3, 'left', '0') + "_", "_" + day(d, 'dayofyear') + "_"];
        matching_files = full_dir(contains({full_dir.name}, pat));
        %Process each file for that day
        for j = 1:length(matching_files)
            f = matching_files(j).name;
            disp("Loading " + f + "...")
            %Load the csv into MatLab
            loaded_data = load(rel_path + f);
            %Extract from the file name the time the data starts
            splits = split(f, "_");
            time = splits{3};
            time = minutes(hours(str2double(time(1:2))) + minutes(str2double(time(3:4))));
            inst_idx = 1+strfind(instruments, extractBefore(f, 2));
            %Copy the current data array for that day and insert the data
            %from this file into the corresponding time slot.
            overwrite = data{i, inst_idx};
            overwrite(time+1:time+size(loaded_data, 1), :) = loaded_data;
            %Restrict data to 1 day's worth in case added data would push
            %the array to more than 1439 (one day) in length. Not clean but it works.
            if size(overwrite, 1) > 1439
                overwrite = overwrite(1:1439, :);
            end

            data(i, inst_idx) = {overwrite};
        end
    end
    %Reshape the data to three dimensions to be much more usable.
    for i = 1:size(data, 1)
        for j = 2:size(data, 2)
            data{i, j} = reshape(data{i, j}, [1439, 20, 22]);%Minutes Diameter Speed
            data{i, j}(:, :, [1:2, 22]) = 0;%Remove first 2 and last speed classes (don't trust them)
            data{i, j}(:, [1:2, 20], :) = 0;%Remove first 2 and last diameter class (don't trust them)
        end
    end
    %Put everything into a convenient table.
    data = cell2table(data, 'VariableNames', {'Date', 'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H'});
end