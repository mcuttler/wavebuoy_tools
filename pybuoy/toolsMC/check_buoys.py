# -*- coding: utf-8 -*-
"""
Created on Tue Apr  6 09:30:39 2021

@author: 00084142
"""

import numpy as np
from scipy.io import loadmat
import matplotlib.pyplot as plt
import pandas as pd
import datetime as dt
import h5py
import os
import netCDF4 as nc
import numpy as np 
import cartopy.crs as ccrs
from matplotlib.gridspec import GridSpec
import sys

#%%
def matlab2datetime(matlab_datenum):
    """  
    Convert matlab datenum format to datetime format
    
    Parameters
    ----------
    matlab_datenum : TYPE
        DESCRIPTION.

    Returns
    -------
    TYPE
        DESCRIPTION.

    """
    day = dt.datetime.fromordinal(int(matlab_datenum))
    dayfrac = dt.timedelta(days=matlab_datenum%1) - dt.timedelta(days = 366)
    return day + dayfrac
#%% 
def make_drifting_gif(site):
    filestart = r'Y:\CUTTLER_wawaves\Data\realtime_archive_backup'
    fileend = r'mat_archive\2021'
    filepath = os.path.join(filestart,site,fileend)
                        
    files = os.listdir(filepath)
    data = dict([])

    for j, file in enumerate(files):
        f = h5py.File(os.path.join(filepath,file))
        fields = np.array(f['SpotData'])     
        for field in fields:
            if j==0:
                data[field]=np.transpose(np.array(f['SpotData'][field]))
            else:
                try:
                    data[field]=np.append(data[field],np.transpose(np.array(f['SpotData'][field])))
                else
            
    #convert time to datetime
    data['datetime'] = []

    for j, val in enumerate(data['time']):
        data['datetime'].append(matlab2datetime(val))
    data['datetime_temp']=[]
    for j, val in enumerate(data['temp_time']):
        data['datetime_temp'].append(matlab2datetime(float(val)))
    
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
#%% 
def plot_gps_history(site):
    filestart = r'Y:\CUTTLER_wawaves\Data\realtime_archive_backup'
    fileend = r'mat_archive\2021'
    filepath = os.path.join(filestart,site,fileend)
                        
    files = os.listdir(filepath)
    data = dict([])
    
    for j, file in enumerate(files):
        f = h5py.File(os.path.join(filepath,file))
        fields = np.array(f['SpotData'])     
        for field in fields:
            if j==0:
                data[field]=np.transpose(np.array(f['SpotData'][field]))
            else:
                data[field]=np.append(data[field],np.transpose(np.array(f['SpotData'][field])))
            
    #convert time to datetime
    data['datetime'] = []

    for j, val in enumerate(data['time']):
        data['datetime'].append(matlab2datetime(val))
    data['datetime_temp']=[]
    for j, val in enumerate(data['temp_time']):
        data['datetime_temp'].append(matlab2datetime(float(val)))
    
    #calculate time index by month
    tind = pd.Series(data['datetime']).dt.month

    #plot lat/lon by month
    plt.figure()
    for val in pd.unique(tind):
        plt.plot(data['lon'][tind==val],data['lat'][tind==val],'.')
        plt.grid('on')
    plt.show()
    # plt.plot(deploy_loc[0],deploy_loc[1],'kx',markersize=12)
    plt.legend(['Jan','Feb','Mar','Apr','DeployLoc'])
    plt.title(site)
    
