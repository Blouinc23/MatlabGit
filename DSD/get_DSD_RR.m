%Returns the rainrate at each height/time for the input DSD in mm/h
function [RR,RRBase] = get_DSD_RR(dsd)
arguments
    dsd  (64, :, :) double
end
art_data = load('ArtData.mat');
diam = art_data.D64;
vel = art_data.v64;

volume = pi * (diam).^3 /6;%mm^3    
RR = dsd .* volume .* vel * 3.6e-3;
RRBase=RR;
RR = squeeze(sum(RR, 1));
RR(RR==0) = NaN;
end