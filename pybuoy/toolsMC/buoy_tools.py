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
import math

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
def match_times(tseries1, tseries2):
    """
    find matching (or closest) time points between two time series
    
    M Cuttler
    UWA, 2021

    Parameters
    ----------
    tseries1 : List
        DESCRIPTION.
    tserise2 : List
        DESCRIPTION.

    Returns
    -------
    index for subsetting larger timeseries

    """  
    tseries1 = np.array(tseries1) 
    tseries2 = np.array(tseries2)     

    if len(tseries1)<len(tseries2):
        a = tseries1
        b = tseries2
    else:
        a = tseries2
        b = tseries1
        
    #loop over shortest variable
    for j, t in enumerate(a):
        tmin = min(b, key=lambda x: abs(x-t))            
        if j==0:
            ind = np.argwhere(b==tmin)    
        else:
            ind = np.append(ind,np.argwhere(b==tmin))
    ind = ind.tolist()
    
    return ind
            

        
        
        