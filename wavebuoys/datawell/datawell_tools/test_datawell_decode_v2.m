%% Test Datawell decode

hexstring = 'eb82e6e1cdd22b7de3'; 

raw = [hex2dec(hexstring(1:3)), hex2dec(hexstring(4:6)), hex2dec(hexstring(7:9)),...
    hex2dec(hexstring(10:12)), hex2dec(hexstring(13:15)), hex2dec(hexstring(16:18))]; 

ix=find(raw>2047);
raw(ix)=-4096; % two's complement

% also try raw = [-2044 1 2044] and compare with DWTP specifications

a = 457; 
b = a/1000; 
displacements = b*sinh(raw./a); 