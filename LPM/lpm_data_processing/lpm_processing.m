%Converts .txt LPM data files to CSVs with the drop matrices in them

%Note: to function requires that in the same directory be a folder called
%'processed_lpm_data' and a folder called 'unprocessed_lpm_data' which has
%a folder called 'done' in it. Raw .txt files should be placed
%in the 'unprocessed_lpm_data' folder. Processed files will be created in
%the 'processed_lpm_data' folder and the used raw data files will be moved
%to the 'done' folder. Multiple files can be selected to be processed at
%once.

%Select lpm files to be processed
[files, path] = uigetfile('*.txt', 'Multiselect', 'on');
if isfloat(files)
    error('No files selected')
end
if ischar(files)
    files={files};
end


%Process each file
for f = 1:size(files, 2)
    disp("Processing file " + f + " of " + size(files, 2) + "...")
    
    file = files{f};
    
    %Read the file
    full_path = strcat(path, file);
    FID = fopen(full_path);
    raw_data = textscan(FID, '%s');
    fclose(FID);
    
    %Note: the read .txt does not split the data into lines correctly,
    %which is why we join them all into one line then use split later
    data = string(raw_data{:});
    %data = strrep(data, '?????', 'ER');
    line_data = join(data, '');
    
    %Find size of output matrix. num_cols is at 520 from lpm standard
    num_cols = 520;
    num_rows = floor(sum(count(line_data, ';'))/num_cols);
    
    %Shave off data that was not completely filled out at end of the file,
    %probably due to a power outage.    
    block_count = sum(count(line_data, ';'));
    error_length = mod(block_count, num_cols);
    if error_length ~= 0 
        block_indices = strfind(line_data, ';');
        line_data = extractBefore(line_data, block_indices(length(block_indices)-error_length+1));
    end
    %Divide data into pieces by the delimiter ';' and shape it into the
    %right dimentsions
    split_data = split(line_data, ';');
    split_data = reshape(split_data(1:end-1), [num_cols, num_rows])';

    %Extract the relevant subsection of the data into a file in the
    %processed_lpm_data folder with the same file name as the input file
    final_data = str2double(split_data(:, 80:end-1));
    %writematrix(final_data, join([extractBefore(path, '\unprocessed_lpm_data'), '\processed_lpm_data\', extractBefore(file, '.txt'), '.csv']));
    
    %Edited to make this work withmatlab r2022a Chris Blouin 6-12-22
    writematrix(final_data,[path 'processed_lpm_data\' file '.csv']);

    %Move the input .txt file to the 'done' folder
    %movefile(full_path, join([path, '\done']))
    disp(file + ", total drops: " + sum(final_data, 'all'));
end
disp("Done!")