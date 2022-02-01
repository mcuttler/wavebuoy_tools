%% Collect archived data
% rootdir = 'E:\waved\Dev_site';
% yrs = 2018:2019;
% mths = 1:12;
%%
function [archive, archive_dates, archive20, archive21, archive25, archive28, archive82, timewave, timecurr] = collect_archive_data(rootdir, yrs, mths);

cnt=1;
for ii = 1:numel(yrs)    
    for kk = 1:numel(mths)
        
        file20 = [rootdir '\' num2str(yrs(ii)) '\' num2str(mths(kk), '%02d') '\Dev_site{0xF20}' num2str(yrs(ii)) '-' num2str(mths(kk), '%02d') '.csv'];
        file21 = [rootdir '\' num2str(yrs(ii)) '\' num2str(mths(kk), '%02d') '\Dev_site{0xF21}' num2str(yrs(ii)) '-' num2str(mths(kk), '%02d') '.csv'];
        file25 = [rootdir '\' num2str(yrs(ii)) '\' num2str(mths(kk), '%02d') '\Dev_site{0xF25}' num2str(yrs(ii)) '-' num2str(mths(kk), '%02d') '.csv'];
        file28 = [rootdir '\' num2str(yrs(ii)) '\' num2str(mths(kk), '%02d') '\Dev_site{0xF28}' num2str(yrs(ii)) '-' num2str(mths(kk), '%02d') '.csv'];
        file82 = [rootdir '\' num2str(yrs(ii)) '\' num2str(mths(kk), '%02d') '\Dev_site{0xF82}' num2str(yrs(ii)) '-' num2str(mths(kk), '%02d') '.csv'];
        
        if exist(file20)
            disp(['Processing Month ' num2str(cnt)]);
            data20 = importdata(file20);
            data21 = importdata(file21);
            data25 = importdata(file25);
            data28 = importdata(file28);
            data82 = importdata(file82);                                           
        
                   
            RefTime = datenum(1970,01,01);
            %acquisition start time for temp/curr
            dumtime = datenum(yrs(ii),mths(kk),01):datenum(0,0,0,0,30,0):datenum(yrs(ii),mths(kk),eomday(yrs(ii),mths(kk)),23,30,0);
            
            %shift by 30 min to reflect Datawell timestamp (timestamp
            %corresponds to when data acquisition started); note,
            %temperature and surface current data is collect
            %'instantaneously' whereas wave data acquisition starts 30 min
            %prior to data transmission. Find wave data by data acquisition
            %start, but save data (line 94 by tranmission time)            
            dumtimewave = dumtime - datenum(0,0,0,0,30,0);
            
            
            time20 = (data20(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
            time21 = (data21(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
            time25 = (data25(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
            time28 = (data28(:,1).*(1/60).*(1/60).*(1/24))+RefTime;
            
            [m,~] = size(data82.data);
            for i = 1:m
                time82(i,1) = (str2num(data82.textdata{i,1}).*(1/60).*(1/60).*(1/24))+RefTime;
            end
            
            %create time variable of anticipated 30 min time steps for each
            %month
            out = [];
            out20 = [];
            out21 = [];
            out25 = [];
            out28 = [];
            out82 = [];
            out_timewave =[];
            out_timecurr = [];
            
            out(:,1) = dumtime;
            offset = datenum(0,0,0,0,5,0);
            
            for i = 1:length(out)
                dum20 = find(time20>=dumtimewave(i)-offset&time20<=dumtimewave(i)+offset, 1);
                dum21 = find(time21>=dumtimewave(i)-offset&time21<=dumtimewave(i)+offset,1);
                dum25 = find(time25>=dumtimewave(i)-offset&time25<=dumtimewave(i)+offset,1);
                dum28 = find(time28>=dumtimewave(i)-offset&time28<=dumtimewave(i)+offset,1);
                dum82 = find(time82>=dumtime(i)-offset&time82<=dumtime(i)+offset,1);
                
                if isempty(dum20)
                    out(i,2) = 0;
                else
                    out(i,2) = 1;
                end
                
                if isempty(dum21)
                    out(i,3) = 0;
                else
                    out(i,3) = 1;
                end                
                                
                if isempty(dum25)
                    out(i,4) = 0;
                else
                    out(i,4) = 1;
                end
                
                if isempty(dum28)
                    out(i,5) = 0;
                else
                    out(i,5) = 1;
                end
                
                if isempty(dum82)
                    out(i,6) = 0;
                else
                    out(i,6) = 1;
                    out_timecurr = [out_timecurr; dumtime(i)];
                    out82 = [out82; data82.data(dum82,:)];
                end 
                
                %sum across wave data for indexing
                out(i,7) = sum(out(i,2:5));
                if out(i,7)==4
                    out_timewave = [out_timewave; dumtimewave(i)];
                    out20 = [out20; data20(dum20,:)];
                    out21 = [out21; data21(dum21,:)];
                    out25 = [out25; data25(dum25,[4, 12, 14, 15])];
                    out28 = [out28; data28(dum28,:)];
                end                                                
            end
            
            eval(['Data' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out;'])
            eval(['Data20' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out20;'])            
            eval(['Data21' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out21;'])
            eval(['Data25' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out25;'])
            eval(['Data28' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out28;'])
            eval(['Data82' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out82;'])
            eval(['TimeWave' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out_timewave;'])
            eval(['TimeCurr' num2str(yrs(ii)) num2str(mths(kk),'%02d') '= out_timecurr;'])
            
            month{cnt,1} = [num2str(yrs(ii)) num2str(mths(kk),'%02d')];
                                
            cnt = cnt+1;
            
                
            clear ans data20 data21 data25 data28 data82 dum20 dum21 dum25...
                dum28 dum82 dumtime file20 file21 file25 file28 file82...
                out out20 out21 out25 out28 out82 RefTime time20 time21 time25 time28 time82 out_timewave out_timecurr
        end
    end
end

archive = [];
archive20 = [];
archive21 = [];
archive25 = [];
archive28 = [];
archive82 = [];
timewave = [];
timecurr = [];
archive_dates = [];

for i =1:length(month)   
    eval(['data = Data' month{i} ';']);
    eval(['data20 = Data20' month{i} ';']);
    eval(['data21 = Data21' month{i} ';']);
    eval(['data25 = Data25' month{i} ';']);
    eval(['data28 = Data28' month{i} ';']);
    eval(['data82 = Data82' month{i} ';']);
    eval(['twave = TimeWave' month{i} ';']);
    eval(['tcurr = TimeCurr' month{i} ';']);
    
    archive = [archive; data];
    archive20 = [archive20; data20];
    archive21 = [archive21; data21];
    archive25 = [archive25; data25];
    archive28 = [archive28; data28];
    archive82 = [archive82; data82];
    timewave = [timewave; twave];%time data acquisition started
    timecurr = [timecurr; tcurr];%time data acquisition started
    
    dum = month{i};
    archive_dates(i,1) = str2num(dum(1:4));
    archive_dates(i,2) = str2num(dum(5:6));
    clear dum 
    
end

end



