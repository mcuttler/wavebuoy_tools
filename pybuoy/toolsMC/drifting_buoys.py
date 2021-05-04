import numpy as np
import pandas as pd
import matplotlib.pyplot as plt
import cartopy.crs as ccrs
from matplotlib.gridspec import GridSpec
import sys
import os

#%% Load wave buoy data
time=pd.date_range(start='1/27/2020', end='11/23/2020',freq='1H')

# Spotter Southern Ocean
for ind in range(3):
    raw_SO_dum=pd.read_csv(r'D:\Dropbox\Boxifier\Wave_buoy_project\Results\Drifting_animation\Data\SPOT-0170_History_' + str(ind) + '.csv',header=0)
    raw_SO_dum.index=pd.to_datetime(raw_SO_dum['Epoch Time'],unit='s')
    if ind==0:
        raw_SO=raw_SO_dum.iloc[::-1]
    else:
        raw_SO=pd.concat([raw_SO,raw_SO_dum.iloc[::-1]])
S_SO=raw_SO[['Longitude (deg)','Latitude (deg)','Significant Wave Height (m)','Peak Period (s)']].reindex(time,method='pad')
S_SO.columns=['Lon','Lat','Hs','Tp']
S_SO['Hs'].plot()
    

# Spotter Indian Ocean
for ind in range(3):
    raw_IO_dum=pd.read_csv(r'D:\Dropbox\Boxifier\Wave_buoy_project\Results\Drifting_animation\Data\SPOT-0093_History_' + str(ind) + '.csv',header=0,low_memory=False,na_values='-')
    raw_IO_dum.index=pd.to_datetime(raw_IO_dum['Epoch Time'],unit='s')
    if ind==0:
        raw_IO=raw_IO_dum.iloc[::-1]
    else:
        raw_IO=pd.concat([raw_IO,raw_IO_dum.iloc[::-1]])
S_IO=raw_IO[['Longitude (deg)','Latitude (deg)','Significant Wave Height (m)','Peak Period (s)']].reindex(time,method='pad')
S_IO.columns=['Lon','Lat','Hs','Tp']
S_IO['2020-09-01':'2020-12-01']=np.nan
S_IO['Hs'].plot()

for frame in range(int(len(time)/6)):
    ind=frame*6    
    fig = plt.figure(figsize=(12,17))
    gs = GridSpec(3, 1, height_ratios=[4,1,1])
    ax = fig.add_subplot(gs[0],projection=ccrs.PlateCarree())
    ax.set_title(time[ind],fontsize=16)
    os.environ["CARTOPY_USER_BACKGROUNDS"] = "d:/Dropbox/Boxifier/Wave_buoy_project/Results/Cartopy_backgrounds/"
    ax.background_img(name='BM', resolution='high')
    ax.set_extent([100, 125, -40, -18], crs=ccrs.PlateCarree())
    ax.coastlines('10m')
    cmap=ax.scatter(S_SO['Lon'].iloc[0:ind],S_SO['Lat'].iloc[0:ind],c=S_SO['Hs'].iloc[0:ind],cmap='jet',vmin=1,vmax=5,transform=ccrs.PlateCarree())
    ax.scatter(S_IO['Lon'].iloc[0:ind],S_IO['Lat'].iloc[0:ind],c=S_IO['Hs'].iloc[0:ind],cmap='jet',vmin=1,vmax=5,transform=ccrs.PlateCarree())
    cb=plt.colorbar(cmap)
    cb.set_label('$H_s$ [m]',fontsize=16,rotation=0,labelpad=40)
    ax1 = fig.add_subplot(gs[1])
    ax1.plot(time,S_SO['Hs'],color='k')
    ax1.plot(time[ind],S_SO['Hs'].iloc[ind],marker='o',markerfacecolor='red')
    ax1.plot([time[ind],time[ind]],[0,10],color='r')
    ax1.set_ylim(1,10)
    ax1.set_xticks(time[::30*48])
    ax1.set_xlim(time[0],time[-1])
    ax1.set_ylabel('$H_s$ [m]',fontsize=14)

    ax2 = fig.add_subplot(gs[2])
    ax2.plot(time,S_IO['Hs'],color='k')
    ax2.plot(time[ind],S_IO['Hs'].iloc[ind],marker='o',markerfacecolor='red')
    ax2.plot([time[ind],time[ind]],[0,10],color='r')
    ax2.set_ylim(1,10)
    ax2.set_xticks(time[::30*48])
    ax2.set_xlim(time[0],time[-1])
    ax2.set_ylabel('$H_s$ [m]',fontsize=14)

    fig.savefig(f"Frames/frame_{frame:04d}.png", dpi=300)
    plt.close(fig)    

