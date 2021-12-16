%% Convert datawell hexadecimal strings to displacement values for searching raw displacements 

%not sure that I am working in the correct order through the hexstring,
%perhaps needs to go right to left? 

function [h,n,w] = datawell_hex_to_displacement(hexstring)
%hexstring from datawell 0xF23 is 18 characters long, but contains 2
%vectors. Each vector is 9 characters, with 3 characters per displacement
%(heave, north, west). See Pages 43-45 in Datawell DWTP 

h(1) = hex_to_disp(hex2dec(hexstring(1:3)));
n(1) = hex_to_disp(hex2dec(hexstring(4:6))); 
w(1) = hex_to_disp(hex2dec(hexstring(7:9)));  

h(2) = hex_to_disp(hex2dec(hexstring(10:12))); 
n(2) = hex_to_disp(hex2dec(hexstring(13:15))); 
w(2) = hex_to_disp(hex2dec(hexstring(16:18))); 


%% sub-function that applies equation 16 from Datawell DWTP (page 19) 
function displacement = hex_to_disp(val)
displacement = (0.457*sinh(val/457)); 
end

end
