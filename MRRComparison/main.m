%Finds the DSD from both MRR and 2DVD data and compares between them.

%Paths with functions used
addpath(pwd+"\MRR");
addpath(pwd+"\2DVD");
addpath(pwd+"\DSD");

%Configurable Parameters: specify characteristics of period to analyze
periods_of_interest = load('periods_of_interest.mat');
periods_of_interest = periods_of_interest.periods;
p = 5;
date = periods_of_interest.Date(p);
start_time = periods_of_interest.StartTime(p);
duration = periods_of_interest.Duration(p);

%Comments on rows of periods_of_interest
%1: (LOG) Only OK matching, but lots of rain. Lots of rain at the high MRR
%heights skew the RR plot and make the log better to use.
%2: (LOG) Extreme rainrates (max around 900), but thats super high up so
%probably not reliable. That said, the general shape of both match really
%well, although MRR is overall higher RR throughout.
%3: (LOG) Not much rain, and MRR has most rain at the highest area while
%2DVD has most rain at lower area.
%4: (LINEAR) Very low rainrates (0.45mm/hr max)
%5: (LINEAR) Little rainrate, but the there is higher rainrate at the high
    %heights on both 2DVD and MRR RR plots while also having very little at
    %the lower heights, which is encouraging.
%6: (LOG) Both have similarly high rainrates, but the time they see them is
%off. Very high rainrates (up to 350mm/h)
%7: (LINEAR) 2DVD is much higher than MRR, and MRR is only significant RR
%at lower heights
%8: (LOG) match at lower heights, but MRR is almost directly veritcal in
%how the RR traces up through the vertical axis while 2DVD maintains the
%distinct slight slant.

%Use to plot a histogram of drop density through the day to find good times
%for analysis
plot_drop_density = false;
if(plot_drop_density)
    drop_field = getDropField3(get_path(date));
    histogram(drop_field.time)
end

%Find the dsd for both the MRR and 2DVD data over the same period
reload_data = true;
if reload_data || ~exist('mrr_dsd', 'var') || ~exist('dvd_dsd', 'var')
    disp("Finding 2DVD dsd...");
    dvd_dsd = get_2DVD_DSD2(date,start_time, duration);
    disp("Finding MRR dsd...");
    mrr_dsd = get_MRR_DSD(date,start_time, duration);
    disp("Done loading data.");
end


% mrr_rr_plot = mrr_rr(1:end, :);
% dvd_rr_plot = dvd_rr(1:end, :);
% max_rr = min(max([mrr_rr_plot, dvd_rr_plot], [], 'all'), 100);
% figure
% hold on
% histogram(mrr_rr_plot, 'BinEdges', linspace(0, max_rr, 200));
% histogram(dvd_rr_plot, 'BinEdges', linspace(0, max_rr, 200));
% legend('MRR RR', '2DVD RR')
% title(sprintf("Histograms of rainrates from each instrument for %s, at %s for %d minutes", datestr(date), datestr(start_time), minutes(duration)))
% xlabel('Rainrate (mm/h)')
% ylabel('Number of observations (10s interval)')


dvd_dsd_mod = dvd_dsd;
dvd_dsd_mod(1:8, :, :) = 0; %Remove diameters less than 0.4mm
mrr_dsd_mod = mrr_dsd;
mrr_dsd_mod(1:8, :, :) = 0; %Remove diameters less than 0.4mm
all_max_rr = max([
        max([get_DSD_RR(dvd_dsd), get_DSD_RR(mrr_dsd)], [], 'all'),
        %max([get_DSD_RR(dvd_dsd_mod), get_DSD_RR(mrr_dsd_mod)], [], 'all')
    ]);
all_max_dm = max([
        max([get_DSD_dm(dvd_dsd), get_DSD_dm(mrr_dsd)], [], 'all'),
        %max([get_DSD_dm(dvd_dsd_mod), get_DSD_dm(mrr_dsd_mod)], [], 'all')
    ]);
%all_max_dm = max([get_DSD_dm(dvd_dsd), get_DSD_dm(mrr_dsd), get_DSD_dm(dvd_dsd_mod), get_DSD_dm(mrr_dsd_mod)], [], 'all');

[n_fig, n_tiles] = make_plots(dvd_dsd, mrr_dsd, false);
%[m_fig, m_tiles] = make_plots(dvd_dsd_mod, mrr_dsd_mod, true);

%title(n_tiles, "Normal plots", "Unmodified data")
%title(m_tiles, "Modified plots", "Drops with diameters < 0.4mm removed")
%all_plots = [n_fig, m_fig];
all_plots = [n_fig];
for i = 1:numel(all_plots)
    figure(all_plots(i))
    for j = 1:2
        nexttile(j)
        %caxis([0, log10(all_max_rr)])
        caxis([0, all_max_rr])
        set(gca,'YTickLabels',num2cell(yticks*10))%set
        set(gca,'XTickLabels',num2cell(xticks*10))
        set(gca,'YTickLabels',num2cell(yticks*10))%set
        set(gca, 'FontSize', 18)
    end
    for j = 3:4
        nexttile(j)
        caxis([0, all_max_dm])
        set(gca,'YTickLabels',num2cell(yticks*10))%set
        set(gca,'XTickLabels',num2cell(xticks*10))
        set(gca,'YTickLabels',num2cell(yticks*10))%set
        set(gca, 'FontSize', 18)
    end
    start_str = datestr(timeofday(start_time+date));
    stop_str = datestr(timeofday(duration+start_time+date));
    title_str = "Rain Event "+p+", "+datestr(date) + start_str + " -" + stop_str;
    title(n_tiles, title_str, 'FontSize',32)
end







