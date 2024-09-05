%% check buoy location and time since last data, send alert email if outside limits

function [warning] = spotter_get_data_fail_warning(buoy_info)


    %set up email details
    warning = 1; 
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
    mail_title = [buoy_info.name ' - no new data in >12 hours'];
    mail_message = [buoy_info.name ' - unable to retrieve new data from last 12 hours via Sofar API']; 
    
    sendmail('jeff.hansen@uwa.edu.au',mail_title,mail_message) ;
    sendmail('michael.cuttler@uwa.edu.au', mail_title, mail_message) ;
    sendmail('carlin.alerts@outlook.com.au', mail_title, mail_message) ;
    sendmail('matt.hatcher@uwa.edu.au', mail_title, mail_message) ;
    sendmail('ronni.king@uwa.edu.au', mail_title, mail_message) ;

end
