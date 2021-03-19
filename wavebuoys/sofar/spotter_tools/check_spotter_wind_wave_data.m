function [SpotData] = check_spotter_wind_wave_data(data_in)
[m,~] = size(data_in.hsig); 
[n,~] = size(data_in.wind_dir); 
if m~=n  
    if n>m %missing waves
        data = data_in; 
        fields = {'hsig';'tp';'tm';'dp';'dpspr';'dm';'dmspr';'lat';'lon'}; 
        for jj = 1:length(fields); 
            data.(fields{jj}) = ones(size(data_in.time,1),1).*nan; 
        end
        data.time = data_in.wind_time;
        for j = 1:n
            dum = find(data_in.time==data_in.wind_time(j)); 
            if isempty(dum)
                data.serialID{j,1} = buoy_info.serial;                 
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = nan;
                end
            else
                data.serialID{j,1} = buoy_info.serial;
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = data_in.(fields{jj})(dum,1);
                end
            end
        end
        fields = {'time';'serialID';'hsig';'tp';'tm';'dp';'dpspr';'dm';'dmspr';'lat';'lon'};
        for jj = 1:length(fields)
            data_in.(fields{jj}) = data.(fields{jj}); 
        end
        
    elseif m>n %missing wind
        data = data_in; 
        fields = {'wind_speed';'wind_dir';'wind_seasurfaceId'};
        for jj = 1:length(fields); 
            data.(fields{jj}) = ones(size(data_in.time,1),1).*nan; 
        end
        data.wind_time = data_in.time;
        for j = 1:m
            dum = find(data_in.wind_time==data_in.time(j)); 
            if isempty(dum)                                
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = nan;
                end
            elseif length(dum)>1
                if data_in.(fields{jj})(dum(1))==data_in.(fields{jj})(dum(2))
                    data.(fields{jj})(j,1) = data_in.(fields{jj})(dum(1)); 
                else
                    data.(fields{jj})(j,1) = nanmean(data_in.(fields{jj})(dum));
                end
            else
                for jj = 1:length(fields)
                    data.(fields{jj})(j,1) = data_in.(fields{jj})(dum,1);
                end
            end
        end
        fields = {'wind_time';'wind_speed';'wind_dir';'wind_seasurfaceId'};
        for jj = 1:length(fields)
            data_in.(fields{jj}) = data.(fields{jj}); 
        end
    end
else
    SpotData = data_in; 
end