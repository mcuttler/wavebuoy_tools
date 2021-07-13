function [NS,NE,ndirec,ndirecA, direc] = lygre_krogstad_MC(a1,a2,b1,b2,Ein,dtheta);

%%
% Estimates directional spectrum from directional moments and variance
% using the Maximum Entropy Method (MEM) as described in Lygre & Krogstad.
% 1986, JPO.
%
% Output:
% NS -> normalized distribution
% NE -> energy distribution

%Edited - M Cuttler, UWA (July 2018)
%    -Fixed directional convention export (12 July 2018)
%%
%% L&K notation
d1 = a1(:);
d2 = b1(:);
d3 = a2(:);
d4 = b2(:);
en = Ein(:);
c1 = d1 + i*d2;
c2 = d3 + i*d4;
p1 = (c1-c2.*conj(c1))./(1-abs(c1).^2);
p2 = c2-c1.*p1;
x1 = 1-p1.*conj(c1)-p2.*conj(c2);

% define directional domain (dtheta from input)
direc   = (0:dtheta:359.9);

% get distribution with "dtheta" degree resolution
dr  = pi/180;
tot = 0;
for n = 1:length(direc),
    alpha = direc(n)*dr;
    e1 = exp(-i.*alpha);
    e2 = exp(-2.*i.*alpha);
    y1 = abs(1-p1.*e1-p2.*e2).^2;
    S(:,n)=(x1./y1);
end
S = real(S);

% normalize

tot=sum(S,2)*dtheta;
for ii=1:length(en) %each frequency
    Sn(ii,:)=S(ii,:)/tot(ii);
end;

% calculate energy density by multiplying the energies at each frequency
% by the normalized directional distribution at that frequency

for ii = 1:length(en);
    E(ii,:) = Sn(ii,:).* en(ii);
end;

% modify directional convention (modifies by 270 to switch to Nautical with
% north at vertical
%export this direction as it's what the output spectra correspond to (MC)

ndirecA = 270-direc;
ndirec  = 270-direc;
ia      = find(ndirec <0);
ndirec(ia) = ndirec(ia)+360;

% map to 0-360
NE = zeros(size(E));
NS = zeros(size(Sn));
for ii = 1:length(direc);
    ia = find(ndirec==direc(ii));
    if ~isempty(ia)
        NE(:,ii) = E(:,ia);
        NS(:,ii) = Sn(:,ia);
    else
        fprintf(1,'\n !!! Error converting to geographic coordinate frame !!!');
    end
end
