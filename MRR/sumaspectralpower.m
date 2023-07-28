x(1:64,1)=SpectrumReflectivity(:,94,327);
x=10.^(x/10);
et=sum(x);

SumPV(1:128,1:248)=0.;
for i=1:128
    for j=1:248
        x(1:64,1)=SpectrumReflectivity(:,i,j);
        x=10.^(x/10);
        SumPV(i,j)=sum(x);
    end
end
figure
histogram(log10(SumPV),'Facecolor','none','Edgecolor','r')

%histogram((Za49-calibration_constant49)./10,'Facecolor','none','Edgecolor','g')')

SpectrumReflectivity=SpectrumReflectivity1(:,:,236:360);
SpectrumReflectivity(:,:,126:248)=SpectrumReflectivity2(:,:,1:123);