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
import os 
import sys
from toolsMC import buoy_tools

#%% locally archived data
def load_buoy_text_archive(site, archive_path):
    """ 
    To be completed
    M Cuttler (UWA)
    """
    
    datapath = os.path.join(archive_path, site, 'text_archive')
    yrs = os.listdir(datapath)
    textarchive = []
    #get full path for each daily file
    for yr in yrs:
        months = os.listdir(os.path.join(datapath, yr))
        for month in months:
            days = os.listdir(os.path.join(datapath,yr,month))
            for dd in days:
                textarchive.append(os.path.join(datapath,yr,month,dd))
    #loop through text archive and load days into dataframe
    for i, file in enumerate(textarchive): 
        if i == 0:
            buoydata = pd.read_csv(file)      
        else: 
            buoydata = buoydata.append(pd.read_csv(file))
     
    return buoydata     
#%%
def load_buoy_mat_archive(site,filestart, fileend):
    """
    Parameters
    ----------
    site : TYPE
        DESCRIPTION.
    fielstart : TYPE
        DESCRIPTION.
    fileend : TYPE
        DESCRIPTION.
    filepath : TYPE
        DESCRIPTION.
     : TYPE
        DESCRIPTION.
    
    Example:
        filestart = r'Y:\CUTTLER_wawaves\Data\realtime_archive_backup'
        fileend = r'mat_archive\2021'
        
        
    Returns
    -------
    data : TYPE
        DESCRIPTION.

    """

    filepath = os.path.join(filestart,site,fileend)                   
    files = os.listdir(filepath)
    data = dict([])
    
    for j, file in enumerate(files):
        f = h5py.File(os.path.join(filepath,file),'r')
        fields = np.array(f['SpotData'])     
        for field in fields:
            if j==0:
                data[field]=np.transpose(np.array(f['SpotData'][field]))
            else:
                data[field]=np.append(data[field],np.transpose(np.array(f['SpotData'][field])))
            
    #convert time to datetime
    data['datetime'] = []

    for j, val in enumerate(data['time']):
        data['datetime'].append(buoy_tools.matlab2datetime(val))
    data['datetime_temp']=[]
    for j, val in enumerate(data['temp_time']):
        data['datetime_temp'].append(buoy_tools.matlab2datetime(float(val)))     
    return data                

#%% WA DoT data
def import_WA_DoT(datapath):
    """
    MC to complete
    UWA, 2021
    Parameters
    ----------
    datapath : TYPE
        DESCRIPTION.

    Returns
    -------
    None.

    """
    files = os.listdir(datapath)
    #only keep csv 
    files = [file for file in files if file[-3:]=='csv']
    
    #suck in data to dataframe
    for i, file in enumerate(files):
        if i==0:
            dot = pd.read_csv(os.path.join(datapath,file))
        else:
            dot = dot.append(pd.read_csv(os.path.join(datapath,file)))
            
    return dot 
            
        