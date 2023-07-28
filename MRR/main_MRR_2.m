%This script is meant to replicate the steps the MRR takes in going from
%raw data to DSD, VEL, and other measurements. Currently it is not working
%as multiple parts of steps we are missing info.

%Our MRRs are serial numbers #49 and #50
%---------------%
%clear all
%-----Load in file to more useable format
%Open file.
[source, path] = uigetfile('.nc');
file = cat(2, path,source);
%Read file data into struct called read_data. This has all the data in the
%file, but is unwieldy as is
read_data = ncinfo(file);
%Extract variable names from read_data, then create D and D_param
var_names = cell(length(read_data.Variables), 1);
d_vals = cell(length(read_data.Variables), 1);
temp = cell(length(read_data.Variables), 1);
for i=1:length(var_names)
    var_names{i} = read_data.Variables(i).Name;
    d_vals{i} = ncread(file, var_names{i});
end

args=[var_names,d_vals]';
%Data is the data struct containing all data from t
Data = struct(args{:});
%D_param contains info about each variable and what the dimensions
%correspond to
D_param = read_data.Variables;

%Lookup tables
warning('off', 'MATLAB:xlsread:ActiveX');
diam_vel_vals = xlsread("Diam_VelMRR.xlsx");
v = diam_vel_vals(:, 2)';
D = diam_vel_vals(:, 1)';
sigma_vals = xlsread("mrr_sigma_ext.xlsx");
sigma_back = interp1(sigma_vals(:, 1), sigma_vals(:, 2), D);
sigma_back(isnan(sigma_back)) = 0;
sigma_ext = interp1(sigma_vals(:, 1), sigma_vals(:, 3), D);
sigma_ext(isnan(sigma_ext)) = 0;

%---------------%
%-----Begin replicating calculation of products following MRR "description
%of products" manual-----
%Configurable parameters
N = D_param(33).Dimensions(2).Length;       %Num range gates
m = D_param(33).Dimensions(1).Length;       %Num lines in spectrum
T_i = 1;    %SET MANUALLY                   %Time of incoherent averaging
delta_r = D_param(17).Attributes(6).Value;  %Range resolution
num_obvs = D_param(33).Dimensions(3).Length;
%Fixed parameters
f_s = 500000;                               %Sampling rate, 500kHz
lambda = 1.238*10^-2;                       %Wavelength, meters
c = 2.997*10^8;                             %Velocity of light (in air)
%Dependent Parameters
B = c/(2*delta_r);                          %Signal Bandwidth
I = f_s*T_i/(2*N*m);                        %Number of incoherently averaged spectra
M = m;                                      %Number of sweeps for a single measurement
T_s = 2*N/f_s;                              %Sweep Time
f_ny = f_s/(2*N);                           %Nyquist frequency range
v_ny = lambda*f_s/(4*N);                    %Nyquist velocity range
delta_t = m*T_s;                            %Time resolution of one spectrum (single measurement)
delta_f = 1/delta_t;                        %Frequency resolution
delta_v = lambda/(2*m*T_s);                 %Velocity resolution
H = N*delta_r;                              %Height range

sigma_back = pi^5 * .92 * D.^6 / lambda;

%Derived Products

PIA = exp(Data.Z) ./ exp(Data.Za);

% %Backscatter cross-section : sigma
% eta_a_in = Data.spectrum_raw .* Data.calibration_constant .* ((1:N).^2) .* delta_r ./ Data.transfer_function';
% eta_a_in(isinf(eta_a_in)) = 0;
% 
% %Attenuated drop size dristributions : N_a
% eta_a_vn = eta_a_in/delta_v;
% %Ignore air density correction delta_rho, it is very minor
% delta_v_delta_D = 6.18*exp(-.6*D);
% eta_a_Dn = eta_a_vn.*delta_v_delta_D';
% N_a = eta_a_Dn./sigma_back;
% N_a(isnan(N_a) | isinf(N_a)) = 0;
% 
% % %Path Integrated attenuation : PIA
% PIA = ones(N, num_obvs);
% N_prime = zeros(m, N, num_obvs);
% k_e_prime = zeros(N, num_obvs);
% N_Dn = zeros(m, N, num_obvs);
% k_e = zeros(N, num_obvs);
% for n=2:N
%     N_prime(:, n, :) = squeeze(N_a(:, n, :)).*PIA(n-1, :);
%     k_e_prime(n, :) = squeeze(sum(sigma_ext' .* N_prime(:, n, :)))';
%     N_Dn(:, n, :) = -squeeze(N_prime(:, n, :)).*log(1-2*k_e_prime(n, :)*delta_r) ./ (2*k_e_prime(n, :)*delta_r);
%     k_e(n, :) = squeeze(sum(sigma_ext' .* N_Dn(:, n, :)))';
%     PIA(n, :) =PIA(n-1, :) .* exp(2*k_e(n, :)*delta_r);
%     if PIA(n, :) > 10
%         break   %NOTE: This will only break when the PIA for all t at n are 1
%     end
% end
% 
% %Drop Size Distribution : N_DSD
% N_DSD = N_a .* reshape(PIA, 1, N, num_obvs);
%     
% %Radar reflectivity factor : Z
% Z = 10^18 * squeeze(sum(N_DSD .* (D.^6)'));
% Z_log = 10*log(Z);
% 
% %Attenuated radar reflectivity factor : Z_a
% Z_a = Z./PIA;
% Z_a_log = 10*log(Z_a);
% 
% %Equivalent radar reflectivity factor : Z_e
% %|K|^2 = 0.92 (ART line 177)
% eta = squeeze(sum(sigma_back.*N_DSD, 1));
% Z_e = 10^18 * lambda^4 * eta / (pi^5 * .92);
% Z_e_log = 10*log(Z_e);
% 
% %Attenuated equeivalent reflectivity factor : Z_ea
% Z_ea = Z_e ./ PIA;
% Z_ea_log = 10*log(Z_ea);
% 
% %Liquid Water Content : LWC
% rho_w = 0.9998395; %Density of water
% LWC = squeeze(rho_w * pi / 6 * sum(N_DSD.*(D.^3)'));
% 
% %Rain Rate : RR
% RR = squeeze(pi / 6 * sum(N_DSD.*((D.^3).*v)', 1));
% 
% %Characteristic Fall Velocity : VEL
% i_1 = sum(eta_a_in .* (1:m)', 1) ./ sum(eta_a_in, 1);
% VEL = squeeze(lambda / 2 * delta_f * i_1);
% 
% %Spectral Width : WIDTH
% i_2 = squeeze(sum(eta_a_in .* ((1:m)'-i_1)).^2 ./ sum(eta_a_in, 1));
% WIDTH = lambda / 2 * delta_f * i_2;

%Signal to Noise Ratio : SNR
%???

%Melting Layer : ML
%No derivation given

% figure();
% graph_Z = pcolor(Data.Z);
% graph_Z.EdgeColor = 'none';
% title('Z, db');
% xlabel('seconds');
% ylabel('height (10m slices)');
% colorbar;
% 
% figure();
% graph_VEL = pcolor(Data.VEL);
% graph_VEL.EdgeColor = 'none';
% title('VEL, db');
% xlabel('seconds');
% ylabel('height (10m slices)');
% colorbar;
% 
% figure();
% graph_RR = pcolor(log10(Data.RR));
% graph_RR.EdgeColor = 'none';
% title('Log_{10}(R), mm h^{-1}');
% xlabel('seconds');
% ylabel('height (10m slices)');
% colorbar;