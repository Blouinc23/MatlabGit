function f = graph_mrr_sim(rain_rates, instruments)
    f = figure;
    for i = instruments
        subplot(4, 2, i)
        histogram(rain_rates(i, :), (0:.5:30))
        %histogram(rain_rates(i, :))
        title("Simulated MRR rain_rates, instrument " + i)
    end
end