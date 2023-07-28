%Ignore this chunk of code, not being used for anything right now
%start_date = datetime(2021, 8, 1);
%stop_date = datetime(2021, 8, 31);
%summary = summarize_period(start_date:days(1):stop_date, 49, false);
% for d = 1:length(summary)
%     if isstruct(summary{1, d})%We have data for that day
%         nexttile
%         f = pcolor(summary{1, d}.time, summary{1, d}.range,  summary{1, d}.RR);
%         f.EdgeColor = 'none';
%         set(gca, 'ColorScale', 'log')
%         colorbar
%     end
% end


date=datetime(2021, 8, 18);
DSD = get_DSD(date);%Date is not used right now since we use Art's data
RR = get_RR(DSD);
Z = get_Z(DSD);

figure
contourf(log10(RR/1))
colorbar
colormap('turbo')
title("MRR49 Log(R_w/1 mm h^{-1})")
xlabel("10's of seconds")
ylabel('Height index, 10*m')
caxis([-1.75, 2.5])

% figure
% contourf(Z, 'LineColor', 'None')
% colorbar
% colormap('turbo')
% title("MRR49 Z, dBZ")
% xlabel("10's of seconds")
% ylabel('Height index, 10m increments')

function RR = get_RR(DSD)
    art_data = load('Aug192021.mat');
    diam = art_data.D64;%mm
    vel = art_data.v64;%m/s
    
    volume = pi * (diam/10).^3 /6;%cm^3    
    RR = DSD .* volume .* vel * 3.6;
    RR = squeeze(sum(RR, 1));
end

function Z = get_Z(DSD)
    idx_vals = csvread("D_V_sigB_values.csv");
    idx = idx_vals(:, 1);
    diam = idx_vals(:, 2);
    Z = zeros(size(DSD, 2, 3));
    for i = 1:size(idx_vals, 1)
        Z = Z + squeeze(DSD(idx(i), :, :).*diam(i)^6);
    end
    Z = 10*log10(Z);
end