%%  Apply QARTOD QA/QC 
%    
% Function to do QARTOD Time series flat line test (Test 16) -
% 
%   See QARTOD manual for further details
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%   inputs:
% 
% in.time - time vector : datenum format
% in.WVHGT - timeseries wave height : WVHGT
% in.WVPD - timeseries wave period : WVPD
% in.WVDIR - timeseries wave direction : WVDIR
% in.WVSP - timeseries wave spreading : WVSP

%    User defined test criteria
% in.WHTOL - wave height tolerance 
% in.WPTOL - period tolerance 
% in.WDTOL - directional tolerance 
% in.WSPTOL - spreading tolerance
% in.rep_fail - number of previous time poins to compare for fail
% in.rep_fail - number of previous time poins to compare for suspect


%
%     Outputs:
% out1 - QC test flag of same length of time vector. values 1,3,4. 
%        1 = pass (see Qartod manual
%        "QARTOD-IOOS_Manual_for_Real-Time_Quality_Control_of_Waves_v2.1.pdf"
%        3 = suspect
%        4 = fail 
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Example usage
% 
%           [QCFlag] = qartod_15_flat_line(in)
%     
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
% Code history
% 
%     Author          | Date             | Script Version     | Update
%     --------------------------------------------------------
%     M. Cuttler     | 09 Oct 2020 | 1.0                      | Initial creation
% --------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 09 Oct 2020 | 1.1                      | Modify so that code starts with first point that at 'suspect' or 'fail' limit and assumes all points up to that have the same flag

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qartod_16_flat_line(in)
%% initial check that length of data is long enough for this test
if length(in.WVHGT)>=in.rep_suspect
    %% first check for 'suspect' values
    %check ea   QCFlag_suspect  = zeros(length(in.WVHGT),4);ch input variable and then at end keep highest QC flat
 
    
    %start at in.rep_suspect or in.rep_fail, assume all preceding points get
    %that flag
    for ii=in.rep_suspect:length(in.WVHGT)
        
        if ii==in.rep_suspect
            checkWVHGT = diff(in.WVHGT(1:ii));  
            checkWVPD = diff(in.WVPD(1:ii)); 
            checkWVDIR = diff(in.WVDIR(1:ii)); 
            checkWVSP = diff(in.WVSP(1:ii));                              
            
            QCFlag_suspect(ii,1) = check_suspect(checkWVHGT, in.WHTOL); 
            QCFlag_suspect(1:ii-1,1) = QCFlag_suspect(ii,1); 
            QCFlag_suspect(ii,2) = check_suspect(checkWVPD, in.WPTOL); 
            QCFlag_suspect(1:ii-1,2) = QCFlag_suspect(ii,2); 
            QCFlag_suspect(ii,3) = check_suspect(checkWVDIR, in.WDTOL); 
            QCFlag_suspect(1:ii-1,2) = QCFlag_suspect(ii,3); 
            QCFlag_suspect(ii,4) = check_suspect(checkWVSP, in.WSPTOL);         
            QCFlag_suspect(1:ii-1,2) = QCFlag_suspect(ii,4); 
            
        else
            
            checkWVHGT = diff(in.WVHGT(ii-in.rep_suspect:ii));
            checkWVPD = diff(in.WVPD(ii-in.rep_suspect:ii)); 
            checkWVDIR = diff(in.WVDIR(ii-in.rep_suspect:ii)); 
            checkWVSP = diff(in.WVSP(ii-in.rep_suspect:ii));                                
            
            QCFlag_suspect(ii,1) = check_suspect(checkWVHGT, in.WHTOL); 
            QCFlag_suspect(ii,2) = check_suspect(checkWVPD, in.WPTOL); 
            QCFlag_suspect(ii,3) = check_suspect(checkWVDIR, in.WDTOL); 
            QCFlag_suspect(ii,4) = check_suspect(checkWVSP, in.WSPTOL); 
            
        end
    end
    
    %% now check for fail values
    QCFlag_fail  = zeros(length(in.WVHGT),4);
    %
    for ii=in.rep_fail:length(in.WVHGT)
        %check if first n values are 'equal' within tolerance
         if ii==in.rep_fail
            checkWVHGT = diff(in.WVHGT(1:ii)); 
            checkWVPD = diff(in.WVPD(1:ii)); 
            checkWVDIR = diff(in.WVDIR(1:ii)); 
            checkWVSP = diff(in.WVSP(1:ii));       
            
            QCFlag_fail(ii,1) = check_fail(checkWVHGT, in.WHTOL); 
            QCFlag_fail(1:ii,1) = QCFlag_fail(ii,1); 
            QCFlag_fail(ii,2) = check_fail(checkWVPD, in.WPTOL); 
            QCFlag_fail(1:ii,2) = QCFlag_fail(ii,2); 
            QCFlag_fail(ii,3) = check_fail(checkWVDIR, in.WDTOL); 
            QCFlag_fail(1:ii,3) = QCFlag_fail(ii,3); 
            QCFlag_fail(ii,4) = check_fail(checkWVSP, in.WSPTOL); ;       
            QCFlag_fail(1:ii,4) = QCFlag_fail(ii,4); 
            
        else
            checkWVHGT = diff(in.WVHGT(ii-in.rep_fail:ii));
            checkWVPD = diff(in.WVPD(ii-in.rep_fail:ii)); 
            checkWVDIR = diff(in.WVDIR(ii-in.rep_fail:ii)); 
            checkWVSP = diff(in.WVSP(ii-in.rep_fail:ii));                        
            
            QCFlag_fail(ii,1) = check_fail(checkWVHGT, in.WHTOL); 
            QCFlag_fail(ii,2) = check_fail(checkWVPD, in.WPTOL); 
            QCFlag_fail(ii,3) = check_fail(checkWVDIR, in.WDTOL); 
            QCFlag_fail(ii,4) = check_fail(checkWVSP, in.WSPTOL);       
            
        end
    end
    
    %% now compare values for fail/suspect and keep higher one
    for ii = 1:length(in.WVHGT)
        for jj = 1:size(QCFlag_fail,2)
            QCFlag_tmp(ii,jj) = compare_qcflag(QCFlag_suspect(ii,jj), QCFlag_fail(ii,jj)); 
        end
    end
    
    QCFlag = max(QCFlag_tmp,[],2);
else
    disp('Dataset not long enough for FLATLINE TEST'); 
    QCFlag = ones(length(in.WVHGT),1).*nan;
end

%% subfunctions
function [suspect] = check_suspect(check_suspect, lim_sus)
    if all(abs(check_suspect)<lim_sus)
        suspect = 3; 
    else
        suspect = 1;
    end
end


function [fail] = check_fail(check_fail, lim_fail)
    if all(abs(check_fail)<lim_fail)
        fail = 4; 
    else
        fail = 1;
    end
end

function [keep_val] = compare_qcflag(qc_sus, qc_fail)

    if qc_sus==qc_fail
        keep_val = 1;
    elseif qc_sus<qc_fail
        keep_val = qc_fail;
    elseif qc_sus>qc_fail
        keep_val = qc_sus;
    end
end

end


  

         
        
            
            
        
        
        
    
    





