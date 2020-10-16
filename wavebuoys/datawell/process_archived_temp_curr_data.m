%% process archived temp/surface current data

function [temp_curr] = process_archived_temp_curr_data(TC, time)
%only keep select columns (see Datawell manual pg 37), note, column values
%in variable 'data82' are off by 3 compared to manual as columns 1-3 get
%stored in data82.textdata when imported        
[m,~] = size(TC);

for ii = 1:m
    %4 - current speed (m/s)        
    temp_curr.curr_mag(ii,1) = TC(ii,1);
    %5 - direction to (rad)
    temp_curr.curr_dir(ii,1) = rad2deg(TC(ii,2));
    %6 - std of speed (m/s)
    temp_curr.curr_mag_std(ii,1) = TC(ii,3);
    %7 - std (direction to (rad)
    temp_curr.curr_dir_std(ii,1) = rad2deg(TC(ii,4));
    %11 - water temp (K)
    temp_curr.T(ii,1) = TC(ii,8);
    %13 - vertical velocity (m/s)
    temp_curr.w(ii,1) = TC(ii,10);
    %14 - std of veritcal velocity (m/s)
    temp_curr.w_std(ii,1) = TC(ii,11); 
    temp_curr.timecurr(ii,1) = time(ii,1); 
end


end
