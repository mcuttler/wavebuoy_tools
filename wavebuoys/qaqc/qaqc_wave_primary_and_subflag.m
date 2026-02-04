%% qaqc subflag
% This code determines the 'reason' that data received the primary qa flag
% Only determines reason for bad or questionable data (primary flag of 4 or 3)

function [primary_flag, sub_flag] = qaqc_wave_primary_and_subflag(bulkparams, fields, qaqc_tests) 


for i = 1:size(bulkparams.time,1)
	%% build variable that compiles results of all qaqc tests for each time point
	% matrix is [r, c] = [tests, parameters] 
    dum = [];        
    for j = 1:length(fields)
        for jj = 1:length(qaqc_tests)                        
            dum(jj,j) = bulkparams.([fields{j} '_' qaqc_tests{jj}])(i,1);
        end
    end
    
    %% determine cause for flag, and assign primary and secondary flags
    
    %for first data point, only rely on QARTOD 19 (range test) - all others
    %require mulitple time points 
    if i == 1
        test19 = find(contains(qaqc_tests,'range')==1); 
        if sum(dum(test19,:))==length(fields) %everything is a value of 1 (pass)
            primary_flag(i,1)=1; 
            sub_flag(i,1) = -127; 
        else %something not 1, so figure out which was outside range 
            check_idx = find(dum(test19,:)==max(dum(test19,:))); 
            if length(check_idx)>1
                check_idx = check_idx(1);
            end
            
            primary_flag(i,1) = dum(test19,check_idx(1)); 
            %build new matrix to check which one failed 
            if contains(fields{check_idx},'h')
                sub_flag(i,1) = 16; %hs
            elseif contains(fields{check_idx},'t')
                sub_flag(i,1) = 17; %tp
            elseif contains(fields{check_idx},'d')
                sub_flag(i,1) = 18; %dp            
            end                       
        end
    else
		
        dd = max(dum,[],2); %find max value in each row to determine which test has 'worst' fail/suspect 
        didx = find(dd==max(dd)); %find the test that has most fails 
        if length(didx)>1           
            didx = didx(end);%assigns to last test, this could probably be better 
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

%finish by over-writing the above based on the watch circle 
primary_flag(bulkparams.qc_flag_watch>=3) = bulkparams.qc_flag_watch(bulkparams.qc_flag_watch>=3); 
sub_flag(bulkparams.qc_flag_watch>=3) = 37; 
end
    

%% subfunction for assigning subflag 
function [subflag] = qaqc_assign_subflag(errors, flag_range)

flag_idx = find(errors==max(errors)); 

if length(flag_idx)==1 %hs, tp or dp
    subflag = flag_range(flag_idx); 
elseif length(flag_idx)==2
    if flag_idx==[1 2] %hs, tp
        subflag = flag_range(4); 
    elseif flag_idx==[1 3] %hs, dp
        subflag = flag_range(5); 
    elseif flag_idx==[2 3] %tp, dp
        subflag = flag_range(6); 
    end
elseif length(flag_idx)==3 %hs, tp, dp
    subflag=flag_range(7);
end

end



        
        
        
        
            

        
        
        
    
      



    
            
            





    
        




