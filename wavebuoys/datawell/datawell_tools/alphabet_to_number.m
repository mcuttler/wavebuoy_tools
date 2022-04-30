%% convert alphabet to numbers (0-25)

function [n] = alphabet_to_number(letter,nform)

%include both upper and lower case alphabet so case insensitive
a_upper = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
a_lower = 'abcdefghijklmnopqrstuvwxyz';

n = find(letter==a_upper | letter==a_lower); 
%determine value of A - either 0 or 1. Sets full range as 0-25 or 1-26; 
if nform==0 
    n = n-1; 
end
    
end


