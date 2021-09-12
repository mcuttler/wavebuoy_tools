# -*- coding: utf-8 -*-
"""
Created on Thu Feb  4 20:39:43 2021

@author: 00084142
"""

#%% Tools for Sofar wave buoys
import requests
import json 
import numpy as np
import pandas as pd
from datetime import datetime, timedelta
import pytz 
import os
import glob
#%% 

def get_spotter_realtime(buoy_info):
    """    
    Parameters
    ----------
    buoy_info : dict
        contains meta-data on buoy of interest. including serial (SpotterID), and 
        parameters to include for GET request

    Returns
    -------
    SpotData : disct
        most recent data from Sofar API for buoy of interest.

    """
    head={'token': buoy_info['token'],'spotterId': buoy_info['SpotterID']}
    parameters = {'limit': buoy_info['limit'],'includeWaves':buoy_info['includeWaves'],
                  'includeWindData':buoy_info['includeWindData'],
                  'includeSurfaceTempData':buoy_info['includeSurfaceTempData']}
    response = requests.get('https://api.sofarocean.com/api/wave-data?spotterId='+buoy_info['SpotterID'], 
                            headers=head, params=parameters)
    
    #extract JSON string to dictionary
    raw_json = response.json()
    dumdata = raw_json['data']
    
    #loop through and build into numpy arrays
    
    
    return SpotData 

#%% concatenate smart mooring (temperature data)
def concatenate_smart_mooring(buoy_path,file_ext,num_sensors):
    """
        Parameters
    ----------
    buoy_path : sttr
        location of smart-mooring memory card CSVs.
    file_ext : str
        extension of memory card CSV file - e.g. 'SMT'.
    num_sensors : int
        number of sensors on smart-mooring.

    Returns
    -------
    smart_mooring : DataFrame
        concatenated dataframe of all smart mooring files.

    """
    #get list of files to concatenate        
    files = glob.glob(os.path.join(buoy_path,'*'+file_ext+'*'))
    #error if no smart mooring files
    if not files:
        print('No files with ' + file_ext +' - check directory')
    #create column labels
    cols = ['millis','EpochTime','LogType']
    for sensor in list(range(num_sensors)):
        cols.append('sensor'+str(sensor))
            
    for i, file in enumerate(files): 
        print(file[-12:])          
        d = pd.read_csv(file,names=cols,index_col=False,header=0,on_bad_lines='skip')                                
        if i==0:
            smart_mooring = d
        else:
            smart_mooring = smart_mooring.append(d)           
    smart_mooring = smart_mooring.reset_index().drop(columns=['index','millis','LogType'])  
    #calculate time ignore milliseconds 
    smart_mooring['time'] = pd.to_datetime(smart_mooring.EpochTime,unit='s')  
    smart_mooring = smart_mooring.set_index('time')                 
    
    return smart_mooring