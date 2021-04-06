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
site = 'SharkBay'
# deploy_loc = [113.130500,-25.420100]
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
    
            
        