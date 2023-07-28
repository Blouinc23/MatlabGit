art_dsd = get_DSD_ART;
art_rr = get_DSD_RR(art_dsd);
art_rr_log = log10(art_rr/10);

figure
contourf(art_rr_log)
colorbar
colormap('turbo')
title("MRR49 Log(R_w/1 mm h^{-1})")
xlabel("10's of seconds")
ylabel('Height index, 10*m')