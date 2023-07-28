function summary = get_LPM_summary2(loaded_data)
    arguments
        loaded_data (:, 9) table
    end
    
    %Diameter and volume buckets
    diameters_bin_width = [.125, .125, .125, .25, .25, .25, .25, .25, .25, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5, .5];
    min_diameters = [.125, .25, .375, .5, .75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8];
    max_diameters = [min_diameters(2:end), 8];
    min_volumes = pi/6*min_diameters.^3;
    speed_bounds = [0, .2, .4, .6, .8, 1, 1.4, 1.8, 2.2, 2.6, 3, 3.4, 4.2, 5, 5.8, 6.6, 7.4, 8.2, 9, 10, 20];
    mid_speeds = (speed_bounds(1:end-1) + speed_bounds(2:end))/2;
    terminal_speeds = termpoly([min_diameters, 8]);%Note: unstable for large diameters
    sub_terminal_speeds = terminal_speeds(1:end-1) .* 0.7;
    super_terminal_speeds = terminal_speeds(2:end) .* 1.3;
    %Row: diameter class, Col: speed class
    sub_terminal_mat = ones(length(sub_terminal_speeds), length(mid_speeds)) .* speed_bounds(2:end) < ones(length(sub_terminal_speeds), length(mid_speeds)) .* sub_terminal_speeds';
    super_terminal_mat = ones(length(super_terminal_speeds), length(mid_speeds)) .* speed_bounds(1:end-1) > ones(length(super_terminal_speeds), length(mid_speeds)) .* super_terminal_speeds';
    
    
    %LPM area in mm
    width = 20;
    len = 228;
    %area that LPM can scan for each diameter class
    effective_areas = (width - max_diameters).*(len - max_diameters); 
    
    %Create summary
    summary = struct();
    %Make matrices with repeating values for easy matrix dot multiplication
    max_minutes = 1439;%Number of minutes in largest data packet
    class_list_len = 440;%Dimension of diameter/speed class element of data
    rep_vols = repmat(min_volumes, max_minutes, 20);
    rep_areas = repmat(effective_areas, max_minutes, 20);
    rep_min_diam = repmat(min_diameters, max_minutes, 20);
    rep_sub_terminal_mat = repmat(reshape(sub_terminal_mat', [1, class_list_len]), max_minutes, 1);
    rep_super_terminal_mat = repmat(reshape(super_terminal_mat', [1, class_list_len]), max_minutes, 1);
    for d = 1:size(loaded_data, 1) %Day
        for n = 1:size(loaded_data, 2)-1 %Instrument
            t_data = cell2mat(loaded_data{d, n+1});
            %Get subset for easy matrix multiplication
            [dim_1, dim_2] = size(t_data);
            
            t_vols = rep_vols(1:dim_1, 1:dim_2);
            t_areas = rep_areas(1:dim_1, 1:dim_2);
            t_min_diam = rep_min_diam(1:dim_1, 1:dim_2);
            t_sub_terminal_mat = rep_sub_terminal_mat(1:dim_1, 1:dim_2);
            t_super_terminal_mat = rep_super_terminal_mat(1:dim_1, 1:dim_2);
            summary(d, n).date = loaded_data{d, 1};
            summary(d, n).instrument = loaded_data.Properties.VariableNames{n+1};
            summary(d, n).drop_field = t_data;
            summary(d, n).total_drops = sum(t_data, 2)';
            
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
            
            %Handle case of no data
            if isempty(t_data)
                summary(d, n).rainrate = [];
                summary(d, n).mean_diameter = [];
                summary(d, n).mean_volume = [];
                summary(d, n).vol_weighted_mean_diam = [];
                summary(d, n).z_star = [];
                summary(d, n).sub_terminal_drops = [];
                summary(d, n).super_terminal_drops = [];
                continue
            end
            
            summary(d, n).rainrate = sum(t_data .*  t_vols ./ t_areas * 60, 2, 'omitnan')';
            summary(d, n).mean_diameter = sum(t_data .* t_min_diam ./ sum(t_data, 2), 2, 'omitnan')';
            summary(d, n).mean_volume = sum(t_data .* t_vols ./ sum(t_data, 2), 2, 'omitnan')';
            summary(d, n).vol_weighted_mean_diam = sum(t_data .* t_min_diam.^4, 2, 'omitnan')' ./ sum(t_data .* t_min_diam.^3, 2, 'omitnan')';
            summary(d, n).vol_weighted_mean_diam(isnan(summary(d, n).vol_weighted_mean_diam)) = 0;
            summary(d, n).z_star = sum(t_data .*t_min_diam .^ 6, 2, 'omitnan')';
            summary(d, n).sub_terminal_drops = sum(t_data .* t_sub_terminal_mat, 2, 'omitnan')';
            summary(d, n).super_terminal_drops = sum(t_data .* t_super_terminal_mat, 2, 'omitnan')';
        end
    end
end