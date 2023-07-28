%Get the DSD to the corresponding period/instrument
function DSD = get_DSD(date, start_time, period, serial_number)
arguments
    date datetime;
    start_time duration = minutes(0);%Duration since midnight
    period duration = minutes(30);%Duration since midnight
    serial_number double = 49;
end

%Get the data
day_data = get_MRR_day_summary(date, serial_number, true);
%Convert from log
spectrum = 10.^(day_data.spectrum_reflectivity/10);
%Restrict time to specified period
start = start_time/seconds(10)+1;
stop = (start_time+period)/seconds(10);
spectrum = spectrum(:, :, start:min(stop, 8640));
%Find shifts to diameter bins based on calculated local vertical wind
shifts = get_shifts(spectrum);

art_data = load('ArtData.mat');
sigma_arr = art_data.SBV';
%s2=(sigma_arr(1:end-1)+sigma_arr(2:end))/2
%s2=[s2 0];

%Calculate the DSD
DSD = zeros(size(spectrum));
UnshiftedDSD = zeros(size(spectrum));
%At each time...
for t = 1:size(spectrum, 3)%time t
    %And each height...
    for h = 1:size(spectrum, 2)%height slice h
        %If there is a solution...
        if ~isnan(shifts(h, t))
            %Shift the spectrum
            shifted_spectrum = circshift(spectrum(:, h, t), shifts(h, t));
            %And add to the DSD there, with some unit adjustments
            % Trying to get unshifted spectrum

          
            DSD(:, h, t) = 10^4 * shifted_spectrum ./ sigma_arr';
            UnshiftedDSD(:,h,t)=10^4*spectrum(:,h,t)./sigma_arr';
            %DSD(:, h, t) = 10^4 * shifted_spectrum ./ s2';
        else%Solution did not exist, set to NaN
            DSD(:, h, t) = NaN;
            UnshiftedDSD(:,h,t)=NaN;
        end
    end
end
%Filter out some drops we don't trust
diam_idx = art_data.D64>0.22 & art_data.SBV>0;
DSD(~diam_idx, :, :) = 0;
DSD(DSD<.0001) = 0;
UnshiftedDSD(~diam_idx, :, :) = 0;
UnshiftedDSD(DSD<.0001) = 0;
end