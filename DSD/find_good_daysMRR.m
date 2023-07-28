all_dates=datetime(2022, 1, 16);
Z=0.1;

%Paths with functions used
addpath(pwd+"\MRR");
addpath(pwd+"\2DVD");
addpath(pwd+"\DSD");


%Get information to determine the beginnning and ending of rain events for
%testing
for d = 1:length(all_dates)
    summary = get_MRR_day_summary(all_dates(d), 49, true);
%     heightAvgRR=mean(summary.RR);
%     Threshold=mean(heightAvgRR)-Z*std(heightAvgRR);
%     Ind=find(heightAvgRR>=Threshold);
%     IndMin=min(Ind);
%     IndMax=max(Ind);
%     Duration=IndMax-IndMin;
%     conversionFactor=(24/length(heightAvgRR))*60;
%     minuteDuration=conversionFactor*Duration;
end


