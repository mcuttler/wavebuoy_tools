%% check buoy location and time since last data, send alert email if outside limits

function [warning] = spotter_buoy_volt_humid_alert(buoy_info, data); 


% threshholds for a warning being sent - hard code, but could be added to
% buoys_metadata.csv 
V_min = 3.8; %Spotter battery is 3.7 V
Humid_max = 80; 

%calculate trend in Voltage and humidity over last week
system_data = array2timetable([data.humidity, data.batteryVoltage],'RowTimes',datetime(data.systime,'convertfrom','datenum'),'VariableNames',{'humidity','voltage'}); 
tr = timerange(system_data.Time(end)-days(7), system_data.Time(end)); 
system_data = system_data(tr,:); 

dV = fitlm(system_data.Time

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
