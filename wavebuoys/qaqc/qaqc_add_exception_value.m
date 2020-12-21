%% add exception value to all data in input structure


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 21 Dec 2020 | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------
%  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [output] = qaqc_add_exception_value(data,fields,flag)
output = data; 
fieldnms = fieldnames(output); 

idx = intersect(fields, fieldnms); 

for i = 1:length(idx)
    output.(idx{i})(flag) = -9999;
end

end


