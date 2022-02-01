%% Test Datawell decode

hexstring = 'f47e19d3b05be93d21'; 

raw = [hex2dec(hexstring(1:3)), hex2dec(hexstring(4:6)), hex2dec(hexstring(7:9)),...
    hex2dec(hexstring(10:12)), hex2dec(hexstring(13:15)), hex2dec(hexstring(16:18))]; 

a = 457; 
b = a/1000; 
displacements = b*sinh(raw./a); 