# -*- coding: utf-8 -*-
"""
Created on Thu Jul  1 10:00:29 2021

@author: 00084142
"""

import numpy as np
import pandas as pd
import xarray as xr
import cartopy.crs as ccrs
from matplotlib import pyplot as plt
import os
os.chdir(r'G:\CUTTLER_GitHub\wavebuoy_tools\pybuoy')
from toolsMC import buoy_tools, buoy_data
from datetime import datetime, timedelta
import imageio

#%% pull in wave buoy - could probably access directly from AWS? 
site = 'Dampier'
archive_path = r'F:\Active_Projects\CUTTLER_wawaves\Data\realtime_archive_backup'
dampier = buoy_data.load_buoy_text_archive(site, archive_path)
c = dampier.columns
dampier = dampier.rename(columns={c[0]:'time',c[1]:'timestamp',c[2]:'site',
                        c[3]:'buoyid',c[4]:'hs',c[5]:'tp',c[6]:'tm',
                        c[7]:'dp',c[8]:'dpspr',c[9]:'dm',c[10]:'dmspr',
                        c[11]:'qf_waves',c[12]:'surf_temp',c[13]:'qf_sst',
                        c[14]:'bott_temp',c[15]:'qf_bott_temp',
                        c[16]:'windspeed',c[17]:'winddir',c[18]:'curr_mag',
                        c[19]:'curr_dir',c[20]:'lat',c[21]:'lon'})
dampier['datetime'] = pd.to_datetime(dampier['timestamp'])
dampier = dampier[2:]
dampier = dampier.reset_index().drop(columns='index')
#%% get Ivica's model forecast from THREDDS
t1 = datetime(2021,6,30)
tend = datetime(2021,7,4)
dates = pd.date_range(t1,tend,freq='d')

#build list for xarray multi-import 
ncbase = 'http://130.95.29.59:8080/thredds/dodsC/NWS_NEW/qck_'
nclist = []
for date in dates:
    nclist.append(ncbase + date.strftime('%Y%m%d') + '.nc')
    
ds = xr.open_mfdataset(nclist,combine='by_coords')
#%% make figures/gif 
filepath = r'F:\Active_Projects\LOWE_IMOS_WaveBuoys\OutReach_Media_Promo(Photos)\Data_GIFs\Dampier2021'
filenames = []   
for i in range(len(ds.ocean_time)):
    # if ds.ocean_time[i].data < np.datetime64(datetime.utcfromtimestamp(dampier['time'].iloc[-1])):
    cmag = (ds.u_sur_eastward[i,:,:]**2+ds.v_sur_northward[i,:,:]**2)**0.5
    plt.figure(figsize=(10,8))
    plt.pcolormesh(ds.lon_rho, ds.lat_rho,cmag,shading='auto',vmin=0,vmax=0.5)
    plt.axis('equal')           
    plt.xlim(116.25, 116.75)
    plt.ylim(-20.75,-20.25)
    plt.quiver(ds.lon_rho, ds.lat_rho, ds.u_sur_eastward[i,:,:],ds.v_sur_northward[i,:,:],scale=5,scale_units='xy',
                   width=0.005)    
    plt.colorbar(label='Current velocity (m/s)')
    plt.xlabel('Longitude')
    plt.ylabel('Latitude')     
    plt.title(pd.to_datetime(str(ds.ocean_time[i].data+np.timedelta64(8,'h'))).strftime('%Y-%m-%d %H:%M') + ' AWST')     
    ibuoy = np.abs(dampier.datetime - ds.ocean_time[i].data).idxmin()
    if i > 0:
        plt.plot(dampier.lon[10446:ibuoy],dampier.lat[10446:ibuoy],'b.',markersize=8)
    plt.plot(dampier.lon[ibuoy],dampier.lat[ibuoy],'r.',markersize=16)
    
    ff = 'Dampier_surface_vel' + str(i).zfill(3) +'.png'
    figname = os.path.join(filepath,ff)    
    filenames.append(figname)    
    # save frame
    plt.savefig(figname)
    plt.close()
    
#%% build gif
outpath = r'F:\Active_Projects\LOWE_IMOS_WaveBuoys\OutReach_Media_Promo(Photos)\Data_GIFs\Dampier2021'
outgif = 'buoy.gif'
with imageio.get_writer(os.path.join(outpath,outgif), mode='I') as writer:
    for filename in filenames:
        image = imageio.imread(filename)
        writer.append_data(image)
        
images = list(map(lambda filename: imageio.imread(filename), filenames))   
imageio.mimsave(os.path.join(outpath,outgif), images, duration = 0.25) # modify the frame duration as needed

