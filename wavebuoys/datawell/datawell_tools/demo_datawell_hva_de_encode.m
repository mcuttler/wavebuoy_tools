% demo_datawell_hva_de_encode

% constants
b = 457;
milli_b = b/1000;

i = [-2044 -1 0 1 2044]

displacement = milli_b * sinh(i./b) % decode

ii = b*asinh(displacement/milli_b)  % encode

%%
b = 457;
milli_b = b/1000;

hn1 = hex2dec('265');
nn1 = hex2dec('040');
wn1 = hex2dec('e85');
hn = hex2dec('182');
nn = hex2dec('0d2');
wn = hex2dec('e51'); 

i = [hn1 nn1 wn1 hn nn wn];
displacement = milli_b * sinh(i./b) % decode
