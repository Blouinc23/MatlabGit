function [v]=termpoly(D)

% This function converts a diameter (in mm) to a terminal velocity
% following the 9th order polynomial expression (from JAM, 1969) by Foote
% and duTouit?
%
% Michael L. Larsen, 3/4/14
% ************************************************************************

v=-8.5731540e-2+3.3265862*D + 4.3843578*D.^2 - 6.8813414*D.^3 + 4.7570205*D.^4 - 1.9046601*D.^5 + 4.6339978e-1*D.^6 - 6.7607898e-2*D.^7+5.4455480e-3*D.^8-1.8631087e-4*D.^9;