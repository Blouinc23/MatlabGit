function DSD = get_DSD_ART
art_data = load('ArtData.mat');
sigma_arr = art_data.SBV';
spectrum = art_data.SpectrumReflectivity;
spectrum = spectrum(:, :, 1:228);
spectrum = 10.^(spectrum/10);
shifts = art_data.wshft;

DSD = NaN(size(spectrum));
for t = 1:size(spectrum, 3)%time t
    for h = 1:size(spectrum, 2)%height slice h
        if ~isnan(shifts(h, t))%Solution exists
            shifted_spectrum = circshift(spectrum(:, h, t), shifts(h, t));
            DSD(:, h, t) = 10^4 * shifted_spectrum ./ sigma_arr';
        end
    end
end
diam_idx = art_data.D64>0.22 & art_data.SBV>0;
DSD(~diam_idx, :, :) = 0;
DSD(DSD<.0001) = 0;
end



