function [TotalAccum,CumAcc] = TotalAccumulation(mrr_rr,heightBins)
%This function gets the total accumulated rain during a rain event for the
%mrr with given heightbins. TotalAccum is a vector with the final total
%accumulation for the given rain event. CumAcc is the cumulative
%accumulation over time for each height bin. Useful for some plots
mrr_rr_0=mrr_rr;
mrr_rr_0(isnan(mrr_rr_0))=0;
Constant=1;

for j=1:length(heightBins)
    for i=1:size(mrr_rr_0,2)
        CumAcc(i,j)=Constant.*trapz(mrr_rr_0(heightBins(j),1:i)',1);
    end
end
TotalAccum=CumAcc(end,:);
end

