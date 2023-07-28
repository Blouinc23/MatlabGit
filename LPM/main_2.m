%Load the LPM data for the datetimes in date_row, then various
%visualizations are available to be uncommented out.
%HEIGHTS
%A & B: 3.66m
%C & D: 10.97m
%E & F: 110m
%G & H: 194m

good_days = load('LPM_Data\LPM_Good_Days.mat');%Array of datetimes we determined were
%worth looking at more closely
good_days = good_days.LPM_good_days;
date_row = table2array(good_days(:, 1));   %CONFIGURABLE, datetime array of which days to use

tic
disp("Loading data...")
loaded_data = load_day_lpm_data3(date_row);
disp("Getting summary...")
summary = get_LPM_summary3(loaded_data);
toc
disp("Done loading...")

%--------------------------------------------------------------------------
%Calculate some stats over all the days of data for use later

idx_mean_drop_count = zeros(size(summary));
idx_eligible_counts = zeros(size(summary));
idx_mean_rr = zeros(size(summary));
idx_mean_rr_bins = zeros([size(summary), 22]);
idx_super_terminal_frac = zeros([size(summary), 22]);
idx_sub_terminal_frac = zeros([size(summary), 22]);
all_instruments = 'A':'H';

% figure
for i = 1:size(summary, 1)
    for j = 1:size(summary,2)
%         subplot(size(summary, 1), size(summary, 2), (i-1)*size(summary, 2) + j)
%         hold on

        s = summary(i, j);
        
%         %Plot set 1: portion sub, super, non terminal drops
%         idx = summary(i, j).total_drops > 100;
%         plot(summary(i, j).sub_terminal_drops(idx) ./ summary(i, j).total_drops(idx))
%         plot(summary(i, j).super_terminal_drops(idx) ./ summary(i, j).total_drops(idx))
%         plot((summary(i, j).super_terminal_drops(idx)+summary(i, j).sub_terminal_drops(idx)) ./ summary(i, j).total_drops(idx))
%         ylim([0, 1])

%         %Plot set 2: portion sub terminal drops vs portion super terminal
%         %drops
%         idx = summary(i, j).total_drops > 100;
%         scatter(summary(i, j).sub_terminal_drops(idx) ./ summary(i, j).total_drops(idx) , summary(i, j).super_terminal_drops(idx) ./ summary(i, j).total_drops(idx));

%         idx = summary(i, j).total_drops > 30;
%         histogram(summary(i, j).total_drops(idx))
%         set(gca, 'YScale', 'log')
        

        idx = sum(s.rainrate, 2)>0.1;
        idx_eligible_counts(i, j) = sum(idx);%Num minutes of each day that fit condition in idx
        idx_mean_drop_count(i, j) = mean(s.total_drops(idx), 'omitnan');
        idx_mean_rr(i, j) = mean(sum(s.rainrate(idx, :), 2), 'omitnan');
        idx_mean_rr_bins(i, j, :) = mean(s.rainrate(idx, :), 1, 'omitnan');
        idx_super_terminal_frac(i, j, :) = sum(s.super_terminal_drops(idx, :), 1, 'omitnan') ./ squeeze(sum(s.drop_field(idx, :, :), [1, 2], 'omitnan'))';
        idx_sub_terminal_frac(i, j, :) = sum(s.sub_terminal_drops(idx, :), 1, 'omitnan') ./ squeeze(sum(s.drop_field(idx, :, :), [1, 2], 'omitnan'))';
    end
end

%--------------------------------------------------------------------------
%Plot rainrate over the day for each instrument, for each day

% figure
% for i = 1:size(summary, 1)
%     subplot(ceil(sqrt(size(summary, 1))), ceil(sqrt(size(summary, 1))), i)
%     hold on
%     for j = 1:size(summary, 2)
%         s = summary(i, j);
%         plot(s.date, s.rainrate)
%     end
% end

%--------------------------------------------------------------------------
%Plot the mean drop count at each height on each day

% plot(mean(cat(3, idx_mean_rr(:, 1:2:end), idx_mean_rr(:, 2:2:end)), 3, 'omitnan'));

%--------------------------------------------------------------------------
%Stats on mean values available for each instrument
% 
% t = idx_eligible_counts;
% t(t == 0) = nan(1);
% disp("Num Eligible Counts: ")
% disp(mean(t, 'omitnan'))
% t = idx_mean_drop_count;
% t(t == 0) = nan(1);
% disp("Minute Drop Counts: ")
% disp(mean(t, 'omitnan'))
% t = idx_mean_rr;
% t(t == 0) = nan(1);
% disp("Mean Rainrates: ")
% disp(mean(t, 'omitnan'))

%--------------------------------------------------------------------------
%Relative detection rates of instruments compared to the mean

% %How many drops each instrument measures on average compared to all other
% %instruments
% relative_drop_detection_rate = idx_mean_drop_count ./ mean(idx_mean_drop_count, 2, 'omitnan');
% disp(mean(relative_drop_detection_rate, 1, 'omitnan'));
%How much rainrate each instrument measures on average compared to all other
%instruments
relative_rr_detection_rate = idx_mean_rr ./ mean(idx_mean_rr, 2, 'omitnan');
disp(mean(relative_rr_detection_rate, 1, 'omitnan'));
%How much sub terminal drops each instrument measures on average compared to all other
%instruments
relative_sub_rate = idx_sub_terminal_frac ./ mean(idx_sub_terminal_frac, 2, 'omitnan');
disp(mean(relative_sub_rate, 1, 'omitnan'));
relative_super_rate = idx_super_terminal_frac ./ mean(idx_super_terminal_frac, 2, 'omitnan');
disp(mean(relative_super_rate, 1, 'omitnan'));

%--------------------------------------------------------------------------
%Histograms of correlation coefficients of instrument pair for each day

corrcoef_mat = zeros(size(summary, 1), size(summary, 2), size(summary, 2));
for d = 1:size(summary, 1)
    for i = 1:size(summary, 2)
        for j = 1:size(summary, 2)
            idx = sum(summary(d, i).rainrate, 2) > 0.1 | sum(summary(d, j).rainrate, 2) > 0.1;
            t = corrcoef(sum(summary(d, i).rainrate(idx, :), 2), sum(summary(d, j).rainrate(idx, :), 2));
            if size(t ,1) ~= 2
                corrcoef_mat(d, i, j) = NaN;
            else
                corrcoef_mat(d, i, j) = t(1, 2);
            end
        end
    end
end
%mean(corrcoef_mat, 'omitnan')
temp = permute(corrcoef_mat, [2, 3, 1]);

figure('Name', 'Correlation Coefficient of rainrate for instrument pairs')
for i = 1:size(summary, 2)
    for j = 1:size(summary, 2)
        subplot(8, 8, (i-1)*size(summary, 2)+j)
        histogram(corrcoef_mat(:, i, j), (-1:0.1:1))
        title(all_instruments(i) + " vs " + all_instruments(j))
    end
end

figure('Name', 'Fraction nonterminal')
for i = 22:-1:1
    subplot(5, 5, i)
    histogram(idx_sub_terminal_frac(:, :, i), (0:0.05:1))
    title("Fraction sub terminal bin " + i)
end

figure
for i = 1:4
    for j = 1:8
        subplot(4, 8, 8*(i-1)+j)
        histogram(idx_sub_terminal_frac(:, j, i+2), (0:0.05:1))
    end
end
%--------------------------------------------------------------------------














