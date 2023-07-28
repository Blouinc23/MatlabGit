all_dates=datetime(2021, 1, 251:267);
start_time = hours(18)+minutes(44);
duration = minutes(40);

%Use to plot a histogram of drop density through the day to find good times
%for analysis
counts = NaN(size(all_dates));
figure
for d = 1:length(all_dates)
    drop_field = getDropField3(get_path(all_dates(d)));
    if size(drop_field) ~= [1, 1]
        counts(d) = size(drop_field, 1);
        %nexttile
        histogram(drop_field.time, minutes(0):minutes(5):hours(24))
        title(d)
    end
end


