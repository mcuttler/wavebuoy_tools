function [out]=spectra_bin_partitioning(out,info)

%Take output structure from spectra_from_displacements function and
%calcualte partitioned Sea and Swell and IG bulk parameters
%requires info structure as input as 
%  info.fminIG = 1/300; 
%  info.fminSS = 1/25; Swell min
%  info.fmaxSS = 1/8; %Sea/swell cuoff
%  info.fmaxSea = 1/2;     
% if no calcualtion of IG is desired do not include info.fminIG as a field
% in the input structure. You can also omit fminSS (swell min) and fmaxSea
% (sea max frequency). If only info.fmaxSS is provided the code will use a
% single cutoff to define sea/swell
%
%the out structure provided as an input must include:
%out.S  the 1D spectrum
%out.f the out.fuencies
%out.a1 S(
%out.a2 
%out.b1 
%out.b2 
%
%output from this code is simply added to the out structure as additional
%variables.
%
%****NOTE: attention should be paid to alignment between the input
%out.frequency vector and cut off frequencies (e.g. between sea and swell
%bands) in some cases it may be best to interpolate the spectrum to higher
%resolution frequency bins to ensure the cut off frequencies do not fall in the
%middle of bins. See code below to see usage of > vs >= and < vs <=
%
%v1.0 JEH April 2024
%v1.1 MC April 2024 - modify spreading to match Rogers and Wang (equation
%7) 
