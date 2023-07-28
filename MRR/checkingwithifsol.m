%
ITMAX=90;
for i=1:128
    for j=1:ITMAX
        if(ifsol(i,j) < 1)
            Zshft(i,j)=NaN;
        end
    end
end


for i=1:128
    for j=1:ITMAX
        if(Rshft(i,j) < 10^-2)
            Rshft(i,j)=NaN;
        end
    end
end

for i=1:128
    for j=1:ITMAX
        ZshftdB(i,j)=10*log10(Zshft(i,j));
    end
end

for i=1:128
    for j=1:ITMAX
        if(wshft(i,j) == 1)
            wshft(i,j)=NaN;
        end
    end
end
for i=1:128
    for j=1:ITMAX
        if(ZshftdB(i,j) < .01)
        ZshftdB(i,j)=NaN;
        end
    end
end

