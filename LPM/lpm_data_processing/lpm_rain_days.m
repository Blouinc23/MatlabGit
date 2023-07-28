%Finds days with at least a certain number of drops in at least a certain
%number of instruments.
    %Select .csv files from the lpm_processing.m output. Files must all be
        %from the same year or it will stack drop counts from the same day of
        %year in each year.
    %count_minimum is the minimum number of drops to be considered a
        %good/rainy day.
    %min_instrument_count is the number of instruments that must meet the
        %count_minimum requirement to be considered a 'good' day.

[files, path] = uigetfile('*.csv', 'Multiselect', 'on');
if isfloat(files)
    error('No files selected')
end
if ischar(files)
    files={files};
end

%Configurable variables
count_minimum = 100000;%minimum number of drops in the day for an instrument to be good
min_instrument_count = 4;%Number of instruments that must meet the drop count minimum
%for the day to be considered interesting

splits = split(files, '_');
all_instruments = unique(splits(:, :, 1));
all_days = unique(splits(:, :, 2));
all_counts = zeros(length(all_instruments), length(all_days));

%Process each file
for f = 1:size(files, 2)
    disp("Processing file " + f + " of " + size(files, 2) + "...")
    
    file = files{f};
    
    %Read the file
    full_path = strcat(path, file);
    f_counts = load(full_path);
    [splits_f, ~] = split(file, ["_", "."]);
    [f_instrument, f_day, f_time, f_year, ~] = splits_f{:};
    f_inst = find(contains(all_instruments, f_instrument));
    f_days = strncmp(all_days, f_day, 10);
    %Put drop counts into all_counts
    all_counts(f_inst, f_days) = all_counts(f_inst, f_days) + sum(f_counts, 'all');
end

%Find days meeting conditions
enough_drop_inst_counts = sum(all_counts > count_minimum, 1);
valid_days = sort(str2double(all_days(enough_drop_inst_counts >= min_instrument_count)));

%Put results into a table
varTypes = cell(length(all_instruments)+1, 1);
varTypes(1) = {'datetime'};
varTypes(2:end) = {'double'};
varNames = cell(length(all_instruments)+1, 1);
varNames(1) = {'date'};
varNames(2:end) = all_instruments;
results = table('Size', [length(valid_days), length(varTypes)], 'VariableTypes', varTypes, 'VariableNames', varNames);
results.date(:) = datetime(str2double(f_year), 1, valid_days);
results(:, 2:end) = num2cell(all_counts(:, enough_drop_inst_counts >= min_instrument_count))';

