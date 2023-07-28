function [mrr_dsd,dvd_dsd,dvd_rr,mrr_rr] = AverageComparisonGraphs(date,start_time,duration,serial_number2dvd,reload)
%Turns the script created into a function that outpts mrr and 2dvd dsd and
%rr data as well as useful graphs for comparing the two over multiple rain
%events
addpath(pwd+"\MRR");
addpath(pwd+"\2DVD");
addpath(pwd+"\DSD");
addpath(pwd+"\ChrisB");


if reload
    mrr_dsd = get_MRR_DSD(date,start_time, duration);
    dvd_dsd = get_2DVD_DSD2(date,start_time, duration, serial_number2dvd);
    dvd_rr=get_DSD_RR(dvd_dsd);
    mrr_rr = get_DSD_RR(mrr_dsd);
end


%MRR Info and plot 
figure(1)
max_rr=max(max(get_DSD_RR(mrr_dsd)))
caxis_max = max_rr;
contourf(mrr_rr, 'LineColor', 'none')
colorbar
caxis([0, caxis_max])
colormap('parula')
title("Rainrates of MRR (mm/hr)")
xlabel('Time (s)')
ylabel('Height (m)')

%Replacing all the nans with 0
mrr_rr(isnan(mrr_rr))=0;
dvd_rr(isnan(dvd_rr))=0;

figure(2)
plot(max(mrr_rr'));
title("Max Rainrates of MRR (mm/hr)")
xlabel('128 Height Bins')
ylabel('Max Rain rate (mm/hr)')

figure(3)
hold on
title("Rainrates of Each Height bin (mm/hr)")
xlabel('Time (s)')
ylabel('Rain Rate(mm/hr)')
for i=1:size(mrr_rr,1)
    plot(mrr_rr(i,:))
end
hold off

figure(4)
hold on
title("Average Rain Rate of each height bin (mm/hr)")
xlabel("Height Bin")
ylabel("Rain Rate (mm/hr)")
plot(mean(mrr_rr'));
plot(max(mrr_rr'));
plot(mean(dvd_rr'));
plot(max(dvd_rr'));
legend("mrr","mrr max" ,"dvd averaged","dvd max")
hold off

figure(5)
hold on
title("Median Rain Rate of each height bin (mm/hr)")
xlabel("Height Bin")
ylabel("Rain Rate (mm/hr)")
plot(median(mrr_rr'));
plot(max(mrr_rr'));
plot(mean(dvd_rr'));
plot(max(dvd_rr'));
legend("mrr","mrr max" ,"dvd averaged","dvd max")
hold off


end

