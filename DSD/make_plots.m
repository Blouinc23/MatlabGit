function [fig, tiles] = make_plots(dvd_dsd, mrr_dsd, use_log_plots, plot_type)
arguments
    dvd_dsd  (64, :, :) double
    mrr_dsd  (64, :, :) double
    use_log_plots logical = false
    plot_type string = "all"
end
fig = figure;
tiles = tiledlayout('flow');
if plot_type == "rr" || plot_type == "all"
    mrr_rr = get_DSD_RR(mrr_dsd);%Rainrate
    dvd_rr = get_DSD_RR(dvd_dsd);%Rainrate
    max_rr = max([dvd_rr, mrr_rr], [], 'all');
    caxis_max = max_rr;
    if use_log_plots
        contours = [0:2:8, 10:10:100, 150:50:1000];
        nexttile
        contourf(log10(dvd_rr), log10(contours), 'LineColor', 'none')
        colorbar
        caxis([0, log10(caxis_max)])
        colormap('jet')
        title("Rainrates of 2DVD (mm/hr)")
        xlabel('Time (s)')
        ylabel('Height (m)')
        nexttile
        contourf(log10(mrr_rr), log10(contours), 'LineColor', 'none')
        colorbar
        caxis([0, log10(caxis_max)])
        colormap('jet')
        title("Rainrates of MRR (mm/hr)")
        xlabel('Time (s)')
        ylabel('Height (m)')
    else
        nexttile
        contourf(dvd_rr, 'LineColor', 'none')
        colorbar
        caxis([0, caxis_max])
        colormap('jet')
        title("Rainrates of 2DVD (mm/hr)")
        xlabel('Time (s)')
        ylabel('Height (m)')

        nexttile
        contourf(mrr_rr, 'LineColor', 'none')
        colorbar
        caxis([0, caxis_max])
        colormap('jet')
        title("Rainrates of MRR (mm/hr)")
        xlabel('Time (s)')
        ylabel('Height (m)')
    end
end
if plot_type == "dm" || plot_type == "all"
    mrr_dm = get_DSD_dm(mrr_dsd);%Mass weighted mean diameter
    dvd_dm = get_DSD_dm(dvd_dsd);%Mass weighted mean diameter
    max_dm = max([dvd_dm, mrr_dm], [], 'all');
    contours = [0:0.25:2, 2.5:0.5:8];
    caxis_max = max_dm;
    nexttile
    contourf(dvd_dm, 30, 'LineColor', 'none')
    colorbar
    caxis([0, caxis_max])
    colormap('jet')
    title("D_m of 2DVD (mm)")
    xlabel('Time (s)')
    ylabel('Height (m)')

    nexttile
    contourf(mrr_dm, 30, 'LineColor', 'none')
    colorbar
    caxis([0, caxis_max])
    colormap('jet')
    title("D_m of MRR (mm)")
    xlabel('Time (s)')
    ylabel('Height (m)')
    
end
end
