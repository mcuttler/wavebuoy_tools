%% process archived temp/surface current data

function [temp_curr] = process_realtime_temp_curr_data(TC, time, temp_curr)
%only keep select columns (see Datawell manual pg 37), note, column values
%in variable 'data82' are off by 3 compared to manual as columns 1-3 get
%stored in data82.textdata when imported        
[m,~] = size(TC);

for ii = 1:m
    %4 - current speed (m/s)        
    temp_curr.curr_mag= [temp_curr.curr_mag;TC(ii,1)];
    %5 - direction to (rad)
    temp_curr.curr_dir= [temp_curr.curr_dir; rad2deg(TC(ii,2))];
    %6 - std of speed (m/s)
    temp_curr.curr_mag_std = [temp_curr.curr_mag_std;TC(ii,3)];
    %7 - std (direction to (rad)
    temp_curr.curr_dir_std = [temp_curr.curr_dir_std;rad2deg(TC(ii,4))];
    %11 - water temp (K)
    temp_curr.T = [temp_curr.T; TC(ii,8)];
    %13 - vertical velocity (m/s)
    temp_curr.w = [temp_curr.w; TC(ii,10)];
    %14 - std of veritcal velocity (m/s)
    temp_curr.w_std = [temp_curr.w_std; TC(ii,11)];
    temp_curr.timecurr = [temp_curr.timecurr; time(ii,1)];
end


end
