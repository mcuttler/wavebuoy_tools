%% check buoy location and time since last data, send alert email if outside limits

function [warning] = spotter_buoy_volt_humid_alert(buoy_info)

% threshholds for a warning being sent:
V_min = buoy_info.V_min;
Humid_max = buoy_info.Humid_max; 

% Retreive buoy latest data point 
% Accesses Spoondrift API to get most recent data from specified Spotter
% SpotterID is string of Spotter name - i.e. 'SPOT-0093'
% AQL token: a1b3c0dbaa16bb21d5f0befcbcca51

import matlab.net.*
import matlab.net.http.*
header = matlab.net.http.HeaderField('token',buoy_info.sofar_token,'spotterId',buoy_info.serial);
r = RequestMessage('GET', header);

%get data
uri = URI(['https://api.sofarocean.com/api/latest-data?spotterId=' buoy_info.serial]);

resp = send(r,uri);
status = resp.StatusCode;

disp('Get Volt and Humid from API status - ')
disp(status);

V=resp.Body.Data.data.batteryVoltage(end);
Humid = resp.Body.Data.data.humidity(end);

if V < V_min % If voltage below voltage min warning   
    %set up email details
    warning.volts = 1; 
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
    
    %send email
    mail_title = [buoy_info.name ' buoy voltage = ' num2str(V)];
    mail_message = [buoy_info.name ' buoy voltage = ' num2str(V)]; 
    
    sendmail('jeff.hansen@uwa.edu.au',mail_title,mail_message) ;
    sendmail('michael.cuttler@uwa.edu.au', mail_title, mail_message) ;
    sendmail('carlin.alerts@outlook.com.au', mail_title, mail_message) ;
    sendmail('matt.hatcher@uwa.edu.au', mail_title, mail_message) ;
    sendmail('ronni.king@uwa.edu.au', mail_title, mail_message) ;
else
    warning.volts = 0; 
end


% 
if Humid > Humid_max %If humidity is above set threshhold for warning email
    %set up email details
    warning.humid = 1; 
    setpref('Internet','SMTP_Server','smtp.gmail.com');
    setpref('Internet','E_mail','wa.wavebuoy.alert@gmail.com');
    setpref('Internet','SMTP_Username','wa.wavebuoy.alert');
    setpref('Internet','SMTP_Password','rvwqxkuaiaqfarht');
    props = java.lang.System.getProperties;
    props.setProperty('mail.smtp.auth','true');
    props.setProperty('mail.smtp.socketFactory.class', 'javax.net.ssl.SSLSocketFactory');
    props.setProperty('mail.smtp.socketFactory.port','465');
    
    %send email
    mail_title = [buoy_info.name ' buoy high humidity']; 
    mail_message = [buoy_info.name ' buoy humidity =' num2str(Humid)]; 
    
    sendmail('jeff.hansen@uwa.edu.au',mail_title, mail_message);
    sendmail('carlin.alerts@outlook.com.au',mail_title, mail_message);
    sendmail('michael.cuttler@uwa.edu.au',mail_title, mail_message);
    sendmail('matt.hatcher@uwa.edu.au',mail_title, mail_message);
    sendmail('ronni.king@uwa.edu.au', mail_title, mail_message) ;
else
    warning.humid = 0; 
end
