% dispersion relationship
% Li Erikson
%
function [l]=ldis(T,h)
%on G:
g=9.81;
omega=2*pi./T;
D=omega.^2.*h/g;
iter=0;
iterm=50;
error=1;

if D>1
   xo=D;
else 
   xo=sqrt(D);
end

while(error)>0.001 & iter<10;
   F=xo-D./tanh(xo);
   DF=1+D./sinh(xo).^2;
   x1=xo-F./DF;
   error=abs((x1-xo)./xo);
   xo=x1;
   iter=iter+1;
end

if iter>iterm
   '10 iterations have been exceeded'
else
   l=2*pi*h./x1;
end
