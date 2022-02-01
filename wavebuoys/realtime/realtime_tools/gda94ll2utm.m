function[E,N,zone]=gda94ll2utm(lat,lon)
% Geographicals to grid using Redfearn's formulae
% latitudes and longitudes in decimal degrees
% see http://www.icsm.gov.au/gda/gdatm/index.html

%lat=-22-13/60-55.3539/3600;
%lon=113+50/60+32.2055/3600;
%lat=-37-39/60-10.15610/3600;
%lon=143+55/60+35.3839/3600;

% Set constants and parameters
a=6378137; %semi major axis
f=.003352811;%flattening
invf=1/f;%inverse flattening
b=6356752.314;%semi major axis
e2=2*f-f^2;%eccentricity
e=sqrt(e2);
e4=e2*e2;
e6=e4*e2;
eprime2=e2/(1-e2);%Second eccentricity
eprime=sqrt(eprime2);
n=(a-b)/(a+b);
n2=n*n;
n3=n2*n;
n4=n3*n;
G=a*(1-n)*(1-n2)*(1+9*n2/4+225*n4/64)*pi/180;
E0=500000;%false easting
N0=10000000;%false northing
K0=.9996;%central scale factor
zw=6;%zone width (degrees)
cm=-177;%longitude of central meridian
zone0=cm-(1.5*zw);%longitude of western edge of zone zero
cm0=zone0+(zw/2);%central meridian of zone zero
A0=1-e2/4-3*e4/64-5*e6/256;
A2=(3/8)*(e2+e4/4+15*e6/128);
A4=(15/256)*(e4+3*e6/4);
A6=35*e6/3072;

% calculate zone
zones=floor((lon-zone0)/zw);
% check that all data in same zone
% if(max(zones)-min(zones))
%     'data cover more than one zone'
%     stop
% end
zone=min(zones);
cz=zone*zw+cm0;%central meridian
dlon=(lon-cz)*pi/180;

la=lat*pi/180;
lo=lon*pi/180;
sinla=sin(la);
sinla2=sinla.*sinla;
sin2la=sin(2*la);
sin4la=sin(4*la);
sin6la=sin(6*la);
rho=a*(1-e2)./((1-e2*sinla2).^1.5);
nu=a./sqrt((1-e2*sinla2));
psi=nu./rho;
psi2=psi.*psi;
psi3=psi2.*psi;
psi4=psi3.*psi;

% Calculate meridian distance m
term1=a*A0*la;
term2=a*A2*sin2la;
term3=a*A4*sin4la;
term4=a*A6*sin6la;
m=term1-term2+term3-term4;

% Calculate powers of cos(la)
cosla=cos(la);
cosla2=cosla.*cosla;
cosla3=cosla2.*cosla;
cosla4=cosla3.*cosla;
cosla5=cosla4.*cosla;
cosla6=cosla5.*cosla;
cosla7=cosla6.*cosla;
cosla8=cosla7.*cosla;

% Calculate powers of dlon
dlon2=dlon.*dlon;
dlon3=dlon2.*dlon;
dlon4=dlon3.*dlon;
dlon5=dlon4.*dlon;
dlon6=dlon5.*dlon;
dlon7=dlon6.*dlon;
dlon8=dlon7.*dlon;

% Calculate powers of tan(la)
tanla=tan(la);
tanla2=tanla.*tanla;
tanla4=tanla2.*tanla2;
tanla6=tanla4.*tanla2;

% Easting
et1=nu.*dlon.*cosla;
et2=nu.*dlon3.*cosla3.*(psi-tanla2)/6;
et3=nu.*dlon5.*cosla5.*(4*psi3.*(1-6*tanla2)+psi2.*(1+8*tanla2)-2*psi.*tanla2+tanla4)/120;
et4=nu.*dlon7.*cosla7.*(61-479*tanla2+179*tanla4-tanla6)/5040;
E=E0+K0*(et1+et2+et3+et4);
%sprintf('%f',E)

% Northing
nt1=nu.*dlon2.*sinla.*cosla/2;
nt2=nu.*dlon4.*sinla.*cosla3.*(4*psi2+psi-tanla2)/24;
nt3=nu.*dlon6.*sinla.*cosla5.*(8*psi4.*(11-24*tanla2)-28*psi3.*(1-6*tanla2)+psi2.*(1-32*tanla2)-2*psi.*tanla2+tanla4)/720;
nt4=nu.*dlon8.*sinla.*cosla7.*(1385-3111*tanla2+543*tanla4-tanla6)/40320;
N=K0*(m+nt1+nt2+nt3+nt4)+N0;
%sprintf('%f',N)