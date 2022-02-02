%% qaqc subflag
% This code determines the 'reason' that data received the primary qa flag
% Only determines reason for bad or questionable data (primary flag of 3

function [primary_flag, sub_flag] = qaqc_temp_primary_and_subflag(bulkparams, fields, qaqc_tests); 

%check that temperature data exists (e.g. not just -9999)
if isfield(bulkparams,'temp')
    tfield = 'temp';
else
    tfield = 'surf_temp';
end

if all(bulkparams.(tfield)<0)
    primary_flag(:,1) = ones(size(bulkparams.(tfield),1),1).*4; 
    sub_flag(:,1) = ones(size(bulkparams.(tfield),1),1).*2; 
else
    for i = 1:size(bulkparams.time,1)
        %build variable that compiles results of all qaqc tests for each time point
        dum = [];   
        
        for j = 1:length(fields)
            for jj = 1:length(qaqc_tests)            
                dum(jj,j) = bulkparams.([fields{j} '_' qaqc_tests{jj}])(i,1);
            end
        end
    
        
        %% determine cause for flag, and assign primary and secondary flags
        
        %for first data point, only rely on QARTOD 19 (range test) - all others require mulitple time points 
        if i == 1
            test19 = find(strcmp(qaqc_tests,'19')==1); 
            if dum(test19)==1
                primary_flag(i,1) = 1;
                sub_flag(i,1) = -127;
            elseif dum(test19)==4
                primary_flag(i,1) = 4; 
                sub_flag(i,1) = 4;
            end
        else 
            %check that at least one test is 3 or 4
            if any(dum==3)|any(dum==4)
                didx = find(dum==max(dum));                 
                if length(didx)>1
                    didx = didx(end);
                end
                
                if didx==1                  
                    sub_flag(i,1) = 2; %mean+/- std
                    primary_flag(i,1) = dum(didx); 
                elseif didx==2
                    sub_flag(i,1) = 3; %flat line
                    primary_flag(i,1) = dum(didx); 
                elseif didx==3
                    sub_flag(i,1) = 4; %range
                    primary_flag(i,1) = dum(didx); 
                elseif didx==4
                    sub_flag(i,1) = 5; %rate of change
                    primary_flag(i,1) = dum(didx); 
                elseif didx==5
                    sub_flag(i,1) = 6; %spike 
                    primary_flag(i,1) = dum(didx); 
                end
            else
                primary_flag(i,1) = 1;
                sub_flag(i,1) = -127; 
            end
        end
    end
end





        
        
        
        
            

        
        
        
    
      



    
            
            





    
        




