function [VertWind,VertWindAll,vDiffCell] = VerticalWind(date, start_time, period, serial_number, verbose)
%This function gives the vertical wind profile over time given the data and
%duration like the other functions use 
arguments
    date datetime;
    start_time duration=minutes(0);
    period duration = minutes(30);%Duration since midnight
    serial_number double = 49;
    verbose logical=false;
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
%Loading in artdata
art_data = load('ArtData.mat');
sigma_arr = art_data.SBV';
v64=art_data.v64;

if verbose
    VertWind=zeros([size(spectrum,2),size(spectrum,3)]);
    VertWindAll=zeros(size(spectrum));
    for t=1:size(spectrum,3)
        for h=1:size(spectrum,2)
            for b=1:size(spectrum,1)
                if ~isnan(shifts(h,t))
                    vDiff=v64-circshift(v64,shifts(h,t));
                else
                    vDiff=zeros(size(v64));
                end
                vDiffCell(b,h,t)={vDiff};
                VertWindAll(b,h,t)=vDiff(b);
                VertWind(h,t)=vDiff(1);
            end
        end
    end
% This is shifting by mod(64), try to use the value of the shift to
% determine the wrap around 
elseif ~verbose 
    VertWind=zeros([size(spectrum,2),size(spectrum,3)]);
    VertWindAll=0;
    vDiffCell={0};
    for t=1:size(spectrum,3)
        for h=1:size(spectrum,2)
            if ~isnan(shifts(h,t))
                vDiff=v64-circshift(v64,shifts(h,t));
            else
                vDiff=zeros(size(v64));
            end
            VertWind(h,t)=vDiff(1);
        end
    end
end


end