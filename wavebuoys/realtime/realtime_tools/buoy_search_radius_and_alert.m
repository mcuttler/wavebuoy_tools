%% check buoy location and time since last data, send alert email if outside limits

function [warning] = buoy_search_radius_and_alert(buoy_info)

%buoy time warning 
in_cut=buoy_info.time_cutoff; %hours

dev_loc = [buoy_info.DeployLat, buoy_info.DeployLon]; %lat lon location of development site buou
[xdev_dep,ydev_dep]=gda94ll2utm(dev_loc(1),dev_loc(2));
dev_watch=buoy_info.search_rad; %warning distance for offshore buoy, in m
%watch radius for 30 m depth is 178 m per http://cdip.ucsd.edu/documents/index/gauge_docs/buoy_watch_circle.pdf

c=datenum(clock)-8/24; %get current time and convert to UTC
dd=datevec(c); %date vec format

yr=num2str(dd(1));
mm=num2str(dd(2));
if dd(2)<10
    mm=['0' mm];
end

dirI=[buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' yr '\' mm '\'];


%% devlopment site buoy
%in event data from first of month is not written, acess previous months
%data
try
   dev=load([dirI buoy_info.datawell_name '{0xF80}' yr '-' mm '.csv']);
catch
    mm=num2str(dd(2)-1);
    if dd(2)-1<10
        mm=['0' mm];
    end
    dirI=[buoy_info.datawell_datapath '\' buoy_info.datawell_name '\' yr '\' mm '\'];
    dev=load([dirI buoy_info.datawell_name '{0xF80}' yr '-' mm '.csv']);
end

time_dev=(dev(end,1)/86400)+datenum([1970 1 1]); %timestap is seconds from Jan 1 1970

%latitude and longitude
lat_dev=dev(end,3)*180/pi;
long_dev=dev(end,4)*180/pi;

%convert to UTM
[xdev,ydev,zn]=gda94ll2utm(lat_dev,long_dev);

%calculate distance from deployment location
dist_dev=sqrt((xdev-xdev_dep)^2+(ydev-ydev_dep)^2);

if c-time_dev>in_cut/24 %if time difference greater than cutoff, development site
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
    dt=(c-time_dev)*24;
    %send email
    sendmail('jeff.hansen@uwa.edu.au',['Development site buoy data >' num2str(in_cut) ' hrs old'],['Development site buoy data last reported ' num2str(dt) '  hrs ago']) ;
    sendmail('michael.cuttler@uwa.edu.au',['Development site buoy data >' num2str(in_cut) ' hrs old'],['Development site buoy data last reported ' num2str(dt) '  hrs ago']) ;
    sendmail('carlin.alerts@outlook.com.au',['Development site buoy data >' num2str(in_cut) ' hrs old'],['Development site buoy data last reported ' num2str(dt) '  hrs ago']) ;
    sendmail('matt.hatcher@uwa.edu.au',['Development site buoy data >' num2str(in_cut) ' hrs old'],['Development site buoy data last reported ' num2str(dt) '  hrs ago']) ;
    sendmail('ronni.king@uwa.edu.au',['Development site buoy data >' num2str(in_cut) ' hrs old'],['Development site buoy data last reported ' num2str(dt) '  hrs ago']) ;
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
    sendmail('ronni.king@uwa.edu.au',mail_title, mail_message);
else
    warning.gps = 0; 
end
