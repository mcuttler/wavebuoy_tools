%% function to re-organise resutls of qartod QAQC tests into final subflag for IMOS netcdf



function [output] = qaqc_combine_qartod_flags(bulkparams_nc,field,tests); 


for j = 1:length(tests)
    if tests(j)==19
        testnames{j,1} = ['qf_' num2str(tests(j))]; 
    else        
        testnames{j,1} = [field '_' num2str(tests(j))]; 
    end
end

txtout = []; 
for jj = 1:length(testnames)
    txtout = [txtout, num2str(bulkparams_nc.(testnames{jj}))]; 
end

output = str2num(txtout); 
end





    

    

        

    

    




