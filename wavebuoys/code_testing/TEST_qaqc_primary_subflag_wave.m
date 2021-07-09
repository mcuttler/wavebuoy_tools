%% Testing QAQC primary/subflag assignment 

for i = 1:size(bulkparams.time,1)
%build variable that compiles results of all qaqc tests for each time point
    dum = [];   
    
    for j = 1:length(fields)
        for jj = 1:length(qaqc_tests)            
            if jj==3
                if j == bulkparams.(['qf_' qaqc_tests{jj}])(i,2)                
                    dum(jj,j) = bulkparams.(['qf_' qaqc_tests{jj}])(i,1);
                else
                    dum(jj,j) = 1; 
                end
            else
                dum(jj,j) = bulkparams.([fields{j} '_' qaqc_tests{jj}])(i,1);
            end
        end
    end
    
    %% determine cause for flag, and assign primary and secondary flags
    
    %for first data point, only rely on QARTOD 19 (range test) - all others
    %require mulitple time points 
    if i == 1
        test19 = find(strcmp(qaqc_tests,'19')==1); 
        if sum(dum(test19,:))==length(fields); 
            primary_flag(i,1)=1; 
            sub_flag(i,1) = -127; 
        else
            check_idx = find(dum(test19,:)==max(dum(test19,:))); 
            primary_flag(i,1) = dum(test19,check_idx(1)); 
            %look at second column for test 19 to determine cause
            if bulkparams.qf_19(i,2)==1
                sub_flag(i,1) = 16; %hs
            elseif bulkparams.qf_19(i,2)==2
                sub_flag(i,1) = 17; %tp
            elseif bulkparams.qf_19(i,3) ==3
                sub_flag(i,1) = 18; %dp
            end                       
        end
    else
        dd = sum(dum,2); 
        didx = find(dd==max(dd)); 
        if length(didx)>1
            didx = didx(end);
        end
        
        %double check that at least one test is 3 or 4
        if any(dum(didx,:)==3) | any(dum(didx,:)==4)        
            %subflag_options = [hs, tp, dp, hs+tp, hs+dp, tp+dp, hs+tp+dp]; 
            if didx==1
                flag_range = [2:8]; %mean +- std
                sub_flag(i,1) = qaqc_assign_subflag(dum(didx,:), flag_range); 
                primary_flag(i,1) = max(dum(didx,:));
            elseif didx==2
                flag_range = [9:15]; %flatline
                sub_flag(i,1) = qaqc_assign_subflag(dum(didx,:), flag_range); 
                primary_flag(i,1) = max(dum(didx,:));
            elseif didx==3 % range test
                flag_range = [16:22]; 
                sub_flag(i,1) = qaqc_assign_subflag(dum(didx,:), flag_range); 
                primary_flag(i,1) = max(dum(didx,:));
            elseif didx==4 %rate of change
                flag_range = [23:29];                
                sub_flag(i,1) = qaqc_assign_subflag(dum(didx,:), flag_range); 
                primary_flag(i,1) = max(dum(didx,:));
            elseif didx==5
                flag_range = [30:36]; %spike
                sub_flag(i,1) = qaqc_assign_subflag(dum(didx,:), flag_range); 
                primary_flag(i,1) = max(dum(didx,:));
            end
        else
            primary_flag(i,1) = 1; 
            sub_flag(i,1) = -127; 
        end
    end
end