%For each instrument and day, calculates LPM values such as rainrate, sub
%terminal drops, etc. Should feed in data from load_day_lpm_data3.m
function summary = get_LPM_summary3(loaded_data)
    arguments
        loaded_data (:, 9) table
    end
    
    %Diameter and volume buckets
    diameters_bin_width = [.125, .125, .125, .25, .25, .25, .25, .25, .25, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5];%mm
    min_diameters = [.125, .25, .375, .5, .75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8];
    max_diameters = [min_diameters(2:end), 8];
    min_volumes = pi/6*min_diameters.^3;
    speed_bounds = [0, .2, .4, .6, .8, 1, 1.4, 1.8, 2.2, 2.6, 3, 3.4, 4.2, 5, 5.8, 6.6, 7.4, 8.2, 9, 10, 20];%m/s
    mid_speeds = (speed_bounds(1:end-1) + speed_bounds(2:end))/2;
    terminal_speeds = termpoly([min_diameters, 8]);%Note: unstable for large diameters
    %terminal_speeds = 9.65-10.3*exp(-.6*[min_diameters, 8]);%Uses the MRR
    %formula for drop speed (maybe wrong)
    sub_terminal_speeds = terminal_speeds(1:end-1) .* 0.7;
    super_terminal_speeds = terminal_speeds(2:end) .* 1.3;
    %Row: diameter class, Col: speed class
    sub_terminal_mat = ones(length(sub_terminal_speeds), length(speed_bounds)-1) .* speed_bounds(2:end) < ones(length(sub_terminal_speeds), length(speed_bounds)-1) .* sub_terminal_speeds';
    super_terminal_mat = ones(length(super_terminal_speeds), length(speed_bounds)-1) .* speed_bounds(1:end-1) > ones(length(super_terminal_speeds), length(speed_bounds)-1) .* super_terminal_speeds';
    
    
    %LPM area in mm
    width = 20;
    len = 228;
    %area that LPM can scan for each diameter class
    effective_areas = (width - max_diameters).*(len - max_diameters); 
    
    %Create summary
    summary = struct();
    for d = 1:size(loaded_data, 1) %Day
        for n = 1:size(loaded_data, 2)-1 %Instrument
            t_data = cell2mat(loaded_data{d, n+1});
            %Put data into summary
            summary(d, n).date = loaded_data{d, 1};
            summary(d, n).instrument = loaded_data.Properties.VariableNames{n+1};
            summary(d, n).drop_field = t_data;
            summary(d, n).total_drops = sum(t_data, [2, 3], 'omitnan')';
            
            %HEIGHTS
            %A & B: 3.66m
            %C & D: 10.97m
            %E & F: 110m
            %G & H: 194m
            if summary(d, n).instrument == 'A' || 'B'
                summary(d, n).height = 3.66;
            elseif summary(d, n).instrument == 'C' || 'D'
                summary(d, n).height = 10.97;
            elseif summary(d, n).instrument == 'E' || 'F'
                summary(d, n).height = 110;
            elseif summary(d, n).instrument == 'G' || 'H'
                summary(d, n).height = 194;
            else
                summary(d, n).height = -1;
                disp("Unknown instrument/height...")
            end
            
%             %Handle case of no data
%             if isempty(t_data)
%                 summary(d, n).rainrate = [];
%                 summary(d, n).mean_diameter = [];
%                 summary(d, n).mean_volume = [];
%                 summary(d, n).vol_weighted_mean_diam = [];
%                 summary(d, n).z_star = [];
%                 summary(d, n).sub_terminal_drops = [];
%                 summary(d, n).super_terminal_drops = [];
%                 continue
%             end

            %20 speed classes, 22 diameter classes
            min_diam = reshape(min_diameters, [1, 1, 22]);
            min_vol = reshape(min_volumes, [1, 1, 22]);
            summary(d, n).rainrate = squeeze(sum(t_data .*  reshape(min_volumes ./ effective_areas * 60, [1, 1, 22]), 2, 'omitnan'));
            summary(d, n).mean_diameter = squeeze(sum(t_data .* min_diam ./ sum(t_data, 3, 'omitnan'), 3, 'omitnan'));
            summary(d, n).mean_diameter_all = squeeze(sum(t_data .* min_diam ./ sum(t_data, [2, 3], 'omitnan'), [2, 3], 'omitnan'))';
            summary(d, n).mean_volume = squeeze(sum(t_data .* min_vol ./ sum(t_data, 3, 'omitnan'), 3, 'omitnan'));
            summary(d, n).mean_volume_all = squeeze(sum(t_data .* min_vol ./ sum(t_data, [2, 3], 'omitnan'), [2, 3], 'omitnan'))';
            summary(d, n).vol_weighted_mean_diam = squeeze(sum(t_data .* min_diam.^4, 2, 'omitnan')./ sum(t_data .* min_diam.^3, 2, 'omitnan'));
            summary(d, n).vol_weighted_mean_diam(isnan(summary(d, n).vol_weighted_mean_diam)) = 0;
            summary(d, n).z_star = sum(t_data .*min_diam .^ 6, 2, 'omitnan');
            summary(d, n).sub_terminal_drops = squeeze(sum(t_data .* reshape(sub_terminal_mat', [1, 20, 22]), 2, 'omitnan'));
            summary(d, n).super_terminal_drops = squeeze(sum(t_data .* reshape(super_terminal_mat', [1, 20, 22]), 2, 'omitnan'));
        end
    end
end