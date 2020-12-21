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
%-----------------------------------------------------------------------------------------------------------------------------------------
%     M. Cuttler     | 21 Dec 2020 | 1.1                      | Modify so%     that runs for individual parameters and tolerance 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function [QCFlag] = qartod_16_flat_line(in, tol,data)
%% initial check that length of data is long enough for this test

if length(data)>=in.rep_suspect
    % first check for 'suspect' values
    QCFlag_suspect  = zeros(size(data,1),1); 
    %start at in.rep_suspect or in.rep_fail, assume all preceding points get
    %that flag
    for ii=in.rep_suspect:length(data)        
        if ii<=in.rep_suspect
            QCFlag_suspect(ii,:) = 2; 
        else
            check_data = diff(data(ii-in.rep_suspect:ii));            
            QCFlag_suspect(ii,1) = check_suspect(check_data, tol);             
        end
    end
    
    %% now check for fail values
    QCFlag_fail  = zeros(size(data,1),1); 
    %
    for ii=in.rep_fail:length(data)
        %check if first n values are 'equal' within tolerance
         if ii<=in.rep_fail
             %not assessed
             QCFlag_fail(ii,:) = 2;            
        else
            check_data = diff(data(ii-in.rep_fail:ii));                                
            QCFlag_fail(ii,1) = check_fail(check_data, tol);                
        end
    end
    
    %% now compare values for fail/suspect and keep higher one
    for ii = 1:length(data)
        QCFlag(ii,1) = compare_qcflag(QCFlag_suspect(ii,1), QCFlag_fail(ii,1)); 
    end   
    
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


  

         
        
            
            
        
        
        
    
    





