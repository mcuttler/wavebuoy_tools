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
def plot_drifting_gif(buoydata):
    
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
            
        