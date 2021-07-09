# -*- coding: utf-8 -*-
"""
Created on Wed Jun 30 10:19:35 2021

@author: 00084142
"""
import os
os.chdir(r'G:\CUTTLER_GitHub\wavebuoy_tools\pybuoy')
from toolsMC import buoy_data, buoy_tools
import numpy as np
import pandas as pd
from datetime import datetime as dt
from matplotlib import pyplot as plt
import cartopy.crs as ccrs

#%% import matlab archive
site = 'PerthCanyon'
archive_path = r'Y:\CUTTLER_wawaves\Data\realtime_archive_backup'
pcanyon = buoy_data.load_buoy_text_archive(site,archive_path)

#rename columns
c = list(pcanyon.columns)
pcanyon = pcanyon.rename(columns={c[0]:'time',c[1]:'timestamp',c[2]:'site',
                        c[3]:'buoyid',c[4]:'hs',c[5]:'tp',c[6]:'tm',
                        c[7]:'dp',c[8]:'dpspr',c[9]:'dm',c[10]:'dmspr',
                        c[11]:'qf_waves',c[12]:'surf_temp',c[13]:'qf_sst',
                        c[14]:'bott_temp',c[15]:'qf_bott_temp',
                        c[16]:'windspeed',c[17]:'winddir',c[18]:'curr_mag',
                        c[19]:'curr_dir',c[20]:'lat',c[21]:'lon'})
pcanyon = pcanyon.drop(columns=['curr_mag','curr_dir','buoyid','windspeed','winddir',
                                'surf_temp','bott_temp','qf_sst','qf_bott_temp'])

pcanyon['datetime'] = pd.to_datetime(pcanyon.timestamp)

#%% plot drifting path with hs
ax = plt.axes(projection=ccrs.PlateCarree())
os.environ["CARTOPY_USER_BACKGROUNDS"] = r'C:\Users\00084142\Dropbox\Research\PyMC\CARTOPY_USER_BACKGROUNDS'
ax.background_img(name='BM', resolution='high')
ax.set_extent([100, 125, -40, -18], crs=ccrs.PlateCarree())
ax.coastlines(resolution='10m')

plt.plot(pcanyon.lon, pcanyon.lat,'.',transform=ccrs.PlateCarree())
ax.plot(115.856588,-31.953823, 'ro', markersize=7, transform=ccrs.PlateCarree())
ax.text(115.9,-31.96, 'Perth', transform=ccrs.PlateCarree())

ax.plot(115.742866,-32.536452, 'ro', markersize=7, transform=ccrs.PlateCarree())
ax.text(115.8,-32.55, 'Mandurah', transform=ccrs.PlateCarree())

ax.set_xlim(114,116.5)
ax.set_ylim(-33,-31.5)


