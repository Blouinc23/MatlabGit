%Returns the mass weighted mean diameter at each height/time for the input DSD in mm/h
function dm = get_DSD_dm(dsd)
arguments
    dsd  (64, :, :) double
end
art_data = load('ArtData.mat');
diam = art_data.D64;

dm = squeeze(sum(diam.^4 .* dsd, 1, 'omitnan')./sum(diam.^3 .* dsd, 1, 'omitnan'));
end