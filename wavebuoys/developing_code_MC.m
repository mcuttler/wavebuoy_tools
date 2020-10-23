%% Code that holds snippets of code not being used

%%  random codes for future QARTOD QA/QC test
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% QARTOD TEST 17 - LT time series operational frequency range

% NOT USED BECAUSE TESTING BULK PARAMETERS - 
% DO NOT HAVE OPERATIONAL FREQUENCY RANGE INFORMATION

% [bulkparams.qf17] = qartod_17_operational_frequency(check);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%  QARTOD TEST 18 - LT Time series Low-Frequency Energy 

% NOT USED BECAUSE TESTING BULK PARAMETERS - 
% DO NOT HAVE OPERATIONAL FREQUENCY RANGE INFORMATION

% [bulkparams.qf18] = qartod_18_low_frequency(check); 
%%

  for ii = 1:size(in.time,1)    
        tnow = in.time(ii);
        tstart = in.time(ii) - datenum(0,0,0,in.time_window, 0,0); 
        tend = in.time(ii) + datenum(0,0,0,in.time_window, 0,0); 
        
        if tstart>= in.time(1) & tend<=in.time(end)
            idx = find(in.time>=tstart & in.time<=tend);
            
            fields = {'WVHGT','WVPD','WVDIR','WVSP'};
            for j = 1:length(fields)                
                dumdata = in.(fields{j});                      
                ddata = dumdata(idx); 
                M = nanmean(ddata); 
                Mhi = M+(in.STD*nanstd(ddata));
                Mlow = M-(in.STD*nanstd(ddata));
                
                if dumdata(ii)>Mhi | dumdata(ii)<Mlow
                    QCFlag(ii,j) = 3;
                end
                clear dumdata ddata M Mhi Mlow
            end
        else
            %not assessed
            QCFlag(ii,:) = -1; 
        end
    end
               
       
        

