%Stack columns onto first column to form a vector from matrix A
clear
X=Za49;
O=X;
%[nrow,ncol] = size(O);
nrow=128;
ncol=360;
VN(1:nrow*ncol,1)=0.;
for i=1:ncol
    VN((i-1)*nrow+1:i*nrow,1)=O(1:nrow,i);
end
%VN=VN-mean(VN);
%sd=sqrt(var(VN));
%VN=VN/sd;
%dlmwrite('C:\FortranOut\BayesAM\RRALLDixie.txt',VN);
%dlmwrite('C:\Users\arjam\Documents\MyFiles\Proposals\New Proposal2019\MRR\NASAMRR\ZeAdj.txt',VN);
