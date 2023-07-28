function combined_data = get_MRR_day_summary(date, serial_number, verbose)
    arguments
        date datetime = datetime(1970, 1, 1);
        serial_number double = 50;
        verbose logical = true;%Whether to output messages to command
            %window to convey progress
    end
    %Select the folder containing the .mrr files to combine. Only top level
    %.mrr files will be combined (none in subfolders).
    if date == datetime(1970, 1, 1)
        path = string(uigetdir());%In case of no given date, prompt to select folder
        date = split(path, '\');
        date = datetime(date{length(date)}, 'InputFormat', 'yyyyMMdd');
    else
        y = year(date);
        m = pad(string(month(date)), 2, 'left', '0');
        d = pad(string(day(date)), 2, 'left', '0');
        path_to_data_folder = "MRR\Data\MRR" + serial_number;%Adjust if needed
        path = path_to_data_folder + "\" + y + m + "\" + y + m + d + "\";
    end
    timer = tic;
    directory = dir(path);
    files = {directory.name};
    files = files(endsWith(files, '.nc'));
    if isempty(files)
        disp("Error, data not found for " + datestr(date) + ". Skipping...")
        combined_data = NaN;
        return
    end
    
    if verbose
        disp(length(files) + " files found for " + datestr(date) + "..." + "(Time elapsed " + toc(timer) + " seconds)");
    end
    %Read in all the files into a multidimensional struct called all_data
    all_data = cell(size(files));
    for f = 1:length(files)
        source = files{f};
        if verbose
            disp("Loading data " + f + " of " + length(files) + "... (" + source + ")" + "(Time elapsed " + toc(timer) + " seconds)")
        end
        file = path + source;
        %Read file data into struct called read_data. This has all the data in the
        %file, but is unwieldy as is
        read_data = ncinfo(file);
        %Extract variable names from read_data, then create D and D_param
        var_names = cell(length(read_data.Variables), 1);
        d_vals = cell(length(read_data.Variables), 1);
        for i=1:length(var_names)
            var_names{i} = read_data.Variables(i).Name;
            d_vals{i} = ncread(file, var_names{i});
        end
        args=[var_names,d_vals]';
        %Data is the data struct containing all data from t
        all_data{f} = struct(args{:});
        %D_param contains info about each variable and what the dimensions
        %correspond to
        %D_param = read_data.Variables;
    end
    all_data = [all_data{:}]';

    %Combine the data into a single struct. Shared variables like range are
    %taken from the first struct in all_data (should be same in all structs 
    %in all_data).
    if verbose
        disp("Combining data. (Time elapsed " + toc(timer) + " seconds)")
    end
    fields = fieldnames(all_data);
    fields = fields(18:end-1);%Only these fields need to be combined
    combined_data = all_data(1);
    for f = 1:length(fields)
        cat_dim = ndims(combined_data.(fields{f}))-sum(size(combined_data.(fields{f})) == 1);
        combined_data.(fields{f}) =  cat(cat_dim, all_data.(fields{f}));
    end

    %Reformat some of the data to be more readable/usable
    if verbose
        disp("Adjusting data formats. (Time elapsed " + toc(timer) + " seconds)")
    end
    start_time = all_data(1).time_coverage_start';
    start_time = datetime(start_time(1:19), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    stop_time = all_data(length(all_data)).time_coverage_end';
    stop_time = datetime(stop_time(1:19), 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss');
    combined_data.time_coverage_start = start_time;
    combined_data.time_coverage_end = stop_time;
    time_ref = extractBefore(string(all_data(1).time_reference'), 21);
    combined_data.time_reference = datetime(time_ref, 'InputFormat', 'yyyy-MM-dd''T''HH:mm:ss''Z');
    combined_data.time = combined_data.time_reference + seconds(combined_data.time);
    combined_data.instrument_type = string(combined_data.instrument_type');
    
    if verbose
        disp("Done. (Time elapsed " + toc(timer) + " seconds)")
    end
end
