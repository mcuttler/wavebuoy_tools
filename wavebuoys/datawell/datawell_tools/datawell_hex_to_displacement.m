%% Convert datawell hexadecimal strings to displacement values for searching raw displacements 
%hexstring from datawell 0xF23 is 18 characters long, but contains 2
%vectors. Each vector is 9 characters, with 3 characters per displacement
%(heave, north, west). See Pages 43-45 in Datawell DWTP 

%The two vectors correspond to the last two displacements in the sample
%window: 
% hn1 = second to last
% h = last 

%%

function [hn1,h] = datawell_hex_to_displacement(hexstring)


raw = [hex2dec(hexstring(1:3)), hex2dec(hexstring(4:6)), hex2dec(hexstring(7:9)),...
    hex2dec(hexstring(10:12)), hex2dec(hexstring(13:15)), hex2dec(hexstring(16:18))]; 

ix=find(raw>2047);

raw(ix)= raw(ix)-4096; % two's complement


a = 457; 
b = a/1000; 
dd = b*sinh(raw./a); 
hn1 = dd(1:3); 
h = dd(4:6); 


end
