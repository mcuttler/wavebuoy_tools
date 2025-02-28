%% check buoy location and time since last data, send alert email if outside limits

function [warning] = spotter_buoy_search_radius_and_alert(buoy_info, SpotData)

%buoy time warning 
in_cut=buoy_info.time_cutoff; %hours

dev_watch=buoy_info.search_rad; %warning distance for offshore buoy, in m

%lat lon location of development site buou
dev_loc = [buoy_info.DeployLat, buoy_info.DeployLon]; 

%most recent latitude and longitude
lat_dev=SpotData.lat(end); 
long_dev=SpotData.lon(end);

%convert to UTM - old 
% [xdev_dep,ydev_dep]=gda94ll2utm(dev_loc(1),dev_loc(2));
% [xdev,ydev,zn]=gda94ll2utm(lat_dev,long_dev);
%calculate distance from deployment location
% dist_dev=sqrt((xdev-xdev_dep)^2+(ydev-ydev_dep)^2);

%new way using mapping toolbox
wgs84 = wgs84Ellipsoid("m");
dist_dev = distance(dev_loc(1), dev_loc(2), lat_dev(1), long_dev(2),wgs84); 

tnow = datenum(now) - (8/24);  %current time in UTC

if tnow - SpotData.time(end) > in_cut/24 %if time difference greater than cutoff, development site
    %set up email details
    warning.time = 1; 
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','E_mail','wa.wavebuoy.alert@gmail.com');
    setpref('Internet','SMTP_Username','wa.wavebuoy.alert');
    %ADD PASSCODE: rvwqxkuaiaqfarht
    %Or password: UWAwavebuoys1
    setpref('Internet','SMTP_Password','rvwqxkuaiaqfarht');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    %calculate time diff
    dt=(tnow-SpotData.time(end))*24;
    %send email
    mail_title = [buoy_info.name ' buoy data >' num2str(in_cut) ' hrs old'];
    mail_message = [buoy_info.name ' buoy data last reported ' num2str(dt) '  hrs ago']; 
    
    if isfield(buoy_info,'alert_emails')
        alert_emails = strsplit(buoy_info.alert_emails,';'); 
        for aa = 1:length(alert_emails)
            sendmail(strrep(alert_emails{aa},' ',''), mail_title, mail_message); 
        end
    else        
        sendmail('jeff.hansen@uwa.edu.au',mail_title,mail_message) ;
        sendmail('michael.cuttler@uwa.edu.au', mail_title, mail_message) ;
        sendmail('carlin.alerts@outlook.com.au', mail_title, mail_message) ;
        sendmail('matt.hatcher@uwa.edu.au', mail_title, mail_message) ;
        sendmail('ronni.king@uwa.edu.au', mail_title, mail_message) ;
    end
else
    warning.time = 0; 
end
% 
if dist_dev>dev_watch %if development site buoy offsite
    %set up email details
    warning.gps = 1; 
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','E_mail','wa.wavebuoy.alert@gmail.com');
    setpref('Internet','SMTP_Username','wa.wavebuoy.alert');
    setpref('Internet','SMTP_Password','rvwqxkuaiaqfarht');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    %send email
    mail_title = [buoy_info.name ' buoy out of radius']; 
    mail_message = [buoy_info.name ' buoy is ' num2str(dist_dev) ' m from deployment location. '...
        'Current position is Lat=' num2str(lat_dev,9) ' Long=' num2str(long_dev,9) '.']; 
    
    sendmail('jeff.hansen@uwa.edu.au',mail_title, mail_message);
    sendmail('carlin.alerts@outlook.com.au',mail_title, mail_message);
    sendmail('michael.cuttler@uwa.edu.au',mail_title, mail_message);
    sendmail('matt.hatcher@uwa.edu.au',mail_title, mail_message);
    sendmail('ronni.king@uwa.edu.au', mail_title, mail_message) ;
else
    warning.gps = 0; 
end
