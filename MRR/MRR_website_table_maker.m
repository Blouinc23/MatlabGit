%Generates summary HTML table code for the MRR data stored in the rootdir
inst_sn = "50";%Serial number of instrument to make table for
rootdir = "Data/MRR50";%Folder to start in. Should have format:
    %root/yyyyMM/yyyyMMdd/yyyyMMdd_hhmmss.nc

all_days = dir(fullfile(rootdir, '*\*'));
all_days = all_days(~ismember({all_days.name},{'.','..'}));

results = struct;
i=0;
%For each day
for d = 1:length(all_days)
    %Find files with that day
    filelist = dir(fullfile(all_days(d).folder + "\" + all_days(d).name, '\*.nc'));
    name = all_days(d).name;
    d_date = datetime(name(1:8), 'InputFormat', 'yyyyMMdd');
    %Put data for that day in results
    results(d).data_code = "SN0" + inst_sn + "_" + string(name(1:8));    
    results(d).year = year(d_date);
    results(d).day_of_year = day(d_date, 'dayofyear');
    results(d).date = d_date;
    try
        %If you can, read that file and fill in its metadata
        file = filelist(1).folder + "\" + filelist(1).name;
        read_data = ncinfo(file);
        results(d).range_gates = read_data.Dimensions(2).Length;
        results(d).spectral_lines = read_data.Dimensions(6).Length;
        results(d).range_res = 10;
        results(d).avg_time = 10;
        
    catch
        %If you can't, say so
        disp("Could not read " + d)
        i = i+1;
        
    end
    
end

%Format into a HTML table
out = strings(1);
for r = 1:length(results)
    out = out + "<tr>";
    out = add_el(out, results(r).data_code);
    out = add_el(out, results(r).year);
    out = add_el(out, results(r).day_of_year);
    out = add_el(out, datestr(results(r).date));
    out = add_el(out, results(r).range_gates);
    out = add_el(out, results(r).spectral_lines);
    out = add_el(out, results(r).range_res);
    out = add_el(out, results(r).avg_time);
    out = out + "</tr>" + newline;
end

%Function to add element to HTML table
function outstring = add_el(instring, newel)
    if isempty(newel)
        newel = "ERROR";
    end
    outstring = instring + "<td>" + newel + "</td>";
end