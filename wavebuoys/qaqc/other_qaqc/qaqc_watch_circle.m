%% Watch Circle QC test
% Check final processed data for inside/outside watch circle
%Use mooring measurements to calculate initial watch circle. If this cuts
%too much data (defined in metadata), then increase watch circle using some
%assumptions defined by user. 
%Remaining data that is outside this adjusted circle is then further
%analysed to determine whether suspect or fail
    % suspect when data is greater than adjusted watch circle, but less than 'buoy_info.watch_circle_fail' * adjusted watch circle
    % fail when data is greater than 'buoy_info.watch_circle_fail' * adjusted watch circle 


    function [data,watch_circle_flag, buoy_info] = qaqc_watch_circle(buoy_info, data)
%% first calculate watch circle using stretch factor and assumed GPS error
%get mainline (should include any chain at bottom) + some stretch factor 
mainline = buoy_info.mainline_length + (buoy_info.mainline_length*buoy_info.mooring_stretch_factor); 
%get catenary
catenary = buoy_info.catenary_length + (buoy_info.catenary_length*buoy_info.mooring_stretch_factor); 

%calculate watch circle
buoy_info.watch_circle = sqrt( mainline^2 - buoy_info.DeployDepth^2) + catenary + buoy_info.watch_circle_gps_error;

%use mapping toolbox distance function to calculate points outside watch_circle
clear dum_distance
wgs84 = wgs84Ellipsoid("m");
for i = 1:size(data.time,1)     
    if data.lat(i) > -180
        dum_distance(i,1) = distance(buoy_info.DeployLat, buoy_info.DeployLon, data.lat(i), data.lon(i),wgs84); 
    else
        dum_distance(i,1) = nan; 
    end
end

ind = find(dum_distance > buoy_info.watch_circle);  

% Mh adds below 4 lines to bring watch subtest circle flag out of function
 ind2 = find(dum_distance > buoy_info.watch_circle*buoy_info.watch_circle_fail);
 data.qc_flag_watch = ones(size(data.time,1),2); % Make subflag results
 data.qc_flag_watch(ind,1)=3; %write flag 3 (4's will be overwritten later where appropriate in next line)
 data.qc_flag_watch(ind2,1)=4;

%check how much data this is
out_of_radius = (size(ind,1)/size(dum_distance,1))*100; 

%% if too much out of radius, try to re-calculate with some more assumptions (mooring build slop)
if out_of_radius >= buoy_info.out_of_radius_tolerance            
    %get mainline length from metadata, include error for slop in mooring build
    mainline = buoy_info.mainline_length+buoy_info.mainline_length_error; 
    %get mainline length from metadata, include error for slop in mooring build
    catenary = buoy_info.catenary_length+buoy_info.catenary_length_error; 
    
    %account for stretch factor to give a bit extra in watch circle 
    mainline = mainline + (mainline * buoy_info.mooring_stretch_factor); 
    catenary = catenary + (catenary * buoy_info.mooring_stretch_factor); 
    %calculate watch circle, and add extra error for GPS uncertainty 
    buoy_info.watch_circle =  sqrt( mainline^2 - buoy_info.DeployDepth^2) + catenary + buoy_info.watch_circle_gps_error;            
    
    clear dum_distance ind ind2 out_of_radius
    for i = 1:size(data.time,1)            
        if data.lat(i) > -180
            dum_distance(i,1) = distance(buoy_info.DeployLat, buoy_info.DeployLon, data.lat(i), data.lon(i),wgs84); 
        else
            dum_distance(i,1) = nan; 
        end
    end        
    
    %calculate percentage of data outside of watch circle
    ind = find(dum_distance > buoy_info.watch_circle); 

    % don't need 'ind2' and updating the flags should be done at the end,
    % however matt adds below 3 lines for testing 
    ind2 = find(dum_distance > buoy_info.watch_circle*buoy_info.watch_circle_fail);
    data.qc_flag_watch(ind,2)=3; %write flag 3 (4's will be overwritten later where appropriate in next line)
    data.qc_flag_watch(ind2,2)=4;

    out_of_radius = (size(ind,1)/size(dum_distance,1)) * 100;     

    if out_of_radius > buoy_info.out_of_radius_tolerance
        watch_circle_flag = 1;
    else
        watch_circle_flag = 0;
    end
else
    watch_circle_flag=0;
end

%% set qc flags
if ~isempty(ind)
    data.qc_subflag_wave(ind,1) = 37; %hard coded from wave_subflag_mapping.csv 
    
    %determine suspect or fail based on distance outside watch circle
    data.qc_flag_wave(dum_distance > buoy_info.watch_circle,1) = 3; 
    % overwrite any suspect in previous line that are bigger than threshold 
    data.qc_flag_wave(dum_distance > buoy_info.watch_circle*buoy_info.watch_circle_fail,1) = 4; 
end

end


        
    


