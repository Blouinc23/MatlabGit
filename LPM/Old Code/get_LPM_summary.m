%Returns a table of many useful data from a filename, minute offset, and
%aggregation interval
function summary = get_LPM_summary(file, interval)
    %Import table into file and choose times    
    try
        T = readmatrix(fullfile("lpm_csv" ,file)); 
    catch
        var_names = {'times', 'total_drops', 'rain_rates', 'mean_diameters', 'mean_weighted_diameters', 'z_stars', 'sub_terminal_drops', 'super_terminal_drops'};
        var_types = {'datetime', 'double', 'double', 'double', 'double', 'double', 'double', 'double'};
        summary = table('Size', [0, 8], 'VariableNames', var_names, 'VariableTypes', var_types);
        return
    end
    T = reshape(T, size(T, 1), 20, 22); %Row: minute, col: speed, deep: diameter
    T(size(T, 1)+1, :, :) = zeros(1, 20, 22); % add missing minute

    %Extract variables from filename
    %instrument = extractBefore(file, 2);
    
    %Find minutes to next hour
    year = str2double(extractBetween(file, 14, 17));
    day = str2double(extractBetween(file, 3, 5));
    hour = str2double(extractBetween(file, 7, 8));
    minute = str2double(extractBetween(file, 9, 10));
    start_time = datetime(year, 1, day, hour, minute, 0);

    %Datetime of first element after offset
    %find total number of full intervals in data
    num_elements = double(idivide(int32(size(T,1)), int32(interval), 'floor'));

    %Diameter and volume buckets
    diameters_width = [.125, .125, .125, .25, .25, .25, .25, .25, .25, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5];
    min_diameters = [.125, .25, .375, .5, .75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8];
    max_diameters = [min_diameters(2:end), 8];
    min_volumes = pi/6*min_diameters.^3;
    mid_speeds = [0.1, 0.3, 0.5, 0.7, 0.9, 1.2, 1.6, 2, 2.4, 2.8, 3.2, 3.8, 4.6, 5.4, 6.2, 7, 7.8, 8.6, 9.5, 10.5];
    speed_bounds = [0, .2, .4, .6, .8, 1, 1.4, 1.8, 2.2, 2.6, 3, 3.4, 4.2, 5, 5.8, 6.6, 7.4, 8.2, 9, 10, 20];
    terminal_speeds = termpoly([min_diameters, 8]);
    sub_terminal_speeds = terminal_speeds(1:22) .* 0.7;
    super_terminal_speeds = terminal_speeds(2:end) .* 1.3;
    
    %If max speed bound of bucket is greater than sub_terminal_speeds of
    %bucket, add the count
    %Gross number of super/sub, number per diameter,
    
    %LPM area in mm
    width = 20;
    length = 228;
    %area that LPM can scan for each diameter class
    effective_areas = (width - max_diameters).*length; 

    %All datetimes with full intervals of data
    times = (start_time + minutes((0:num_elements-1)*interval))';    
    %Calculate depths for each interval in times
    rain_rates = zeros(num_elements, 1);   
    total_drops = zeros(num_elements, 1);
    mean_diameters = zeros(num_elements, 1);
    mean_volumes = zeros(num_elements, 1);
    mean_weighted_diameters = zeros(num_elements, 1);
    z_stars = zeros(num_elements, 1);
    drop_size_distribution = zeros(num_elements, 22);
    diam_drops = zeros(num_elements, 22);
    sub_terminal_drops = zeros(num_elements, 22);
    super_terminal_drops = zeros(num_elements, 22);
    speed_variance = zeros(num_elements, 22);
    raw_interval_drops = zeros(num_elements, 20, 22);

    for h = 1:num_elements
        %Drops summed for the interval, still in speed/size classes
        all_interval_drops = squeeze(sum(T(interval*(h-1)+1 : interval*h, :, :), 1));
        raw_interval_drops(h, :, :) = all_interval_drops;
        %Drops summed for each speed class, still in size classes
        sizes_interval_drops = sum(all_interval_drops)';
        %total_interval_drops = squeeze(sum(sum(T(interval*(h-1)+1 : interval*h, :, :), 1), 2));
        diam_drops(h, :) = sizes_interval_drops';
        rain_rates(h) = sum(sizes_interval_drops .*  (min_volumes ./ effective_areas)' / (interval/60));
        total_drops(h) = sum(sizes_interval_drops);
        %mean speed for each diameter class
        mean_speeds = sum(squeeze(sum(T(interval*(h-1)+1 : interval*h, :, :), 1)) .* (ones(22, 1) * mid_speeds)', 1) ./ sizes_interval_drops';        
        if(total_drops(h) ~= 0)
            mean_diameters(h) = sum(sizes_interval_drops .* min_diameters') / total_drops(h);
            mean_volumes(h) = squeeze(sum(sizes_interval_drops .* min_volumes') ./ total_drops(h));
            mean_weighted_diameters(h) = (6*mean_volumes(h)/pi)^(1/3);%WRONG!
        else
            mean_diameters(h) = 0;
            mean_volumes(h) = 0;
            mean_weighted_diameters(h) = 0;
        end
        z_stars(h) = sum(sizes_interval_drops .* (min_diameters.^6)');
        %find drop size distribution and sub/super terminal drops
        %j is diameter class
        for j = 1:size(all_interval_drops, 2)
            area = effective_areas(j);
            j_probability = 0;
            d = diameters_width(j);
            %s is velocity class
            for s = 1:size(all_interval_drops, 1)
                c = all_interval_drops(s, j);
                v = mid_speeds(s);
                j_probability = j_probability + c/(area*interval*v*d);
                if speed_bounds(s+1) < sub_terminal_speeds(j) 
                    sub_terminal_drops(h, j) = sub_terminal_drops(h, j) + all_interval_drops(s, j);
                else
                    if speed_bounds(s) > super_terminal_speeds(j)
                        super_terminal_drops(h, j) = super_terminal_drops(h, j) + all_interval_drops(s, j);
                    end
                end
                speed_variance(h, j) = speed_variance(h, j) + ((mid_speeds(s)-mean_speeds(j))^2)*all_interval_drops(s, j);
            end
            drop_size_distribution(h, j) = j_probability;
        end
        speed_variance(h, :) = speed_variance(h, :) ./ sizes_interval_drops';
    end
    %sub_terminal_drops = sum(sub_terminal_drops, 2);
    %super_terminal_drops = sum(super_terminal_drops, 2);
    
    %Create table to be returned
    summary = table(times, total_drops, rain_rates, mean_diameters, mean_weighted_diameters, z_stars, diam_drops, sub_terminal_drops, super_terminal_drops, raw_interval_drops);
end