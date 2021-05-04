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
    #loop through textarchive and load days into dataframe
    for i, file in enumerate(textarchive): 
        if i == 0:
            buoydata = pd.read_csv(file)      
        else: 
            buoydata = buoydata.append(pd.read_csv(file))
     
    return buoydata     
        

#%% 
            
        