%% Quick convert GPS epoch time to a datenum. For checking times in raw Sofar files

%% Matt Hatcher: Written 2021 - 04 - 09 
 

%%
function [out] = GPSepoch_to_date(in)

out = datetime(in,'ConvertFrom','epochtime','Epoch','1970-01-01');


end
