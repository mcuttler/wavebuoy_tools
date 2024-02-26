%% Calculate scope and plot for smart moorings 

%MC to add info 

%% read in bathy
%read in bathymetry - Geoscience Australia 250m resolution (2023)
bpath = 'C:\Users\00084142\Data\Australian Bathymetry and Topography 2023 250m';
bname = 'Australian_Bathymetry_and_Topography_2023_250m_MSL_cog.tif'; 
bfile= fullfile(bpath,bname); 
[bathy,binfo] = readgeoraster(bfile); 
bathy = double(bathy); 
[bathy_lat, bathy_lon] = geographicGrid(binfo); 

%crop bathy grid 
ind_lat = find(bathy_lat(:,1)<-15); 
ind_lon = find(bathy_lon(1,:)<125); 
bathy = bathy(ind_lat, ind_lon); 
bathy_lon = bathy_lon(ind_lat, ind_lon); 
bathy_lat = bathy_lat(ind_lat, ind_lon); 
clear ind_lat ind_lon 

%% optional: find closest point to deployment location 
%proposed deployment coordinates in decimal degrees
deploy_lat = -29.181600; 

deploy_lon = 114.862467; 

%find closest bathy point
ind_lat = find(abs(bathy_lat(:,1) - deploy_lat)==min(abs(bathy_lat(:,1) - deploy_lat))); 
ind_lon = find(abs(bathy_lon(1,:) - deploy_lon)==min(abs(bathy_lon(1,:) - deploy_lon))); 

%approximate depth - relative to MSL 
deploy_depth = bathy(ind_lat, ind_lon)*-1;%GA has bathy as negative, so make it positive for calculations below

% set up info about the mooring 
% clc; 
%define the deployment depth if not read from a bathymetry file above. This
%depth is relative to MSL. If you read your depth against a nautical chart
%(e.g., Navionics) it is most likely relative to LAT (lowest astronomical
%tide). To do a rough conversion of LAT to MSL, you need to add (increase
%your depth) by half of your tidal range. So, for example, if you have a
%proposed site that is 12m LAT and a tidal range of 3m, your depth MSL
%would be 13.5m. 
% deploy_depth = 9;
%length of line connecting surface float to surface temperature sensor
B = 1; %in meters

%length of smart mooring bottom section
C = 35; %in meters

%length of riser connecting bottom temperature sensor to anchor
D = 1; %in meters

%tidal range
tidal_range = 1; %in meters

%max swell height
hs = 4; %in meters 

%calculate scope
%(https://sofarocean.notion.site/Mooring-Design-and-Best-Practices-for-Smart-Mooring-6838d5d940114b968143d6196953e213#6e3c3fd8fb4641e784966e32dbe3ea24)
min_scope = (B+C+D)/(deploy_depth + (0.5*tidal_range)+hs); 
max_scope = (B+C+D)/(deploy_depth - (0.5*tidal_range)-hs); 

disp(['Depth MSL: ' num2str(deploy_depth)]);
disp(['Max Scope: ' num2str(max_scope)]); 
disp(['Min Scope: ' num2str(min_scope)]); 

%% plot a summary figure

% fid= figure;
% 
% %plot map with grid 
% ax(1) = subplot(121);
% pcolor(bathy_lon',bathy_lat',bathy'); shading interp; 
% c = colorbar; c.Label.String = 'depth-MSL [m]'; 
% clim([-50 0]); 
% set(gca,'xlim',[deploy_lon-1 deploy_lon+1],'ylim',[deploy_lat-1 deploy_lat+1]); 
% hold on; 
% plot(deploy_lon, deploy_lat,'r.','markersize',24); 
% 
% %plot schematic of mooring 
% ax(2) = subplot(122); 

% fid = figure; 
