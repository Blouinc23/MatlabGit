%Returns simulated mrr data from the given lpm_data, for a mrr_height
%vertical chunk. Assume lpm data has been processed using one minute
%chunks.

%mrr_sim: num_instruments by num_ensembles by num_minutes cell array of 
%x by 3 double arrays, x being the number of drops for that
%minute/instrument. The three columns are, in order, drop diameter, drop
%fall velocity, and drop height (in the similated MRR's vertical range)

%mrr_sim_vol: same dimensions as mrr_sim, but rather than a cell array,
%returns a double showing the volume of water of the drops from that cell
%array

%mrr_sim_rain_rate: same dimensions as mrr_sim, but rather than a cell array,
%returns a double showing the rainrate of that cell array


function [mrr_sim, mrr_sim_info] = get_mrr_sim(lpm_data, mrr_height, ensemble_count, instruments, minutes_to_see)
    d_edges = [.125, .25, .375, .5, .75, 1, 1.25, 1.5, 1.75, 2, 2.5, 3, 3.5, 4, 4.5, 5, 5.5, 6, 6.5, 7, 7.5, 8, 10];
    v_edges = [0, .2, .4, .6, .8, 1, 1.4, 1.8, 2.2, 2.6, 3, 3.4, 4.2, 5, 5.8, 6.6, 7.4, 8.2, 9, 10, 20];
    mrr_sim = cell(length(instruments), ensemble_count, length(minutes_to_see));
    
    %Default minutes_to_see to the full day.
    if isnan(minutes_to_see)
        minutes_to_see = 1:size(lpm_data(1).summary.raw_interval_drops, 1);
    end
    %Default ensemble_count to one.
    if isnan(ensemble_count)
        ensemble_count = 1;
    end
        
    %Create simulated mrr data, then find its volume and rain rates
    for e = 1:ensemble_count %Ensemble
        for i = instruments %Instrument
            %for t = 1:size(lpm_data(i).summary.raw_interval_drops, 1) %Time
            for t = minutes_to_see
                t_sim = zeros(1000000, 3);
                t_drops = 0;
                for v = 1:size(lpm_data(i).summary.raw_interval_drops, 2) %Velocity
                    for d = 1:size(lpm_data(i).summary.raw_interval_drops, 3) %Diameter
                        %Create random diameters and volumes for the drops of that
                        %diameter/velocity bin, then give a random height within
                        %range of where they could have been, and add their volume
                        %to mrr_volume if that random height is within the
                        %mrr_height
                        ran_fractions = rand(1, lpm_data(i).summary.raw_interval_drops(t, v, d));
                        ran_d = d_edges(d) + ran_fractions * (d_edges(d+1)-d_edges(d));
                        ran_v = v_edges(v) + ran_fractions * (v_edges(v+1)-v_edges(v));                       
                        %ran_d =  d_edges(d)*ones(1, lpm_data(i).summary.raw_interval_drops(t, v, d));
                        %ran_v =  v_edges(v)*ones(1, lpm_data(i).summary.raw_interval_drops(t, v, d));
                        ran_h = ran_v .* 60 .* rand(1, size(ran_d, 2)); 
                        in_mrr = ran_h < mrr_height;
                        if(sum(in_mrr ~= 0))
                            t_sim(t_drops+1:t_drops+sum(in_mrr), :) = [ran_d(in_mrr); ran_v(in_mrr); ran_h(in_mrr)]';
                            t_drops = t_drops + sum(in_mrr);
                        end
                    end
                end
                mrr_sim{i, e, t - minutes_to_see(1) + 1} = t_sim(any(t_sim, 2), :);
            end
            disp(e + "; " + i)
        end
    end
    
    %Find volume for ensemble
    volume = cellfun(@total_vol, mrr_sim);
    %Find rain rate for ensemble
    rain_rate = cellfun(@(x) find_rain_rate(x, mrr_height), mrr_sim);
    %Find rain rate for ensemble    
    sigma_b = cellfun(@find_sigma_b, mrr_sim);
    
    %delta_d = cellfun(@(x) find_delta_d(x, d_edges), mrr_sim);
    
    r_prime = cellfun(@(x) find_r_prime(x, d_edges), mrr_sim);
    %Compile above into table
    mrr_sim_info = table(volume, rain_rate, sigma_b, r_prime);

end

%Find tptal volume of array of drops (summed together)
function vol = total_vol(drops)
        vol = sum(drop_vol(drops));
end

%Find volume of each drop in drops (don't sum)
function vol = drop_vol(drops)
    if isempty(drops)
        vol = 0;
    else   
        vol = (drops(:, 1).^3) * pi / 6;
    end
end

function rain_rate = find_rain_rate(drops, mrr_height)
    lpm_area = 4560; %mm^2
    if isempty(drops)
        rain_rate = 0;
    else
        fall_dist = drops(:, 2) * 3600;
        times_seen = floor((fall_dist - drops(:, 3)) / mrr_height);
        rain_rate = sum(times_seen .* drop_vol(drops) / lpm_area);
    end
end

function sigma_b = find_sigma_b(drops)
    sigma_b = {(1.33923*10^-4) * drops.^6.083};
end

function delta_d = find_delta_d(drops, d_edges)
    edges = [0, d_edges, 15];
    diff = drops(:, 1)-edges;
    index = sum(diff >= 0, 2);
    delta_d = {(edges(index+1) - edges(index))'};
end

function r_prime = find_r_prime(drops, d_edges)
    nd = drop_vol(drops) / (10*1*1); %Concentration of drops per unit volume.
    %Currently using dimension of 1x1x10 meters, but that does not
    %accurately reflect actual measurement dimernsions
    delta_d = cell2mat(find_delta_d(drops, d_edges));
    r_prime = {3.6 * (drops(:, 1).^3.124) .* nd .* delta_d};  
end