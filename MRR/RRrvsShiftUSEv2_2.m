%VERTICAL WINDS AND SPECTRA ARE NOT NEARLY AS CONSISTENT AT USING THE
%ADJUSTSPECTRAL aPPROACH SO Deffective IS OK USING THE ADJUSTSPECTRAL
%APPROACH%%Note 1-90 corresponds to 240-330 for SpectrumReflectivity
%
%ITLOW AND ITHI ARE THE LOWER AND UPPER TIME LIMITS
%
ITLOW=1;
ITHI=228;
%Zfact=3.0409;
%For Middle Period
%Zfact=10;
%The Zfact below is the difference between the thoeretical 79.24 and the fit
%to Ze.  Zec is the recalculated Ze using the fit between Ze in dBZ and the
%SumPVlog
%Zfact=3.2885;
%Zfact=7.1758;
Zec=82.517669+1.05*SumPVLog;
Zeta1=10.^(Zec/10);
%Zeta1=10.^((Za/10);
Zfact=2.1182;
ZZ=Zeta1/Zfact;
%ZZ=Zeta1;
%
%DBRED IS THE REDUCTION IN THE POWR SPECTRAL DENSITIES IN DB DONE TO
%MAXIMIZE THE NUMBER OF SOLUTIONS
%
%DBRED=2.42;
DBRED=-.5;
%DBRED=-4.11;
%DBRED=7.95;
%ITinc IS THE TIME SHIFT IF PICKING OUT A DELAYED TIME SEGMENT IN A TIME
%SERIES
%
%ITInc=99;
ITInc=0;
%IMPORTANT
%MAKE SURE ZZ HAS NO NaN
%

tf=isnan(ZZ);
ZZ(tf)=0.;
%
Dvol(1:64,1)=0.;
for i=1:64
    Dvol(i)=pi*((D64(i)/10).^3)/6.;
end
ifsol(1:128,1:ITHI)=0;
wshft(1:128,1:ITHI)=NaN;
Rshft(1:128,1:ITHI)=0.;
Varshft(1:128,1:ITHI)=0.;
Meanshft(1:128,1:ITHI)=0.;
VarDshft(1:128,1:ITHI)=0.;
MeanDshft(1:128,1:ITHI)=0.;
Nshft(1:128,1:ITHI)=0.;
Zshft(1:128,1:ITHI)=0.;
D289shft(1:128,1:ITHI)=0.;
Dbarshft(1:128,1:ITHI)=0.;
D3barshft(1:128,1:ITHI)=0.;
for IT=ITLOW:ITHI
    for k=1:128
        
        x=SpectrumReflectivity(:,k:k,IT+ITInc)-DBRED;
        %
        %THE POWER IN EACH VELOCITY BIN IS CONVERTED TO THE TOTAL NUMBER OF
        %PARTICELS PER CUBIC METER AT THAT VELOCITY. SINCE THE VELOCITY BIN
        %INCREMENT IS FIXED, THE CONVERSION TO PARTICLE CONCENTRATION AUTOMATICALLY
        %ACCOUNTS FOR DIFFERENT DROP BIN SIZES BECAUSE THE NUMBER OF PARTICLES
        %AUTOMATICALLY ADJUSTS. THEREFORE, DELTAD IS UNNECESSARY
        %
        for i=1:64
            if(x(i,1) == -Inf)
                x(i,1)=-999;
            end
        end
        nshft=63;
        NtstTot(1:nshft,1)=0.;
        RtstTot(1:nshft,1)=0.;
        D289Tot(1:nshft,1)=0.;
        MtstTot(1:nshft,1)=0.;
        DtstTot(1:nshft,1)=0.;
        D3tstTot(1:nshft,1)=0.;
        VarRtst(1:nshft,1)=0.;
        MeanRtst(1:nshft,1)=0.;
        D08Tot(1:nshft,1)=0.;
        VarNtst(1:nshft,1)=0.;
        MeanNtst(1:nshft,1)=0.;
        Dbartst(1:nshft,1)=0.;
        D3bartst(1:nshft,1)=0.;
        for i=1:nshft
            NewTSTSpect = circshift(x,i);
            Extst=10.^(NewTSTSpect/10.);
            Sumextst=sum(Extst);
            Ntst(1:64,1)=0.;
            Mtst(1:64,1)=0.;
            Rtst(1:64,1)=0.;
            D289(1:64,1)=0.;
            D08(1:64,1)=0.;
            nD(1:64,1)=0.;
            nn(1:64,1)=0.;
            rr(i:64,1)=0.;
            Dmntst(1:64,1)=0.;
            D3tst(1:64,1)=0.;
            for j=1:64
                if(SBV(j) > 0 && D64(j) > 0.22)
                    nD(j,1)=10^4*(Extst(j)./SBV(j));
                end
                Rtst(j,1)=3.6*nD(j,1)*v64(j)*Dvol(j);
                nn(j,1)=nD(j,1);
                rr(j,1)=Rtst(j,1);
                if(nn(j,1) < .0001)
                    nn(j,1)=NaN;
                    rr(j,1)=NaN;
                end
                %
                %
                D289(j,1)=D64(j,1)^2.89*Rtst(j,1);
                D08(j,1)=(1/D64(j,1)^(.08))*Extst(j);
                if (D08(j,1) > 1 )
                    D08(j,1)=0.;
                end
                Ntst(j,1)=nD(j,1);
                Mtst(j,1)=nD(j,1)*Dvol(j);
                Dmntst(j,1)=nD(j,1)*D64(j);
                D3tst(j,1)=nD(j,1)*D64(j)^3.;
            end
            VarRtst(i,1)=nanvar(rr);
            MeanRtst(i,1)=nanmean(rr);
            VarNtst(i,1)=nanvar(nn);
            MeanNtst(i,1)=nanmean(nn);
            NtstTot(i,1)=sum(Ntst,1);
            RtstTot(i,1)=sum(Rtst,1);
            D289Tot(i,1)=sum(D289,1);
            D08Tot(i,1)=sum(D08);
            MtstTot(i,1)=sum(Mtst,1);
            DtstTot(i,1)=sum(Dmntst,1);
            D3tstTot(i,1)=sum(D3tst,1);
        end
        D289bar=D289Tot./RtstTot;
        D08bar=D08Tot/Sumextst;
        D3bar=D3tstTot./NtstTot;
        Dbar=DtstTot./NtstTot;
        %
        Coef=79.936;
        Zshfttst=D289bar.*RtstTot*Coef;
        %Zshfttst=D289bar.*D08bar.*RtstTot*799.36;
        %Zshfttst=D289bar.*D08bar.*RtstTot*715.213;
        %Zshfttst=(D289bar./D08bar).*RtstTot*7993.6;
        %Zshfttst=(D289bar./D08bar).*RtstTot*79.936;
        %find smallest deviation from observations
        %
        Ztst=ZZ(k,IT);
        Difz(1:63,1)=999.;
        for ii=1:63
            Difz(ii,1)=abs(Zshfttst(ii,1)-Ztst);
            localMinIndexes = find(imregionalmin(Difz));
            L=length(localMinIndexes);
            %Find minv with max NtstTot
            ntst(1:100,1)=0.;
            for i=1:L
                ntst(i,1)=NtstTot(localMinIndexes(i));
            end
            [~,minn] = max(ntst,[],'omitnan','linear');
            minv=localMinIndexes(minn);
        end
        %localMinIndexes = find(imregionalmin(Difz));
        %L=length(localMinIndexes);
        %for i=1:L
        %    Rpsbl(i,1)=RtstTot(localMinIndexes(i));
        %    Zpsbl(i,1)=(300.*Rpsbl(i)^1.35)/Ztst;
        %end
        %for i=1:L
        %if(Zpsbl(i) > 0.5*Ztst)
        %    minv=localMinIndexes(i);
        %end
        %end
        %Note that wshft is really the location of wair=0 so that minv<32 are
        %updrafts and minv>32 are downdrafts
        %
        if(L > 1 && Difz(minv) < 1000)
            ifsol(k,IT)=1;
        end
        wshft(k,IT)=minv;
        Rshft(k,IT)=RtstTot(minv);
        Varshft(k,IT)=VarRtst(minv);
        Meanshft(k,IT)=MeanRtst(minv);
        VarDshft(k,IT)=VarNtst(minv);
        MeanDshft(k,IT)=MeanNtst(minv);
        Nshft(k,IT)=NtstTot(minv);
        Zshft(k,IT)=Zshfttst(minv)*Zfact;
        D289shft(k,IT)=D289bar(minv);
        D3barshft(k,IT)=D3bar(minv);
        Dbarshft(k,IT)=Dbar(minv);
    end
end
RDshft=Varshft.^.5./Meanshft;
RDNshft=VarDshft.^.5./MeanDshft;
wms=-1*(wshft-32)*Delv;

