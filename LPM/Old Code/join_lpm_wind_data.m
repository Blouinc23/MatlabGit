%Combines the data from get_day_lpm and get_wind_summary into one struct
function data = join_lpm_wind_data(lpm_data, wind_data)
    
    joined = outerjoin(lpm_data(1).summary, lpm_data(2).summary, 'LeftKeys', 1, 'RightKeys', 1, 'MergeKeys', true);
    data(1).all = innerjoin(table(wind_data.times, wind_data.wind_AB, 'VariableNames', {'times', 'wind'}), joined, 'LeftKeys', 1, 'RightKeys', 1);
    joined = outerjoin(lpm_data(3).summary, lpm_data(4).summary, 'LeftKeys', 1, 'RightKeys', 1, 'MergeKeys', true);
    data(2).all = innerjoin(table(wind_data.times, wind_data.wind_CD, 'VariableNames', {'times', 'wind'}), joined, 'LeftKeys', 1, 'RightKeys', 1);
    joined = outerjoin(lpm_data(5).summary, lpm_data(6).summary, 'LeftKeys', 1, 'RightKeys', 1, 'MergeKeys', true);
    data(3).all = innerjoin(table(wind_data.times, wind_data.wind_EF, 'VariableNames', {'times', 'wind'}), joined, 'LeftKeys', 1, 'RightKeys', 1);
    joined = outerjoin(lpm_data(7).summary, lpm_data(8).summary, 'LeftKeys', 1, 'RightKeys', 1, 'MergeKeys', true);
    data(4).all = innerjoin(table(wind_data.times, wind_data.wind_GH, 'VariableNames', {'times', 'wind'}), joined, 'LeftKeys', 1, 'RightKeys', 1);
    
end