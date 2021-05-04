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
            
        