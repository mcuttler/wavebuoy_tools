%% create and save MEMplot
%M Cuttler - June 2019

%update 1
    %edit to account for errors in Datawell files (primarily the theta
    %value) which causes dp and hs to be NaN
%%

function [] = make_MEM_plot(ndirec, freq, NE, hs, tp, dp, time)

        ndirec2 = [ndirec 360];
        NE_plot = [NE NE(:,1)];
        NE_plot2 = NE_plot;
        
        %Interp to finescale grid
        % fnew = [min(freq):0.001:max(freq)]';
        fnew=[5:0.2:25]'; 
        dnew = [min(ndirec):0.05:max(ndirec2)];
        [NE_new] = griddata(ndirec2,1./freq,NE_plot,dnew,fnew);
        NE_new2 = NE_new./max(max(NE_new));
        
        fid = figure;
        set(gcf,'Position',[100 767 668 571])
        [h,c] = polarPcolor_final(fnew',dnew,NE_new2,NE_new,'Ncircles',5,'Nspokes',13);
        %[h,c] = polarPcolorMC2(fnew',dnew,NE_new2,NE_new,'Ncircles',5,'Nspokes',13);
        cmap = jet(150);
        colormap(cmap);
        
        %Display Hsig, Tp, Dp        
        text(0.85,0.05,['Hs = ' num2str(round(hs,2)) 'm'],'units','normalized','fontweight','bold','fontsize',12);                        
  
        text(0.85,0.0,['Tp = ' num2str(round(tp,1)) 's'],'units','normalized','fontweight','bold','fontsize',12);                      

        text(0.85,-0.05,['Dp = ' num2str(round(dp)) 'deg'],'units','normalized','fontweight','bold','fontsize',12);
        
        t = title([datestr(time+datenum(0,0,0,8,0,0)) 'WST']);
        t.Position = [0 1.4 0];
        % set(fid,'color',[0.65 0.65 0.65]);
        set(fid,'color','w');
        % caxis([(thresh*max(max(NE_plot))) max(max(NE_plot))*0.8])
        cmap = colormap;
        cmap(1,1:3) = [0.9 0.9 0.9];
        colormap(cmap);
        
        cmap2 = [cmap(1,1:3);ones(10,3);cmap(2:end,:)];
        cmap2(2:11,1) = linspace(cmap(1,1),cmap(2,1),10);
        cmap2(2:11,2) = linspace(cmap(1,2),cmap(2,2),10);
        cmap2(2:11,3) = linspace(cmap(1,3),cmap(2,3),10);
        colormap(fid,cmap2);  
        

        %store everything by year and month - save in folder corresponding to when data transmission (e.g. end of data acquisition) 
        time2 = datevec(time+datenum(0,0,0,0,30,0));
        yr = num2str(time2(1));
        mo = num2str(time2(2),'%02d');
        %---------------------------------------------------------------------------
        
        %close(fid);
       
end
