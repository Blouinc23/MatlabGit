%Returns the lpm data from the given day of year and year
function lpm_data = get_day_lpm(doy, year)
    instruments = 'ABCDEFGH';
    
    %Find files
    lpm_files = dir("LPM_Data/" + year);
    lpm_filenames = strings(length(lpm_files)-2, 1);
    for i = 3:length(lpm_files)
        lpm_filenames(i-2) = lpm_files(i).name;
    end
    
    %For each instrument, get the summary for its LPM files that day
    for i = 1:8
        inst_f = lpm_filenames(contains(lpm_filenames, instruments(i) + "_" + doy));
        inst_f = inst_f(contains(inst_f, year + ".csv"));
        if size(inst_f, 1) > 0
            lpm_data(i).summary = get_LPM_summary(inst_f(1, :), 1);
            for j = 2:size(inst_f, 1)
                lpm_data(i).summary = [lpm_data(i).summary; get_LPM_summary(temp.inst_f(j, :), 1, 0)];
            end
        else
            lpm_data(i).summary = get_LPM_summary(nan, nan);
        end
    end
    
end